// BrowserController.swift

import WebKit
import UIKit
import Combine

@MainActor
final class BrowserController: NSObject, ObservableObject {

    @Published var currentURL: String = ""
    @Published var isLoading: Bool    = false
    @Published var pageTitle: String  = ""
    @Published var lastError: String? = nil

    /// OAuth popup webview — non-nil while a "login with Google/Apple/etc." popup is active.
    /// The BrowserView observes this and presents it as a sheet.
    @Published var oauthPopup: WKWebView? = nil

    let webView: WKWebView
    var onPageLoaded: (() -> Void)?

    // MARK: - Init

    override init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Use default data store (shares cookies with Safari — needed for login persistence)
        config.websiteDataStore = WKWebsiteDataStore.default()

        // Enable JavaScript (on by default, but be explicit)
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        // Use a real initial frame — loading a page with frame .zero can cause blank renders.
        // A generous fixed frame works for our use case (SwiftUI will resize it on layout anyway).
        let initialFrame = CGRect(x: 0, y: 0, width: 430, height: 932)
        self.webView = WKWebView(frame: initialFrame, configuration: config)
        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate         = self
        webView.allowsBackForwardNavigationGestures = true

        // Modern Safari user agent — many sites block old or embedded webview UAs
        webView.customUserAgent =
            "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
            "Version/18.4 Mobile/15E148 Safari/604.1"
    }

    // MARK: - Session Reset
    //
    // Clears ALL cookies, local/session storage, cache, and IndexedDB for every
    // origin the webview has ever touched. Called at the start of every task so
    // stale auth state from the previous service (Claude → Dropbox → Notion) can't
    // collide with the new login flow.
    func resetSession() async {
        // 1. Stop anything loading and clear the popup
        webView.stopLoading()
        oauthPopup = nil
        currentURL = ""
        pageTitle  = ""
        lastError  = nil

        // 2. Wipe EVERY type of website data across ALL domains
        let allTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let dataStore = WKWebsiteDataStore.default()
        let records = await dataStore.dataRecords(ofTypes: allTypes)
        await dataStore.removeData(ofTypes: allTypes, for: records)

        // 3. Clear HTTP shared cookies too (belt + suspenders)
        HTTPCookieStorage.shared.cookies?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }

        // 4. Clear URL cache
        URLCache.shared.removeAllCachedResponses()

        // 5. Load a blank page so no page-level JS is left running
        webView.load(URLRequest(url: URL(string: "about:blank")!))

        print("[Browser] Session reset complete — cleared \(records.count) data records")
    }

    // MARK: - Navigation

    func navigate(to urlString: String) {
        lastError = nil

        // Normalise URL — add https:// if missing
        var normalized = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !normalized.lowercased().hasPrefix("http://") && !normalized.lowercased().hasPrefix("https://") {
            normalized = "https://" + normalized
        }

        guard let url = URL(string: normalized) else {
            lastError = "Invalid URL: \(urlString)"
            return
        }

        // If only the hash/fragment changed on the same page, use JS navigation
        if let current = webView.url,
           url.scheme == current.scheme,
           url.host   == current.host,
           url.path   == current.path,
           let fragment = url.fragment {
            webView.evaluateJavaScript("window.location.hash = '\(fragment.jsEscaped)';")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self else { return }
                self.currentURL = normalized
                NotificationCenter.default.post(name: .browserPageLoaded, object: self)
            }
            return
        }

        print("[Browser] Loading: \(normalized)")
        webView.load(URLRequest(url: url))
    }

    /// Reads the REAL current URL from the webview (including hash/fragment).
    func syncCurrentURL() async {
        if let real = await runJS("window.location.href") as? String,
           !real.isEmpty, real.hasPrefix("http") {
            currentURL = real
        }
    }

    // MARK: - Screenshot

    func takeScreenshot() async -> UIImage? {
        await withCheckedContinuation { cont in
            webView.takeSnapshot(with: WKSnapshotConfiguration()) { image, _ in
                cont.resume(returning: image)
            }
        }
    }

    // MARK: - Full page snapshot (text + every interactive element)

    func extractPageSnapshot() async -> PageSnapshot {
        try? await Task.sleep(nanoseconds: 500_000_000)
        await syncCurrentURL()
        let text     = await extractText()
        let elements = await extractInteractiveElements()
        return PageSnapshot(text: text, elements: elements, url: currentURL)
    }

    private func extractText() async -> String {
        (await runJS("document.body ? document.body.innerText : ''") as? String) ?? ""
    }

    /// Extracts EVERY interactive element: links, buttons, profile icons, avatars,
    /// hamburger menus, nav items, dropdowns — anything a user could tap.
    private func extractInteractiveElements() async -> [PageElement] {
        let js = """
        (function() {
            var results = [];
            var seen    = new Set();

            function addEl(text, href, selector, area) {
                var key = (href || '') + '::' + (text || '') + '::' + (selector || '');
                if (seen.has(key) || !key.trim()) return;
                seen.add(key);
                results.push({ text: text || '', href: href || '', selector: selector || '', area: area || '' });
            }

            function bestSelector(el) {
                if (el.id) return '#' + el.id;
                var testId = el.getAttribute('data-testid') || el.getAttribute('data-test') || el.getAttribute('data-cy');
                if (testId) return '[data-testid="' + testId + '"]';
                var ariaLabel = el.getAttribute('aria-label');
                if (ariaLabel) return '[aria-label="' + ariaLabel.replace(/"/g,'') + '"]';
                var cls = Array.from(el.classList).slice(0,3).join('.');
                return el.tagName.toLowerCase() + (cls ? '.' + cls : '');
            }

            function pageArea(el) {
                var rect = el.getBoundingClientRect();
                var w = window.innerWidth, h = window.innerHeight;
                var vert = rect.top < h*0.25 ? 'top' : rect.top > h*0.75 ? 'bottom' : 'middle';
                var horiz = rect.left > w*0.6 ? 'right' : rect.left < w*0.4 ? 'left' : 'center';
                return vert + '-' + horiz;
            }

            // 1. All <a> links
            document.querySelectorAll('a[href]').forEach(function(a) {
                var text = (a.innerText || a.getAttribute('aria-label') || a.title || '').trim();
                var href = a.href;
                if (href && href.startsWith('http')) addEl(text, href, bestSelector(a), pageArea(a));
            });

            // 2. Buttons
            document.querySelectorAll('button, [role="button"]').forEach(function(el) {
                var text = (el.innerText || el.getAttribute('aria-label') || el.title || '').trim();
                addEl(text, '', bestSelector(el), pageArea(el));
            });

            // 3. Nav / menu items
            document.querySelectorAll('nav a, nav button, [role="menuitem"], [role="tab"], [role="navigation"] a').forEach(function(el) {
                var text = (el.innerText || el.getAttribute('aria-label') || '').trim();
                var href = el.href || '';
                addEl(text, href, bestSelector(el), pageArea(el));
            });

            // 4. Profile / avatar / user icon
            var profileSelectors = [
                '[data-testid*="avatar"]', '[data-testid*="profile"]', '[data-testid*="user"]',
                '[data-testid*="account"]', '[aria-label*="account" i]', '[aria-label*="profile" i]',
                '[aria-label*="user" i]', '[aria-label*="menu" i]', '[aria-label*="settings" i]',
                '.avatar', '.user-avatar', '.profile-pic', '.profile-image',
                'img[src*="avatar"]', 'img[src*="profile"]', 'img[src*="user"]',
                'header img', 'header [role="button"]', 'header button',
                '[class*="avatar"]', '[class*="profile"]', '[class*="userMenu"]',
                '[class*="user-menu"]', '[class*="AccountMenu"]'
            ];
            profileSelectors.forEach(function(sel) {
                try {
                    document.querySelectorAll(sel).forEach(function(el) {
                        var text = (el.getAttribute('aria-label') || el.title || el.alt || el.innerText || 'Profile/Account icon').trim();
                        addEl('[PROFILE ICON] ' + text, '', bestSelector(el), pageArea(el));
                    });
                } catch(e) {}
            });

            // 5. Hamburger / sidebar / drawer toggles
            var menuSelectors = [
                '[aria-label*="menu" i]', '[aria-label*="navigation" i]', '[aria-label*="hamburger" i]',
                '[data-testid*="menu"]', '[data-testid*="hamburger"]', '[data-testid*="sidebar"]',
                '[class*="hamburger"]', '[class*="menuToggle"]', '[class*="sidebar-toggle"]',
                'button[class*="menu"]'
            ];
            menuSelectors.forEach(function(sel) {
                try {
                    document.querySelectorAll(sel).forEach(function(el) {
                        var text = (el.getAttribute('aria-label') || el.innerText || 'Menu toggle').trim();
                        addEl('[MENU] ' + text, '', bestSelector(el), pageArea(el));
                    });
                } catch(e) {}
            });

            // 6. Header area
            document.querySelectorAll('header *, [role="banner"] *').forEach(function(el) {
                if (!['A','BUTTON','IMG','SPAN','DIV'].includes(el.tagName)) return;
                var clickable = el.onclick || el.getAttribute('href') || el.getAttribute('role') === 'button'
                    || getComputedStyle(el).cursor === 'pointer';
                if (!clickable) return;
                var text = (el.innerText || el.getAttribute('aria-label') || el.title || el.alt || '').trim();
                if (text) addEl('[HEADER] ' + text, el.href || '', bestSelector(el), 'top-' + (el.getBoundingClientRect().left > window.innerWidth/2 ? 'right' : 'left'));
            });

            // 7. Dropdown menus / popovers / dialogs
            document.querySelectorAll('[role="menu"] *, [role="dialog"] *, [role="listbox"] *, [role="tooltip"] *, [data-radix-popper-content-wrapper] *, [data-headlessui-state] *, .dropdown-menu *, .popover *, [class*="dropdown"] *, [class*="popover"] *, [class*="menu-item"] *').forEach(function(el) {
                if (!['A','BUTTON','LI','SPAN','DIV'].includes(el.tagName)) return;
                var text = (el.innerText || el.getAttribute('aria-label') || '').trim();
                var href = el.href || '';
                var clickable = el.onclick || href || el.getAttribute('role') || getComputedStyle(el).cursor === 'pointer';
                if (text && clickable) addEl('[DROPDOWN] ' + text, href, bestSelector(el), pageArea(el));
            });

            // 8. Hash-based SPA links
            document.querySelectorAll('a[href*="#"]').forEach(function(a) {
                var text = (a.innerText || a.getAttribute('aria-label') || a.title || '').trim();
                var href = a.href;
                if (href && text) addEl('[HASH-LINK] ' + text, href, bestSelector(a), pageArea(a));
            });

            // 9. Bottom-of-sidebar account buttons (ChatGPT / Slack / Notion style)
            // These services place the logged-in user's avatar/name at the BOTTOM
            // of the left sidebar. Critical: this is often where "Settings" / "Billing"
            // are accessed from.
            var allNav = document.querySelectorAll(
                'nav *, aside *, [role="navigation"] *, [role="complementary"] *'
            );
            for (var bi = 0; bi < allNav.length; bi++) {
                var bel = allNav[bi];
                if (!['A','BUTTON','LI','DIV','SPAN'].includes(bel.tagName)) continue;
                var brect = bel.getBoundingClientRect();
                if (brect.width === 0 || brect.height === 0) continue;
                if (brect.top < window.innerHeight * 0.65) continue;   // bottom 35%
                var clickable = bel.onclick || bel.href || bel.getAttribute('role') === 'button'
                    || bel.tagName === 'BUTTON' || bel.tagName === 'A'
                    || getComputedStyle(bel).cursor === 'pointer';
                if (!clickable) continue;
                var btext = (bel.innerText || bel.getAttribute('aria-label') || bel.title || '').trim();
                if (btext && btext.length < 80) {
                    addEl('[BOTTOM-NAV] ' + btext, bel.href || '', bestSelector(bel), 'bottom-left');
                }
            }

            // Prioritise: profile/dropdown/header/bottom-nav always first
            function isPriority(r) {
                return r.text.indexOf('[PROFILE')    === 0 || r.text.indexOf('[MENU')       === 0
                    || r.text.indexOf('[HEADER')     === 0 || r.text.indexOf('[DROPDOWN')   === 0
                    || r.text.indexOf('[BOTTOM-NAV') === 0;
            }
            var priority = results.filter(function(r) { return isPriority(r); });
            var rest     = results.filter(function(r) { return !isPriority(r); });
            return JSON.stringify(priority.concat(rest).slice(0, 70));
        })();
        """

        guard
            let raw  = await runJS(js) as? String,
            let data = raw.data(using: .utf8),
            let arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: String]]
        else { return [] }

        return arr.map {
            PageElement(
                text:     $0["text"]     ?? "",
                href:     $0["href"]     ?? "",
                selector: $0["selector"] ?? "",
                area:     $0["area"]     ?? ""
            )
        }
    }

    // MARK: - JS Actions

    @discardableResult
    func runJS(_ script: String) async -> Any? {
        try? await webView.evaluateJavaScript(script)
    }

    func click(selector: String) async {
        let js = """
        (function(){
            var el = document.querySelector('\(selector.jsEscaped)');
            if (!el) return false;
            el.scrollIntoView({block:'center'});
            el.focus();
            ['mouseover','mouseenter','mousedown','mouseup'].forEach(function(type) {
                el.dispatchEvent(new MouseEvent(type, {bubbles:true, cancelable:true}));
            });
            el.click();
            el.dispatchEvent(new MouseEvent('mouseleave', {bubbles:true}));
            return true;
        })();
        """
        await runJS(js)
    }

    func clickAt(x: Double, y: Double) async {
        let js = """
        (function(){
            var el = document.elementFromPoint(\(x), \(y));
            if(el){
                el.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,clientX:\(x),clientY:\(y)}));
                el.dispatchEvent(new MouseEvent('mouseup',  {bubbles:true,clientX:\(x),clientY:\(y)}));
                el.click(); return true;
            }
            return false;
        })();
        """
        await runJS(js)
    }

    func clickByText(_ text: String) async {
        let safe = text.jsEscaped.lowercased()
        let js = """
        (function(){
            var all = document.querySelectorAll('a, button, [role="button"], [role="menuitem"], li, span, div, img');
            for (var i = 0; i < all.length; i++) {
                var t = (all[i].innerText || all[i].getAttribute('aria-label') || all[i].title || all[i].alt || '').trim().toLowerCase();
                if (t === '\(safe)' || t.includes('\(safe)')) {
                    all[i].scrollIntoView({block:'center'});
                    all[i].click();
                    return true;
                }
            }
            return false;
        })();
        """
        await runJS(js)
    }

    func type(selector: String, text: String) async {
        let js = """
        (function(){
            var el = document.querySelector('\(selector.jsEscaped)');
            if(!el) return false;
            el.focus();
            el.value = '\(text.jsEscaped)';
            el.dispatchEvent(new Event('input',  {bubbles:true}));
            el.dispatchEvent(new Event('change', {bubbles:true}));
            return true;
        })();
        """
        await runJS(js)
    }

    func scroll(byY pixels: Int) async {
        await runJS("window.scrollBy(0, \(pixels));")
    }

    func extractPageText() async -> String { await extractText() }

    // MARK: - Sidebar closer
    // When the sidebar is open on a settings page it covers the settings content.
    // Close it first so "Manage subscription" and other billing buttons are visible/clickable.

    @discardableResult
    func tryCloseSidebar() async -> Bool {
        let js = """
        (function() {
            var selectors = [
                '[data-testid="close-sidebar-button"]',
                '[aria-label="Close sidebar"]',
                '[aria-label="Close navigation"]',
                '[aria-label="Hide sidebar"]',
                '[aria-label="Toggle sidebar"]',
            ];
            for (var i = 0; i < selectors.length; i++) {
                var el = document.querySelector(selectors[i]);
                if (!el) continue;
                var rect = el.getBoundingClientRect();
                if (rect.width === 0 || rect.height === 0) continue;
                el.click();
                return 'closed:' + selectors[i];
            }
            return null;
        })();
        """
        let result = await runJS(js)
        if let str = result as? String, !str.isEmpty, !(result is NSNull) {
            print("[Browser] Sidebar closed: \(str)")
            return true
        }
        return false
    }

    // MARK: - Proactive sidebar opener
    //
    // On mobile-layout SPAs (ChatGPT, Notion, Slack etc.) the sidebar is COLLAPSED
    // by default. The account/profile button is hidden inside it.
    // We must open the sidebar FIRST before tryClickAccountMenu() can find the button.

    @discardableResult
    func tryOpenSidebar() async -> Bool {
        let js = """
        (function() {
            var selectors = [
                '[data-testid="open-sidebar-button"]',
                '[aria-label="Open sidebar"]',
                '[aria-label="Open navigation"]',
                '[aria-label="Show sidebar"]',
                '[aria-label="Toggle sidebar"]',
                '[aria-label="Open menu"]',
                '[aria-label="Menu"]',
                'button[class*="sidebar"][class*="open"]',
                'button[class*="menu-toggle"]',
                'button[class*="hamburger"]',
                'button[class*="MenuButton"]',
                'button[class*="NavToggle"]',
                'button[class*="SidebarToggle"]',
            ];
            for (var i = 0; i < selectors.length; i++) {
                var el = document.querySelector(selectors[i]);
                if (!el) continue;
                var rect = el.getBoundingClientRect();
                if (rect.width === 0 || rect.height === 0) continue;
                el.dispatchEvent(new MouseEvent('mousedown', {bubbles:true, cancelable:true}));
                el.dispatchEvent(new MouseEvent('mouseup',   {bubbles:true, cancelable:true}));
                el.click();
                return 'sidebar:' + (el.getAttribute('aria-label') || el.getAttribute('data-testid') || selectors[i]);
            }
            return null;
        })();
        """
        let result = await runJS(js)
        if let str = result as? String, !str.isEmpty, !(result is NSNull) {
            print("[Browser] Opened sidebar: \(str)")
            return true
        }
        return false
    }

    // MARK: - Proactive billing menu navigator
    //
    // After the account dropdown / sidebar is open, look for billing-related
    // menu items ("Settings", "My Plan", "Billing", etc.) and click them.

    @discardableResult
    func tryClickBillingFromMenu() async -> Bool {
        let js = """
        (function() {
            // Priority: most directly billing-related first
            var keywords = [
                'my plan', 'billing', 'subscription', 'payments', 'plan & billing',
                'billing & payments', 'upgrade', 'membership', 'settings'
            ];
            // Look in dropdown/menu overlays first, then anywhere
            var containers = [
                '[role="menu"]', '[role="dialog"]', '[role="listbox"]',
                '[data-radix-popper-content-wrapper]', '[data-headlessui-state]',
                '.dropdown', '[class*="dropdown"]', '[class*="popover"]',
                '[class*="menu"]', 'nav', 'aside'
            ];
            function tryIn(scope) {
                var candidates = scope.querySelectorAll('a, button, [role="menuitem"], [role="option"], li');
                for (var k = 0; k < keywords.length; k++) {
                    for (var i = 0; i < candidates.length; i++) {
                        var el = candidates[i];
                        var rect = el.getBoundingClientRect();
                        if (rect.width === 0 || rect.height === 0) continue;
                        var text = (el.innerText || el.getAttribute('aria-label') || '').trim().toLowerCase();
                        if (text.indexOf(keywords[k]) !== -1) {
                            el.scrollIntoView({block:'center'});
                            el.dispatchEvent(new MouseEvent('mousedown', {bubbles:true}));
                            el.dispatchEvent(new MouseEvent('mouseup', {bubbles:true}));
                            el.click();
                            return 'billing-menu:' + text.slice(0, 40);
                        }
                    }
                }
                return null;
            }
            for (var c = 0; c < containers.length; c++) {
                var scope = document.querySelector(containers[c]);
                if (!scope) continue;
                var result = tryIn(scope);
                if (result) return result;
            }
            return null;
        })();
        """
        let result = await runJS(js)
        if let str = result as? String, !str.isEmpty, !(result is NSNull) {
            print("[Browser] Billing menu clicked: \(str)")
            return true
        }
        return false
    }

    // MARK: - Proactive "Manage subscription" clicker
    //
    // When we are on a settings/account page but have NO price yet, proactively
    // search for "Manage subscription" type buttons and click them to open the
    // payment portal (usually Stripe) where the actual charge amount is shown.
    // This runs BEFORE Claude is asked, so it bypasses de-dup entirely.

    @discardableResult
    func tryClickManageSubscription() async -> Bool {
        // Exact-word list with priority: longer/more-specific first so we don't
        // accidentally click a short "manage" button inside a nav that leads nowhere.
        let js = """
        (function() {
            // PRIORITY 1 — explicit billing-portal phrases (usually go to Stripe)
            var priority1 = [
                'manage subscription', 'manage your subscription',
                'manage billing', 'manage your billing',
                'billing portal', 'view billing', 'billing settings',
                'subscription settings', 'manage payment', 'payment settings',
                'billing & payments', 'update payment'
            ];
            // PRIORITY 2 — plan-management phrases (usually open pricing comparison)
            var priority2 = [
                'change plan', 'change your plan', 'see all plans', 'see plans',
                'view plans', 'view all plans', 'compare plans', 'manage plan',
                'manage your plan', 'view plan', 'update plan', 'switch plan'
            ];
            // PRIORITY 3 — bare "manage" button (ChatGPT uses this next to plan name)
            var priority3 = ['manage', 'upgrade'];

            function findAndClick(keywords, exact) {
                var candidates = document.querySelectorAll(
                    'button, a, [role="button"], [role="link"], [role="menuitem"]'
                );
                for (var i = 0; i < candidates.length; i++) {
                    var el = candidates[i];
                    var r = el.getBoundingClientRect();
                    if (r.width === 0 || r.height === 0) continue;
                    if (el.disabled || el.getAttribute('aria-disabled') === 'true') continue;
                    var text = (el.innerText || el.getAttribute('aria-label') || el.title || '').trim().toLowerCase();
                    if (text.length === 0 || text.length > 60) continue;
                    for (var k = 0; k < keywords.length; k++) {
                        var kw = keywords[k];
                        var match = exact ? (text === kw || text === kw + ' ▼') : (text.indexOf(kw) !== -1);
                        if (match) {
                            el.scrollIntoView({block:'center'});
                            ['mousedown','mouseup'].forEach(function(t) {
                                el.dispatchEvent(new MouseEvent(t,{bubbles:true,cancelable:true}));
                            });
                            el.click();
                            return 'clicked[' + kw + ']:' + text.slice(0,50);
                        }
                    }
                }
                return null;
            }
            return findAndClick(priority1, false)
                || findAndClick(priority2, false)
                || findAndClick(priority3, true);
        })();
        """
        let result = await runJS(js)
        if let str = result as? String, !str.isEmpty, !(result is NSNull) {
            print("[Browser] Manage-subscription click: \(str)")
            return true
        }
        return false
    }

    // MARK: - Proactive "Change Plan" from dropdown
    //
    // After clicking "Manage", a dropdown menu opens with options like
    // "Change plan", "See all plans", "Compare plans". This clicks that item.

    @discardableResult
    func tryClickChangePlanFromDropdown() async -> Bool {
        let js = """
        (function() {
            var keywords = [
                'change plan', 'change your plan', 'see all plans', 'see plans',
                'view plans', 'view all plans', 'compare plans', 'all plans',
                'show plans', 'switch plan'
            ];
            // Prefer elements inside a dropdown/menu container
            var containers = document.querySelectorAll(
                '[role="menu"], [role="listbox"], [role="dialog"], .dropdown, [class*="dropdown"], [class*="menu"], [class*="popover"]'
            );
            function scan(root) {
                var els = root.querySelectorAll('button, a, [role="button"], [role="menuitem"], [role="option"], li, div');
                for (var i = 0; i < els.length; i++) {
                    var el = els[i];
                    var r = el.getBoundingClientRect();
                    if (r.width === 0 || r.height === 0) continue;
                    var text = (el.innerText || el.getAttribute('aria-label') || '').trim().toLowerCase();
                    if (text.length === 0 || text.length > 50) continue;
                    for (var k = 0; k < keywords.length; k++) {
                        if (text.indexOf(keywords[k]) !== -1) {
                            el.scrollIntoView({block:'center'});
                            ['mousedown','mouseup'].forEach(function(t) {
                                el.dispatchEvent(new MouseEvent(t,{bubbles:true,cancelable:true}));
                            });
                            el.click();
                            return 'clicked[' + keywords[k] + ']:' + text.slice(0,50);
                        }
                    }
                }
                return null;
            }
            for (var i = 0; i < containers.length; i++) {
                var hit = scan(containers[i]);
                if (hit) return hit;
            }
            // Fallback: scan whole document
            return scan(document.body);
        })();
        """
        let result = await runJS(js)
        if let str = result as? String, !str.isEmpty, !(result is NSNull) {
            print("[Browser] Change-plan click: \(str)")
            return true
        }
        return false
    }

    // MARK: - Extract price from "Choose your plan" comparison page
    //
    // On pricing comparison pages, the user's CURRENT plan is the card with the
    // disabled/greyed-out button. This function finds that card and extracts its price.

    func extractCurrentPlanFromComparisonPage() async -> (plan: String?, price: String?) {
        let js = #"""
        (function() {
            // Find all plan cards — look for elements containing a price pattern
            var pricePattern = /[A-Z]{0,3}\s*[$€£¥₹]\s*\d[\d,.]*\s*(?:\/|per|USD|EUR|GBP)?/i;
            var buttons = document.querySelectorAll('button, a, [role="button"]');
            var candidates = [];

            for (var i = 0; i < buttons.length; i++) {
                var btn = buttons[i];
                var r = btn.getBoundingClientRect();
                if (r.width === 0 || r.height === 0) continue;
                var text = (btn.innerText || btn.getAttribute('aria-label') || '').trim().toLowerCase();
                if (text.length === 0 || text.length > 60) continue;

                // Heuristic for "current plan" marker:
                var isDisabled = btn.disabled || btn.getAttribute('aria-disabled') === 'true';
                var looksDisabled = false;
                try {
                    var cs = window.getComputedStyle(btn);
                    var op = parseFloat(cs.opacity || '1');
                    var pe = cs.pointerEvents;
                    if (op < 0.7 || pe === 'none') looksDisabled = true;
                } catch(e) {}
                var saysCurrent = /current plan|your plan|current$|active plan/.test(text);

                if (isDisabled || looksDisabled || saysCurrent) {
                    // Walk up to find the enclosing card
                    var card = btn;
                    for (var step = 0; step < 8 && card && card.parentElement; step++) {
                        card = card.parentElement;
                        var cardText = (card.innerText || '').trim();
                        if (pricePattern.test(cardText) && cardText.length < 800) {
                            var m = cardText.match(pricePattern);
                            // Extract plan name — usually the first line/heading in the card
                            var lines = cardText.split('\n').map(function(s){return s.trim();}).filter(Boolean);
                            var planName = lines[0] || '';
                            // Skip if first line is just the price
                            if (pricePattern.test(planName) && lines.length > 1) planName = lines[1];
                            candidates.push({
                                plan: planName.slice(0, 40),
                                price: m[0].trim(),
                                buttonText: text,
                                reason: isDisabled ? 'disabled-attr' : (looksDisabled ? 'greyed-style' : 'says-current')
                            });
                            break;
                        }
                    }
                }
            }
            return JSON.stringify(candidates);
        })();
        """#
        let result = await runJS(js)
        guard let jsonStr = result as? String,
              let data = jsonStr.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: String]],
              let first = arr.first else {
            return (nil, nil)
        }
        print("[Browser] Current plan detected: \(first)")
        return (first["plan"], first["price"])
    }

    // MARK: - Proactive account menu opener
    //
    // Three-phase search — no dangerous generic selectors that could click "Sign In":
    //   Phase 1: Explicit aria-label / data-testid patterns (most reliable, anywhere)
    //   Phase 2: Class-name patterns, header area only (top 20% of screen)
    //   Phase 3: Bottom-of-sidebar patterns (ChatGPT, Slack, etc. put account at bottom)

    @discardableResult
    func tryClickAccountMenu() async -> Bool {
        let js = """
        (function() {
            var h = window.innerHeight;

            function dispatchClick(el) {
                el.scrollIntoView({block:'nearest'});
                el.dispatchEvent(new MouseEvent('mousedown', {bubbles:true, cancelable:true}));
                el.dispatchEvent(new MouseEvent('mouseup',   {bubbles:true, cancelable:true}));
                el.click();
            }

            function trySelectors(selectors, areaTest) {
                for (var i = 0; i < selectors.length; i++) {
                    try {
                        var els = document.querySelectorAll(selectors[i]);
                        for (var j = 0; j < els.length; j++) {
                            var el = els[j];
                            var rect = el.getBoundingClientRect();
                            if (rect.width === 0 || rect.height === 0) continue;
                            if (!areaTest(rect)) continue;
                            dispatchClick(el);
                            return 'P' + selectors[i];
                        }
                    } catch(e) {}
                }
                return null;
            }

            // ── Phase 1: Explicit semantic labels (any vertical position) ──────
            var phase1 = [
                '[aria-label*="account" i]',
                '[aria-label*="my profile" i]',
                '[aria-label*="user menu" i]',
                '[aria-label*="open user" i]',
                '[aria-label*="open account" i]',
                '[aria-label*="personal menu" i]',
                '[aria-label*="your profile" i]',
                '[data-testid*="avatar"]',
                '[data-testid*="user-menu"]',
                '[data-testid*="account-menu"]',
                '[data-testid*="user-button"]',
                '[data-testid*="profile-button"]',
                '[data-testid*="nav-user"]',
            ];
            var r = trySelectors(phase1, function(rect) {
                return rect.top >= 0 && rect.top < h;   // anywhere visible
            });
            if (r) return r;

            // ── Phase 2: Class-name patterns, header zone only (top 20%) ───────
            // NOTE: Intentionally omit 'header button:last-of-type' etc — too risky
            var phase2 = [
                '[class*="UserMenu"]', '[class*="user-menu"]', '[class*="userMenu"]',
                '[class*="AccountMenu"]', '[class*="ProfileMenu"]',
                '[class*="AvatarButton"]', '[class*="avatar-button"]',
                '[class*="NavUser"]', '[class*="UserAvatar"]', '[class*="user-avatar"]',
                '[class*="profilePic"]', '[class*="profile-pic"]',
                '[class*="hamburger"]', '[class*="Hamburger"]',
                '[class*="sidebar-toggle"]', '[class*="NavToggle"]',
            ];
            r = trySelectors(phase2, function(rect) {
                return rect.top >= 0 && rect.top < h * 0.20;   // header zone only
            });
            if (r) return r;

            // ── Phase 3: Bottom-of-sidebar account buttons ───────────────────
            // Services like ChatGPT place the user profile at the BOTTOM of the
            // sidebar nav, not in the header. Look for clickable elements in the
            // bottom 25% that contain user-like text or look like account links.
            var bottomCandidates = [];
            var allClickable = document.querySelectorAll('nav a, nav button, aside a, aside button, [role="navigation"] a, [role="navigation"] button');
            for (var i = 0; i < allClickable.length; i++) {
                var el = allClickable[i];
                var rect = el.getBoundingClientRect();
                if (rect.width === 0 || rect.height === 0) continue;
                if (rect.top < h * 0.70 || rect.top > h) continue;   // bottom 30%
                var text = (el.innerText || el.getAttribute('aria-label') || '').trim();
                // Must have some text content (not a blank icon button)
                if (text.length > 0 && text.length < 80) {
                    bottomCandidates.push({ el: el, text: text, top: rect.top });
                }
            }
            // Click the bottommost element (most likely to be the account button)
            if (bottomCandidates.length > 0) {
                bottomCandidates.sort(function(a, b) { return b.top - a.top; });
                dispatchClick(bottomCandidates[0].el);
                return 'bottom-nav:' + bottomCandidates[0].text.slice(0, 30);
            }

            return null;
        })();
        """
        let result = await runJS(js)
        if let str = result as? String, !str.isEmpty, !(result is NSNull) {
            print("[Browser] Account menu: \(str)")
            return true
        }
        return false
    }
}

// MARK: - Page data models

struct PageElement {
    let text:     String
    let href:     String
    let selector: String
    let area:     String
}

struct PageSnapshot {
    let text:     String
    let elements: [PageElement]
    let url:      String

    /// Keywords in element text/selector that indicate a navigation toggle —
    /// clicking these from a settings/billing page goes backwards.
    private static let navToggleSignals = [
        "open-sidebar", "close-sidebar", "open_sidebar", "close_sidebar",
        "menu-toggle", "menu_toggle", "sidebar-toggle", "hamburger",
        "open-nav", "close-nav", "navtoggle", "toggle-nav",
        "show-sidebar", "hide-sidebar",
    ]

    func formatted() -> String {
        var out = "PAGE TEXT:\n\(String(text.prefix(1500)))\n"

        if elements.isEmpty { return out }

        // Determine if we are already inside a settings/billing/account page.
        // On these pages we NEVER need sidebar navigation — we need the page content.
        let onSettingsPage = ["settings", "billing", "account", "subscription",
                              "plan", "payment", "manage", "membership",
                              "stripe.com", "portal", "invoice"].contains {
            url.lowercased().contains($0)
        }

        let filteredElements = elements.filter { el in
            let combined = (el.text + el.selector).lowercased()

            // 1. Always strip sidebar toggle buttons (hamburger, open/close sidebar)
            if PageSnapshot.navToggleSignals.contains(where: { combined.contains($0) }) {
                return false
            }

            // 2. On settings/billing pages: also strip sidebar navigation elements
            //    ([BOTTOM-NAV] = account button in sidebar, [MENU] = hamburger-opened nav)
            //    Claude is already on the right page — it must NOT navigate back through
            //    the sidebar. Showing these causes the "open sidebar → close → repeat" loop.
            if onSettingsPage {
                if el.text.hasPrefix("[BOTTOM-NAV]") || el.text.hasPrefix("[MENU]") {
                    return false
                }
                // Also strip plain sidebar navigation links (New chat, Search chats, etc.)
                // that are inside nav/aside — they are irrelevant on a settings page
                if el.area == "bottom-left" && !el.href.contains("settings") &&
                   !el.href.contains("billing") && !el.href.contains("subscription") &&
                   !el.href.contains("plan") && !el.href.contains("manage") {
                    return false
                }
            }

            return true
        }

        out += "\nINTERACTIVE ELEMENTS (use these — do not guess URLs):\n"

        let areas = ["top-right","top-left","top-center","middle-right","middle-left","middle-center","bottom-right","bottom-left","bottom-center",""]
        for area in areas {
            let group = filteredElements.filter { $0.area == area }
            if group.isEmpty { continue }
            if !area.isEmpty { out += "\n  [\(area.uppercased())]:\n" }
            for el in group {
                if !el.href.isEmpty {
                    out += "    • \"\(el.text)\" → \(el.href)\n"
                } else if !el.selector.isEmpty {
                    out += "    • \"\(el.text)\" selector=\(el.selector)\n"
                }
            }
        }
        return out
    }
}

// MARK: - WKNavigationDelegate

extension BrowserController: WKNavigationDelegate {

    nonisolated func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        Task { @MainActor in
            self.isLoading = true
            self.lastError = nil
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        Task { @MainActor in
            self.isLoading  = false
            self.currentURL = webView.url?.absoluteString ?? ""
            self.pageTitle  = webView.title ?? ""
            self.onPageLoaded?()
            NotificationCenter.default.post(name: .browserPageLoaded, object: self)
            print("[Browser] Loaded: \(webView.url?.absoluteString ?? "nil")")
        }
    }

    // Catches initial load failures (DNS, SSL, connection refused, etc.)
    nonisolated func webView(_ webView: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            self.isLoading = false
            let nsError = error as NSError

            // Don't report cancellations (e.g. user navigated away before page loaded)
            if nsError.code == NSURLErrorCancelled { return }

            self.lastError = "Load failed: \(error.localizedDescription)"
            print("[Browser] Provisional load failed: \(error.localizedDescription)")

            // Still fire the loaded notification so the orchestrator doesn't hang
            NotificationCenter.default.post(name: .browserPageLoaded, object: self)
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            self.isLoading = false
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled { return }
            self.lastError = "Navigation failed: \(error.localizedDescription)"
            print("[Browser] Navigation failed: \(error.localizedDescription)")
            NotificationCenter.default.post(name: .browserPageLoaded, object: self)
        }
    }

    // Allow all redirects (many login pages use 302/307 redirects)
    nonisolated func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }

    // Allow all responses (some sites return non-standard status codes)
    nonisolated func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        decisionHandler(.allow)
    }

    // Handle SSL certificate errors (for development/testing — allow all)
    nonisolated func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

// MARK: - WKUIDelegate

extension BrowserController: WKUIDelegate {

    nonisolated func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    nonisolated func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(false)
    }

    // Handle window.open() — login flows (Google/Apple/Facebook OAuth) open a new window.
    // We create a REAL child WKWebView that shares the same data store (cookies) so that
    // after auth completes, the parent webview picks up the session automatically.
    // BrowserView observes `oauthPopup` and presents this webview as a sheet.
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // WKUIDelegate is always called on the main actor — it's safe to touch UI state here.
        // Must return the new webview synchronously — create it now.
        let popup = WKWebView(frame: webView.frame, configuration: configuration)
        popup.customUserAgent = webView.customUserAgent
        popup.allowsBackForwardNavigationGestures = true

        // Wire delegates so we can observe its lifecycle
        popup.uiDelegate         = self
        popup.navigationDelegate = self

        self.oauthPopup = popup
        print("[Browser] OAuth popup opened: \(navigationAction.request.url?.absoluteString ?? "nil")")
        return popup
    }

    // Popup calls window.close() after OAuth completes — dismiss the sheet.
    nonisolated func webViewDidClose(_ webView: WKWebView) {
        Task { @MainActor in
            print("[Browser] OAuth popup closed via window.close()")
            if self.oauthPopup === webView {
                self.oauthPopup = nil
                // After OAuth closes, reload the main webview to pick up the new session
                if let current = self.webView.url {
                    self.webView.load(URLRequest(url: current))
                }
            }
        }
    }
}

private extension String {
    var jsEscaped: String {
        replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'",  with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}
