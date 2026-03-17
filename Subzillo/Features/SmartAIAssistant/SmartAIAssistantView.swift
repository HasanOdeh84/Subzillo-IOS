//
//  SmartAIAssistant.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 04/03/26.
//

import SwiftUI
import WebKit

struct SmartAIAssistantView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @State private var isLoading                = true
    @State private var loadError                = false
    @State private var refreshID                = UUID()
    
    //MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                if let url = getChatbotURL() {
                    ChatbotWebView(url: url, isLoading: $isLoading, loadError: $loadError)
                        .id(refreshID)
                        .ignoresSafeArea(.container, edges: .bottom)
                        .padding(.top, 40)
                    //                        .padding(.bottom, 10)
                } else {
                    Text("Invalid URL")
                        .foregroundColor(.red)
                }
            }
            //            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: {
                dismiss()
            }) {
                Image("back_gray")
                    .frame(width: 30, height: 30)
            }
            .padding(.top, 60)
            .padding(.leading, 24)
            .zIndex(1)
            
            if loadError {
                errorOverlay
            }
            
            if isLoading{
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.neutralBg100)
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }
    //        .onChange(of: isLoading) { newValue in
    //            if newValue {
    //                LoaderManager.shared.showLoader()
    //            } else {
    //                LoaderManager.shared.hideLoader()
    //            }
    //        }
    
    private var errorOverlay: some View {
        ZStack {
            Color.neutralBg100.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.secondaryNavyBlue400)
                
                VStack(spacing: 8) {
                    Text("Unable to Load Chatbot")
                        .font(.appBold(20))
                        .foregroundColor(.grayClr)
                    
                    Text("Something went wrong while loading the chatbot. Please try again.")
                        .font(.appRegular(16))
                        .foregroundColor(.grayClr)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Button(action: {
                    loadError = false
                    isLoading = true
                    refreshID = UUID()
                }) {
                    Text("Retry")
                        .font(.appBold(16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.secondaryNavyBlue800)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    func getChatbotURL() -> URL? {
        var components = URLComponents(string: Constants.chatbotUrl)
        components?.queryItems = [
            URLQueryItem(name: "authentication", value: chatBotAuthKey),
            URLQueryItem(name: "currency", value: commonApiVM.userInfoResponse?.preferredCurrency ?? ""),
            URLQueryItem(name: "userId", value: Constants.getUserId()),
            URLQueryItem(name: "profilePicUrl", value: commonApiVM.userInfoResponse?.profileImage ?? ""),
        ]
        return components?.url
    }
}


struct ChatbotWebView: UIViewRepresentable {
    
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadError: Bool
    
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
        Coordinator(self)
    }
}

class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    var parent: ChatbotWebView
    private let allowedDomain = Constants.chatbotUrl
    
    init(_ parent: ChatbotWebView) {
        self.parent = parent
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        parent.isLoading = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        parent.isLoading = false
        parent.loadError = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        parent.isLoading = false
        parent.loadError = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        parent.isLoading = false
        parent.loadError = true
    }
    
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
