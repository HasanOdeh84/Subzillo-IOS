//
//  SocialLogins.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 11/10/25.
//

import Foundation
import GoogleSignIn
import AuthenticationServices
import SwiftUICore

class SocialLogins:NSObject, ObservableObject{
    
    static let shared = SocialLogins()
    private override init(){}
    @Published var socialLoginData  : SocialLoginModel?
    private var appleController: ASAuthorizationController?
    
    let googleConfig = GIDConfiguration.init(clientID: Constants.googleSigninId)
    
    //MARK: - Google Sign In -----------
    func signInWithGoogle(completion: @escaping (SocialLoginModel?) -> Void) {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            if let error = error {
                print("Google Sign-in failed:", error.localizedDescription)
                completion(nil)
                return
            }
            guard let idToken = signInResult?.user.idToken?.tokenString else {
                print("Failed to get ID Token")
                completion(nil)
                return
            }
            self.socialLoginData =  SocialLoginModel(id               : idToken,
                                                     loginType        : .google,
                                                     fullName         : signInResult?.user.profile?.name,
                                                     emailAddress     : signInResult?.user.profile?.email ?? "")
            completion(self.socialLoginData)
        }
    }
    
    // MARK: - Apple Sign In ------------
    func signInWithApple(completion: @escaping (SocialLoginModel?) -> Void) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.appleSignInCompletion = completion
        self.appleController = controller
        controller.performRequests()
    }
    
    // Temporary callback
    private var appleSignInCompletion: ((SocialLoginModel?) -> Void)?
}

// MARK: - Apple Sign In Delegate methods
extension SocialLogins:ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign-in failed: \(error)")
        appleSignInCompletion?(nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            self.socialLoginData =  SocialLoginModel(id               : appleIDCredential.user,
                                                     loginType        : .apple,
                                                     fullName         : appleIDCredential.fullName?.givenName,
                                                     emailAddress     : appleIDCredential.email)
            self.appleSignInCompletion?(self.socialLoginData)
        }
    }
}
