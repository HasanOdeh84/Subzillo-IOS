//
//  HTMLWebView.swift
//  Subzillo
//
//  Created by Antigravity on 09/02/26.
//

import SwiftUI
import WebKit

struct HTMLWebView: UIViewRepresentable {
    let htmlContent: String
    @Binding var dynamicHeight: CGFloat
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLWebView
        
        init(_ parent: HTMLWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (result, error) in
                if let height = result as? CGFloat {
                    DispatchQueue.main.async {
                        self.parent.dynamicHeight = height
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false // Height is dynamic, no need to scroll inside
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let headerString = """
        <header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>
        <style>
            body { 
                font-family: -apple-system, Helvetica; 
                font-size: 16px; 
                color: #1A1A1A; 
                line-height: 1.5;
                padding: 10px;
                margin: 0;
            }
            h1, h2, h3, h4, h5, h6 {
                color: #000000;
            }
        </style>
        """
        uiView.loadHTMLString(headerString + htmlContent, baseURL: nil)
    }
}

