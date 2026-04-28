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
                // Some heavy sites (Figma, Google) need a moment to flush storage.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    if let url = self.webView.url, url.absoluteString != "about:blank" {
                        // Only reload if the page hasn't already started navigating/redirecting
                        if !self.webView.isLoading {
                            print("🪟 Agent: Main window hasn't moved, forcing reload to pick up session.")
                            self.webView.reload()
                        } else {
                            print("🪟 Agent: Main window is already navigating, skipping manual reload.")
                        }
                    }
                }
            }
        }
    }
    
    @Published var currentURL: String = ""
    @Published var isLoading: Bool = false
    
    private var urlObservation: NSKeyValueObservation?
    private var loadingObservation: NSKeyValueObservation?
    
    private var agentScripts: String = ""
    
    // Shared Process Pool to persist sessions across instances (Matching Android behavior)
    private static let sharedProcessPool = WKProcessPool()
    
    private static let stealthScriptContent = """
    (function() {
        // 1. Hide webdriver
        Object.defineProperty(navigator, 'webdriver', { get: () => false });
        
        // 2. Spoof hardware properties to match iPad identity
        Object.defineProperty(navigator, 'deviceMemory', { get: () => 8 });
        Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8 });
        Object.defineProperty(navigator, 'platform', { get: () => 'MacIntel' }); // iPads on iOS 13+ report MacIntel
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
    
    override init() {
        let config = WKWebViewConfiguration()
        config.processPool = Self.sharedProcessPool
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Ensure browser-wide cookie acceptance
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        let stealthScript = WKUserScript(source: Self.stealthScriptContent, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.removeAllUserScripts()
        config.userContentController.addUserScript(stealthScript)
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        // USE AN IPAD SAFARI IDENTITY. 
        // iPads are the 'Goldilocks' of User-Agents: they are mobile enough for Google, 
        // but desktop enough for Figma/Claude to load their full engines without crashing.
        self.webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1"
        
        super.init()
        
        // Ensure browser-wide cookie acceptance
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        // Observe URL and Loading state via KVO for anchor support (#)
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
        
        // SECURITY BYPASS: Do not inject scripts into Cloudflare/Turnstile frames
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        let isSecurityCheck = urlString.contains("cloudflare") || urlString.contains("challenges.cloudflare.com")
        
        // Prevent script duplication: check if our scripts are already there
        let existingSources = configuration.userContentController.userScripts.map { $0.source }
        if !agentScripts.isEmpty && !existingSources.contains(agentScripts) && !isSecurityCheck {
            let userScript = WKUserScript(source: agentScripts, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(userScript)
        }
        
        // Create the child WebView for OAuth/Popups with a valid frame
        let popup = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        popup.uiDelegate = self
        popup.navigationDelegate = self
        
        // CRITICAL: Popups must inherit the spoofed User-Agent to pass Google security
        popup.customUserAgent = self.webView.customUserAgent
        
        self.popupWebView = popup
        return popup
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            print("🪟 Agent: Popup closed via JS. Cleaning up.")
            
            // Clean up popup references
            webView.stopLoading()
            webView.navigationDelegate = nil
            webView.uiDelegate = nil
            self.popupWebView = nil
            
            // CRITICAL: Session Sync. 
            // We wait 1.5s (up from 0.5s) to allow the site's own background redirection to finish.
            // If we reload too early, we cancel the site's own login logic.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                
                // Only force a reload if the page hasn't moved on its own
                if !self.webView.isLoading && (self.webView.url?.absoluteString.contains("login") == true || self.webView.url?.absoluteString.contains("auth") == true) {
                    print("🪟 Agent: Main window stuck on login page. Forcing sync reload.")
                    self.webView.reload()
                } else {
                    print("🪟 Agent: Main window is navigating or already on app page. Sync complete.")
                }
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let urlString = url.absoluteString
        let isPopup = (webView == popupWebView)
        print("🔗 Agent [\(isPopup ? "Popup" : "Main")]: Navigating to \(urlString)")
        
        // Special case: If the popup is trying to navigate back to the main site after login, 
        // we might want to "capture" that navigation into the main webview.
        if isPopup && (urlString.contains("runwayml.com") || urlString.contains("claude.ai")) && !urlString.contains("auth") {
             print("🎯 Agent: Popup reached main site. Forcing main window update.")
             // Sometimes closing the popup is enough, but let's be safe.
        }
        
        // Handle custom schemes or intent-like behavior (mirroring Android logic)
        if !urlString.hasPrefix("http") && !urlString.hasPrefix("https") && !urlString.hasPrefix("about:") {
            print("📱 Agent: Custom Scheme Detected: \(urlString)")
            // If it's a known product-specific protocol or needs external handling
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    // MARK: - Navigation Logic
    
    @MainActor
    func navigate(to url: String) {
        guard let urlObj = URL(string: url) else { return }
        
        // On new navigation, we should usually clear any zombie popups
        if popupWebView != nil {
            print("🪟 Agent: Clearing popup to navigate main window.")
            popupWebView = nil
        }
        
        webView.load(URLRequest(url: urlObj))
    }
    
    @MainActor
    func waitForLoad(timeout: TimeInterval = 6.0, stability: TimeInterval = 0.8) async {
        let start = Date()
        while topWebView.isLoading && Date().timeIntervalSince(start) < timeout {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        // Final UI Stability Delay for accurate snapshots
        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds (Reduced from 1.5s for responsiveness)
    }
    
    @MainActor
    func extractPageSnapshot() async -> PageSnapshot {
        // Wait for non-zero frame size to ensure elements are visible for coordinate calculation
        var attempts = 0
        while (topWebView.frame.width == 0 || topWebView.frame.height == 0) && attempts < 10 {
            try? await Task.sleep(nanoseconds: 100_000_000)
            attempts += 1
        }
        
        await ensureScripts(on: topWebView)
        
        let result = try? await topWebView.evaluateJavaScript("window.SubzilloAgent.extractSnapshot()")
        
        guard let dict = result as? [String: Any] else {
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
        _ = try? await target.evaluateJavaScript(agentScripts)
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
        
        // Give it a tiny moment to stabilize
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isResetting = false
            completion()
        }
    }
    
    // Kept for explicit manual resets if ever needed
    func clearAllData() {
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date.distantPast) {
            self.webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
    }
}
