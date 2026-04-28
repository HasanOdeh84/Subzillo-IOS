import SwiftUI
import WebKit

struct AgentWebViewRepresentable: UIViewRepresentable {
    let controller: AgentBrowserController
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = controller.webView
        webView.navigationDelegate = controller
        webView.uiDelegate = controller
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }
    
    class Coordinator: NSObject {
        let controller: AgentBrowserController
        
        init(controller: AgentBrowserController) {
            self.controller = controller
        }
    }
}
