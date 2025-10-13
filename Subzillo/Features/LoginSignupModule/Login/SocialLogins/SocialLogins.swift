//
//  SocialLogins.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 11/10/25.
//

import Foundation
import GoogleSignIn
import AuthenticationServices

class SocialLogins:NSObject, ObservableObject{
    
    static let shared = SocialLogins()
    private override init(){}
    @Published var socialLoginData  : SocialLoginModel?
    @Published var isSocialLoggedIn : Bool?
    
    let googleConfig = GIDConfiguration.init(clientID: Constants.googleSigninId)
    
    //MARK: Google login -----------
    func signInWithGoogle() {
        // 1️⃣ Get root view controller (required for presenting Google sign-in screen)
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else { return }
        
        // 2️⃣ Start Google sign-in process
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            if let error = error {
                print("Google Sign-in failed:", error.localizedDescription)
                return
            }
            
            guard let idToken = signInResult?.user.idToken?.tokenString else {
                print("Failed to get ID Token")
                return
            }
            self.isSocialLoggedIn = true
            self.socialLoginData =  SocialLoginModel(id               : idToken,
                                                     loginType        : .google,
                                                     fullName         : signInResult?.user.profile?.name,
                                                     emailAddress     : signInResult?.user.profile?.email ?? "",
                                                     mobileNumber     : "")
        }
    }
    
    //MARK: Apple login -------------------
    func signInWithGoogleApple(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let req = appleIDProvider.createRequest()
        req.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [req])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

// MARK: - Apple Sign In Delegate methods
extension SocialLogins:ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //        Log("error")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            self.isSocialLoggedIn = true
            self.socialLoginData =  SocialLoginModel(id               : appleIDCredential.user,
                                                     loginType        : .apple,
                                                     fullName         : appleIDCredential.fullName?.givenName,
                                                     emailAddress     : appleIDCredential.email,
                                                     mobileNumber     : "")
        }
    }
}
