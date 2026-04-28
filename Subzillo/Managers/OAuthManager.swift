//
//  OAuthManager.swift
//  Subzillo
//
//  Created by Antigravity on 22/01/26.
//

import AuthenticationServices
import UIKit

class OAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = OAuthManager()
    
    private var session: ASWebAuthenticationSession?
    
    func startOAuth(url: URL, callbackScheme: String, completion: @escaping (URL?, Error?) -> Void) {
        session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { callbackURL, error in
            completion(callbackURL, error)
        }
        
        session?.presentationContextProvider = self
        session?.prefersEphemeralWebBrowserSession = false
        session?.start()
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
