import Foundation
import WebKit
import Combine

@MainActor
class AgentBrowserController: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    let webView: WKWebView
    @Published var popupWebView: WKWebView? {
        didSet {
            if oldValue != nil && popupWebView == nil && !isResetting {
                print("🪟 Agent: Popup dismissed. Syncing session...")
                
                // CRITICAL: Give cookies/storage time to settle across processes.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let url = self.webView.url, url.absoluteString != "about:blank" {
                        print("🪟 Agent: Syncing session. Fresh load of main window.")
                        self.webView.load(URLRequest(url: url))
                    }
                }
            }
        }
    }
    
    @Published var currentURL: String = ""
    @Published var isLoading: Bool = false
    
    private var urlObservation: NSKeyValueObservation?
    private var loadingObservation: NSKeyValueObservation?
    private var popupUrlObservation: NSKeyValueObservation?
    
    private var agentScripts: String = ""
    
    // Shared Process Pool to persist sessions across instances (Matching Android behavior)
    private static let sharedProcessPool = WKProcessPool()
    
    private static let stealthScriptContent = """
    (function() {
        // 1. Hide webdriver
        Object.defineProperty(navigator, 'webdriver', { get: () => false });
    
        // 2. Spoof hardware properties to match iPhone identity
        Object.defineProperty(navigator, 'deviceMemory', { get: () => 8 });
        Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8 });
        Object.defineProperty(navigator, 'platform', { get: () => 'iPhone' });
        Object.defineProperty(navigator, 'vendor', { get: () => 'Apple Computer, Inc.' });
        Object.defineProperty(navigator, 'languages', { get: () => ['en-US', 'en'] });
        Object.defineProperty(navigator, 'maxTouchPoints', { get: () => 5 });
        
        // 3. Remove window.chrome (It's a red flag for Safari/iPhone)
        delete window.chrome;
        
        // 4. Spoof Plugins (Real browsers have them, WKWebView doesn't)
        // Safari on iOS usually has no plugins, but we can leave this or keep it empty
        Object.defineProperty(navigator, 'plugins', { get: () => [] });
    
        // 5. Connection properties
        if (!navigator.connection) {
            Object.defineProperty(navigator, 'connection', {
                get: () => ({
                    effectiveType: '4g',
                    rtt: 50,
                    downlink: 10,
                    saveData: false
                })
            });
        }
        
        // 6. UserAgentData (NOT present in Safari/iPhone, so we MUST NOT define it)
        delete navigator.userAgentData;
        
        // 7. Extra markers
        delete navigator.pdfViewerEnabled;
        
        // 8. Screen and Window properties
        // We do NOT spoof these on iPhone identity to avoid detection
        
        // 9. Hide automation markers
        delete window.cdc_adoQbh7w41ba9e_Array;
        delete window.cdc_adoQbh7w41ba9e_Promise;
        delete window.cdc_adoQbh7w41ba9e_Symbol;
    })();
    """
    
    private var isResetting = false
    private var isExtracting = false
    
    override init() {
        let config = WKWebViewConfiguration()
        config.processPool = Self.sharedProcessPool
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences.javaScriptEnabled = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Force Mobile View - This is critical for agents to reduce DOM size and complexity
        if #available(iOS 13.0, *) {
            config.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        
        // Ensure browser-wide cookie acceptance
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        let stealthScript = WKUserScript(source: Self.stealthScriptContent, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController.removeAllUserScripts()
        config.userContentController.addUserScript(stealthScript)
        
        let screenBounds = UIScreen.main.bounds
        self.webView = WKWebView(frame: screenBounds, configuration: config)
        
        // Modern Safari user agent
        self.webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1"
        
        super.init()
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        self.urlObservation = self.webView.observe(\.url, options: [.new]) { [weak self] _, change in
            DispatchQueue.main.async {
                self?.currentURL = change.newValue??.absoluteString ?? ""
            }
        }
        self.loadingObservation = self.webView.observe(\.isLoading, options: [.new]) { [weak self] _, change in
            DispatchQueue.main.async {
                self?.isLoading = change.newValue ?? false
            }
        }
        
        loadAgentScripts()
    }
    
    /// Always returns the top-most active WebView (Main or Popup)
    private var topWebView: WKWebView {
        return popupWebView ?? webView
    }
    
    // MARK: - WKUIDelegate (Multi-Window Hijacking)
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // CRITICAL: We MUST use the provided 'configuration' object or the app will crash.
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        
        // SECURITY BYPASS: Do not inject scripts into Cloudflare/Turnstile frames
        let _ = urlString.contains("cloudflare") || urlString.contains("challenges.cloudflare.com")
        
        // Create the child WebView for OAuth/Popups with a valid frame
        let popup = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        popup.uiDelegate = self
        popup.navigationDelegate = self
        
        // GOOGLE BYPASS: Google often blocks 'Mobile' WebViews. 
        // Using a 'Desktop' Safari UA inside the popup is the most reliable way to pass Google's security.
        if urlString.contains("accounts.google.com") {
            print("🎯 Agent: Google Login detected. Using Desktop Safari identity for popup.")
            popup.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        } else {
            popup.customUserAgent = self.webView.customUserAgent
        }
        
        // Watch for redirects inside the popup (OAuth success triggers)
        popupUrlObservation = popup.observe(\.url, options: [.new]) { [weak self] _, _ in
            self?.handlePopupURLChange(popup)
        }
        
        self.popupWebView = popup
        
        return popup
    }
    
    private func handlePopupURLChange(_ popup: WKWebView) {
        guard let url = popup.url?.absoluteString else { return }
        
        // If the popup redirects back to the main app or a callback URL, it's done
        let isSuccess = url.contains("google-sign-in-redirect") || 
        url.contains("oauth2/callback") || 
        url.contains("auth/callback") ||
        url.contains("claude.ai/login") ||
        url.contains("success") ||
        url.contains("post_login_redirect") ||
        url.contains("authorized") ||
        (url.contains("shortwave.com") && !url.contains("auth")) ||
        (url.contains("clickup.com") && !url.contains("login")) ||
        (!url.contains("auth") && !url.contains("login") && url.contains("com")) // Heuristic for redirecting to main site
        
        if (isSuccess) {
            print("🪟 Agent: OAuth Success detected in popup URL: \(url). Closing and syncing.")
            
            // POKE COOKIES: Force the main data store to acknowledge the new cookies
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    self?.closePopup()
                }
            }
        }
    }
    
    private func closePopup() {
        popupUrlObservation?.invalidate()
        popupUrlObservation = nil
        popupWebView?.stopLoading()
        popupWebView?.navigationDelegate = nil
        popupWebView?.uiDelegate = nil
        popupWebView = nil
        print("🪟 Agent: Popup Closed.")
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            print("🪟 Agent: OAuth popup closed via window.close(). Syncing session...")
            
            // Clean up popup references
            webView.stopLoading()
            webView.navigationDelegate = nil
            webView.uiDelegate = nil
            self.popupWebView = nil
            
            // CRITICAL: Session Sync. 
            // Reload the main webview immediately to pick up the new session from the shared cookie store.
            if let current = self.webView.url, current.absoluteString != "about:blank" {
                print("🪟 Agent: Reloading main window to pick up session.")
                self.webView.load(URLRequest(url: current))
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.isLoading = true
        self.currentURL = webView.url?.absoluteString ?? ""
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let isPopup = (webView == popupWebView)
        print("✅ Agent [\(isPopup ? "Popup" : "Main")]: Finished loading \(webView.url?.absoluteString ?? "unknown")")
        self.isLoading = false
        self.currentURL = webView.url?.absoluteString ?? ""
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let isPopup = (webView == popupWebView)
        print("❌ Agent [\(isPopup ? "Popup" : "Main")]: Navigation failed: \(error.localizedDescription)")
        self.isLoading = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let isPopup = (webView == popupWebView)
        print("❌ Agent [\(isPopup ? "Popup" : "Main")]: Provisional navigation failed: \(error.localizedDescription)")
        self.isLoading = false
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("💥 Agent: Web Content Process Terminated (Crash). Performing native recovery...")
        // Recovery: Use native reload. evaluateJavaScript will fail if the process is dead.
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, didBecomeUnresponsive webViewUnresponsive: WKWebView) {
        print("🧊 Agent: Browser has frozen (unresponsive). Triggering soft recovery...")
        // If it hangs for too long, a reload is the only way to restart the WebContent process
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, didBecomeResponsive webViewResponsive: WKWebView) {
        print("🔥 Agent: Browser has recovered and is now responsive.")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let urlString = url.absoluteString.lowercased()
        let isPopup = (webView == popupWebView)
        print("🔗 Agent [\(isPopup ? "Popup" : "Main")]: Navigating to \(urlString)")
        
        // BLOCK App Store / External App handoffs (Matches Browser_Automation)
        let blocklist = [
            "itms-apps://", "apps.apple.com", "play.google.com",
            "market://", "intent://", "app-store://", "hotstar-app://",
            "googlegmail://", "ms-outlook://", "mailto:"
        ]
        
        if blocklist.contains(where: { urlString.contains($0) }) {
            // EXPERIMENT: Allow Adobe-specific redirects to test "Frame load interrupted" fix
            if urlString.contains("adobe") || urlString.contains("id1051937863") {
                print("🎯 Agent: EXPERIMENT - Allowing Adobe redirect: \(url.absoluteString)")
                decisionHandler(.allow)
                return
            }
            
            print("🚫 Agent: BLOCKING external app/store redirect to prevent crash: \(url.absoluteString)")
            decisionHandler(.cancel)
            return
        }
        
        if !url.absoluteString.hasPrefix("http") && !url.absoluteString.hasPrefix("https") && !url.absoluteString.hasPrefix("about:") {
            // Safety check for unknown schemes
            if UIApplication.shared.canOpenURL(url) {
                print("⚠️ Agent: Unknown scheme detected. Attempting to open: \(url.absoluteString)")
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            } else {
                print("❌ Agent: Unhandled scheme: \(url.absoluteString). Cancelling to prevent crash.")
                decisionHandler(.cancel)
                return
            }
        }
        
        // Special case: If the popup is trying to navigate back to the main site after login, 
        // we might want to "capture" that navigation into the main webview.
        if isPopup && (urlString.contains("runwayml.com") || urlString.contains("claude.ai") || urlString.contains("shortwave.com") || urlString.contains("clickup.com")) && !urlString.contains("auth") && !urlString.contains("login") {
            print("🎯 Agent: Popup reached main site. Forcing main window update and closing popup.")
            DispatchQueue.main.async { [weak self] in
                self?.closePopup()
            }
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    @MainActor
    func isCaptchaVisible() async -> Bool {
        let url = topWebView.url?.absoluteString.lowercased() ?? ""
        let captchaDomains = ["cloudflare", "turnstile", "hcaptcha", "recaptcha", "challenges.cloudflare.com"]
        if captchaDomains.contains(where: { url.contains($0) }) {
            print("🛡️ Agent: Captcha detected via URL: \(url)")
            return true
        }
        
        // Lightweight check for text markers without full snapshot
        let js = """
        (function() {
            var text = document.body ? document.body.innerText.toLowerCase() : "";
            var markers = ["verify you are human", "checking your browser", "cloudflare", "turnstile", "hcaptcha", "security check", "solve the challenge"];
            for (var m of markers) {
                if (text.indexOf(m) !== -1) return true;
            }
            return false;
        })()
        """
        let result = try? await topWebView.evaluateJavaScript(js) as? Bool
        if result == true {
            print("🛡️ Agent: Captcha detected via text markers.")
            return true
        }
        
        return false
    }
    
    // MARK: - Navigation Logic
    
    @MainActor
    func navigate(to url: String) {
        guard let urlObj = URL(string: url) else { return }
        
        // STOP & BREATHE GUARD:
        // Explicitly stop any current navigation to avoid 'Frame load interrupted' (Code 102).
        topWebView.stopLoading()
        
        // On new navigation, we should usually clear any zombie popups
        if popupWebView != nil {
            print("🪟 Agent: Clearing popup to navigate main window.")
            popupWebView = nil
        }
        
        // Tiny async delay to let WebKit process the 'stop' before the new 'load'
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.webView.load(URLRequest(url: urlObj))
        }
    }
    
    @MainActor
    
    func waitForLoad(timeout: TimeInterval = 8.0, stability: TimeInterval = 0.6) async {
        let start = Date()
        
        // 1. Wait for WKWebView.isLoading to turn false
        while topWebView.isLoading && Date().timeIntervalSince(start) < timeout {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        // 2. Wait for document.readyState == 'complete'
        var readyStateAttempts = 0
        while readyStateAttempts < 15 {
            let state = try? await topWebView.evaluateJavaScript("document.readyState") as? String
            if state == "complete" { break }
            try? await Task.sleep(nanoseconds: 200_000_000)
            readyStateAttempts += 1
            
            // Safety: If we are timing out on readyState, the process might be struggling.
            if readyStateAttempts == 10 {
                print("⚠️ Agent: readyState taking too long. Checking responsiveness...")
            }
        }
        
        // 3. Final Settle Delay
        // Heavier sites like Claude/Dropbox need more time to finish internal JS initialization
        // before we inject our extraction scripts, otherwise we cause a "didBecomeUnresponsive" hang.
        try? await Task.sleep(nanoseconds: 600_000_000)
    }
    
    @MainActor
    func extractPageSnapshot() async -> PageSnapshot {
        // SNAPSHOT LOCK: Prevent overlapping heavy JS extractions which freeze the process
        guard !isExtracting else {
            print("⚠️ Agent: Extraction already in progress. Skipping...")
            return PageSnapshot(text: "", elements: [], url: topWebView.url?.absoluteString ?? "", isLoggedIn: false)
        }
        isExtracting = true
        defer { isExtracting = false }
        
        // CRITICAL: Force a cookie sync check before snapshotting.
        // This ensures the AI sees the most up-to-date logged-in state.
        _ = await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { _ in
                continuation.resume()
            }
        }
        
        // Wait for non-zero frame size to ensure elements are visible for coordinate calculation
        var attempts = 0
        while (topWebView.frame.width == 0 || topWebView.frame.height == 0) && attempts < 5 {
            try? await Task.sleep(nanoseconds: 100_000_000)
            attempts += 1
        }
        
        // SPA Loading indicator heuristic check
        let loaderScript = """
        (function() {
            var loaders = document.querySelectorAll('.loader, .spinner, [role="progressbar"], svg[class*="spin"], div[class*="loading"], .cu-loader');
            return loaders.length > 0;
        })();
        """
        var waitCount = 0
        while waitCount < 15 {
            let hasLoader = (try? await topWebView.evaluateJavaScript(loaderScript) as? Bool ?? false) ?? false
            if !hasLoader { break }
            try? await Task.sleep(nanoseconds: 200_000_000)
            waitCount += 1
        }
        
        await ensureScripts(on: topWebView)
        
        // Use a Task with timeout for the heavy snapshot script to avoid hanging the whole app
        let result = await withTaskGroup(of: Any?.self) { group in
            group.addTask {
                return try? await self.topWebView.evaluateJavaScript("window.SubzilloAgent.extractSnapshot()")
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3s timeout
                return nil
            }
            let first = await group.next()
            group.cancelAll()
            return first
        }
        
        guard let dict = result as? [String: Any] else {
            print("⚠️ Agent: Snapshot extraction failed or timed out.")
            return PageSnapshot(text: "", elements: [], url: topWebView.url?.absoluteString ?? "", isLoggedIn: false)
        }
        
        let text = dict["text"] as? String ?? ""
        let url = topWebView.url?.absoluteString ?? ""
        let isLoggedIn = dict["isLoggedIn"] as? Bool ?? false
        
        var elements: [PageElement] = []
        if let elsArray = dict["elements"] as? [[String: Any]] {
            for elDict in elsArray {
                elements.append(PageElement(
                    text: elDict["text"] as? String ?? "",
                    href: elDict["href"] as? String ?? "",
                    selector: elDict["selector"] as? String ?? "",
                    area: "",
                    x: elDict["x"] as? Int,
                    y: elDict["y"] as? Int
                ))
            }
        }
        
        return PageSnapshot(text: text, elements: elements, url: url, isLoggedIn: isLoggedIn)
    }
    
    @MainActor
    func click(selector: String? = nil, text: String? = nil) async -> Bool {
        await ensureScripts(on: topWebView)
        
        let sel = selector ?? "null"
        let txt = text ?? "null"
        let cleanTxt = txt.replacingOccurrences(of: "'", with: "\\'")
        let cleanSel = sel.replacingOccurrences(of: "'", with: "\\'")
        
        let js = "window.SubzilloAgent.click(\(sel == "null" ? "null" : "'\(cleanSel)'"), \(txt == "null" ? "null" : "'\(cleanTxt)'"))"
        let result = try? await topWebView.evaluateJavaScript(js)
        
        if let resultStr = result as? String {
            if resultStr.hasPrefix("NAVIGATE:") {
                let url = resultStr.replacingOccurrences(of: "NAVIGATE:", with: "")
                navigate(to: url)
                return true
            }
            return resultStr.contains("OK")
        }
        return false
    }
    
    @MainActor
    func clickAt(x: Int, y: Int) async -> Bool {
        let js = """
        (function() {
            var el = document.elementFromPoint(\(x), \(y));
            if (!el) return "FAIL";
            el.click();
            return "OK";
        })()
        """
        let result = try? await topWebView.evaluateJavaScript(js)
        return (result as? String)?.contains("OK") ?? false
    }
    
    @MainActor
    func type(selector: String, text: String) async -> Bool {
        await ensureScripts(on: topWebView)
        let js = "window.SubzilloAgent.type('\(selector)', '\(text)')"
        let result = try? await topWebView.evaluateJavaScript(js)
        return (result as? String)?.contains("OK") ?? false
    }
    private func ensureScripts(on target: WKWebView) async {
        // Injection on-demand is much safer for heavy sites (Adobe, Claude, Dropbox)
        // because it doesn't fight with the site's initial loading JS.
        do {
            _ = try await target.evaluateJavaScript(agentScripts)
        } catch {
            print("⚠️ Agent: Script injection failed (this is expected if page is still navigating): \(error.localizedDescription)")
        }
    }
    
    private func loadAgentScripts() {
        if let path = Bundle.main.path(forResource: "AgentScripts", ofType: "js"),
           let content = try? String(contentsOfFile: path) {
            self.agentScripts = content
        } else {
            // Fallback for local development if bundle path fails
            print("⚠️ Agent: Warning: AgentScripts.js not found in bundle. Checking local workspace.")
            let localPath = "Subzillo/Features/AI/Browser/AgentScripts.js"
            if let content = try? String(contentsOfFile: localPath) {
                self.agentScripts = content
            }
        }
    }
    
    @MainActor
    func scroll(y: Int = 400) async {
        _ = try? await topWebView.evaluateJavaScript("window.scrollBy(0, \(y))")
    }
    
    func prepareForNewTask(completion: @escaping () -> Void = {}) {
        self.isResetting = true
        // Close any lingering popups
        if let popup = self.popupWebView {
            popup.stopLoading()
            popup.navigationDelegate = nil
            popup.uiDelegate = nil
            self.popupWebView = nil
        }
        
        // Navigate to blank to stop previous site scripts, but DON'T clear cookies/sessions
        self.webView.load(URLRequest(url: URL(string: "about:blank")!))
        
        // Ensure cookies are flushed before starting the new task
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isResetting = false
                completion()
            }
        }
    }
    
    // Kept for explicit manual resets if ever needed
    func clearAllData() {
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date.distantPast) {
            self.webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
    }
}
