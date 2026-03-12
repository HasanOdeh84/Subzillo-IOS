//
//  SmartAIAssistant.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 04/03/26.
//

import SwiftUI
import WebKit

//struct SmartAIAssistantView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header
//            HStack {
//                Text("Smart AI Assistant")
//                    .font(.appRegular(24))
//                    .foregroundColor(.neutralMain700)
//                Spacer()
//            }
//            .padding(.top, 60)
//            .padding(.horizontal, 20)
//            .padding(.bottom, 24)
//            
//            // WebView
//            if let url = URL(string: Constants.chatbotUrl) {
//                WebView(url: url)
//                    .edgesIgnoringSafeArea(.bottom)
//                    .padding(.bottom,90)
//                    .background(Color.clear)
//            } else {
//                Text("Invalid URL")
//            }
//        }
//        .background(Color.neutralBg100)
//        .ignoresSafeArea(edges: .top)
//    }
//}

struct SmartAIAssistantView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Smart AI Assistant")
                    .font(.appRegular(24))
                    .foregroundColor(.neutralMain700)
                
                Spacer()
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            if let url = URL(string: Constants.chatbotUrl) {
                ChatbotWebView(url: url)
                    .ignoresSafeArea(.container, edges: .bottom)
                    .padding(.bottom,90)
            } else {
                Text("Invalid URL")
                    .foregroundColor(.red)
            }
        }
        .background(Color.neutralBg100)
        .ignoresSafeArea(edges: .top)
    }
}

struct ChatbotWebView: UIViewRepresentable {
    
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        webView.scrollView.bounces = false

        // Disable zoom
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
        
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    private let allowedDomain = Constants.chatbotUrl
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        // Allow the chatbot URL and internal navigation
        if url.absoluteString.hasPrefix(allowedDomain) || url.scheme == "about" {
            decisionHandler(.allow)
        } else if navigationAction.navigationType == .linkActivated {
            // Open external links in Safari
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    // Handle microphone/camera permission requests from the web page (iOS 15+)
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
}

#Preview {
    SmartAIAssistantView()
}
