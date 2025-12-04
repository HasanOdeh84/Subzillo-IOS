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
import MSAL

class SocialLogins:NSObject, ObservableObject{
    
    static let shared = SocialLogins()
    @Published var socialLoginData  : SocialLoginModel?
    
    private var appleController : ASAuthorizationController?
    
    let googleConfig            = GIDConfiguration.init(clientID: Constants.googleSigninId)
    
    private var application     : MSALPublicClientApplication?
    @Published var account      : MSALAccount?
    private let clientId        = "b6d1a52b-8d3a-4c74-b75f-b8a63be5a684"
    private let scopes          = ["User.Read"]
    
    private override init(){
        do {
            let config = MSALPublicClientApplicationConfig(clientId: clientId)
            // Optionally: set authority if you need a particular tenant/endpoint
            // config.authority = try MSALAADAuthority(url: URL(string: "https://login.microsoftonline.com/common")!)
            application = try MSALPublicClientApplication(configuration: config)
        } catch {
            print("MSAL init error: \(error)")
        }
    }
    
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
    
    //MARK: - Microsoft Sign In -------------
    func signInWithMicrosoft(completion: @escaping (SocialLoginModel?) -> Void) {
        guard let application = application else {
            print("MSAL Application not initialized")
            completion(nil)
            return
        }
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else {
            print("Root VC not found")
            completion(nil)
            return
        }
        let webParams = MSALWebviewParameters(authPresentationViewController: rootVC)
        let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webParams)
        application.acquireToken(with: parameters) { (result, error) in
            if let error = error {
                print("Microsoft login failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let result = result else {
                print("No MSAL result")
                completion(nil)
                return
            }
            let accessToken = result.accessToken
            let account = result.account
            let email = account.username
            self.account = account
            let model = SocialLoginModel(id             : accessToken,
                                         loginType      : .microsoft,
                                         fullName       : nil,
                                         emailAddress   : email)
            
            self.socialLoginData = model
            completion(model)
        }
    }
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
