import Foundation
import WebKit
import Combine

@MainActor
class AgentBrowserController: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    let webView: WKWebView
    @Published var popupWebView: WKWebView?
    
    @Published var currentURL: String = ""
    @Published var isLoading: Bool = false
    
    private var urlObservation: NSKeyValueObservation?
    private var loadingObservation: NSKeyValueObservation?
    
    private var agentScripts: String = ""
    
    // Shared Process Pool to persist sessions across instances (Matching Android behavior)
    private static let sharedProcessPool = WKProcessPool()
    
    override init() {
        let config = WKWebViewConfiguration()
        config.processPool = Self.sharedProcessPool
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Ensure browser-wide cookie acceptance
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        let stealthScriptContent = """
        (function() {
            Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
            Object.defineProperty(navigator, 'deviceMemory', { get: () => 8 });
            Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8 });
            // Block detection of Automation frameworks
            delete window.cdc_adoQbh7w41ba9e_Array;
            delete window.cdc_adoQbh7w41ba9e_Promise;
            delete window.cdc_adoQbh7w41ba9e_Symbol;
        })();
        """
        let stealthScript = WKUserScript(source: stealthScriptContent, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(stealthScript)
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        // Use a modern Mobile User Agent (iPhone) for best layout compatibility
        self.webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        super.init()
        
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
        // Create the child WebView for OAuth/Popups
        let popup = WKWebView(frame: webView.frame, configuration: configuration)
        popup.navigationDelegate = self
        popup.uiDelegate = self
        // Use Mobile Chrome ONLY for popups to bypass Google Login blocks
        popup.customUserAgent = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36"
        
        self.popupWebView = popup
        print("🪟 Agent: OAuth Popup Detected and Hijacked.")
        return popup
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            print("🪟 Agent: Popup closed. Returning focus to main window.")
            self.popupWebView = nil
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.isLoading = true
        self.currentURL = webView.url?.absoluteString ?? ""
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.isLoading = false
        self.currentURL = webView.url?.absoluteString ?? ""
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.isLoading = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.isLoading = false
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
    func waitForLoad(timeout: TimeInterval = 6.0, stability: TimeInterval = 1.0) async {
        let start = Date()
        while topWebView.isLoading && Date().timeIntervalSince(start) < timeout {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        try? await Task.sleep(nanoseconds: UInt64(stability * 1_000_000_000))
    }
    
    @MainActor
    func extractPageSnapshot() async -> PageSnapshot {
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
            let directPath = "/Users/ksmacmini-019/Documents/Alekya_Files/GitProjects/subzillo_new_krify/subzillo_ios 4/Subzillo/Features/AI/Browser/AgentScripts.js"
            self.agentScripts = (try? String(contentsOfFile: directPath)) ?? ""
        }
    }
    
    @MainActor
    func scroll(y: Int = 400) async {
        _ = try? await topWebView.evaluateJavaScript("window.scrollBy(0, \(y))")
    }

    func resetSession() {
        self.popupWebView = nil
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date.distantPast) {
            self.webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
    }
}
