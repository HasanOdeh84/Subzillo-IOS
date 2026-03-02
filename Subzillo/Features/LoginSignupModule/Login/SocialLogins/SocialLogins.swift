//
//  SocialLogins.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 11/10/25.
//

import Foundation
import GoogleSignIn
import AuthenticationServices
import MSAL

class SocialLogins:NSObject, ObservableObject{
    
    static let shared = SocialLogins()
    @Published var socialLoginData  : SocialLoginModel?
    
    private var appleController : ASAuthorizationController?
    
    let googleConfig            = GIDConfiguration.init(clientID: Constants.googleClientId)
    
    private var application     : MSALPublicClientApplication?
    private var application1    : MSALPublicClientApplication?
    @Published var account      : MSALAccount?
    //    private let clientId        = "b6d1a52b-8d3a-4c74-b75f-b8a63be5a684" //ajay's
    //    private let clientId        = "d81f4f2f-5591-4cae-bcfb-bd219a7d4016" //soniya's
    private let scopes          = ["User.Read"]
    //    @StateObject var viewModel = ProfileViewModel()
    
    private override init(){
        do {
            let config = MSALPublicClientApplicationConfig(clientId: Constants.miscrosoftClientId)
            // Optionally: set authority if you need a particular tenant/endpoint
            // config.authority = try MSALAADAuthority(url: URL(string: "https://login.microsoftonline.com/common")!)
            application = try MSALPublicClientApplication(configuration: config)
            
            //for miscrosoft oauth integration
            let authorityURL = URL(string: "https://login.microsoftonline.com/common")!
            let authority = try MSALAADAuthority(url: authorityURL)
            
            let config1 = MSALPublicClientApplicationConfig(
                clientId    : Constants.miscrosoftClientId,
                //                redirectUri : "msauth.com.krify.Subzillo://auth",
                redirectUri : "msauth.com.subzillo.app://auth",
                authority   : authority
            )
            
            application1 = try MSALPublicClientApplication(configuration: config1)
        } catch {
            print("MSAL init error: \(error)")
        }
    }
    
    //MARK: - Google Sign In -----------
    func signInWithGoogle(completion: @escaping (SocialLoginModel?) -> Void) {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else { return }
        
        //        GIDSignIn.sharedInstance.signOut()
        //        DispatchQueue.moain.asyncAfter(deadline: .now() + 1) {
        let config = GIDConfiguration(clientID: Constants.googleClientId)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC, hint: nil, additionalScopes: nil) { [self] signInResult, error in
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
            
            let name = signInResult?.user.profile?.name
            let email = signInResult?.user.profile?.email ?? ""
            
            if let user = GIDSignIn.sharedInstance.currentUser,
               let imageURL = user.profile?.imageURL(withDimension: 200) {
                
                downloadGoogleProfileImage(from: imageURL) { data in
                    print("Profile Image URL: \(String(describing: imageURL))")
                    
                    let model = SocialLoginModel(id          : idToken,
                                                 loginType   : .google,
                                                 fullName    : name,
                                                 emailAddress: email,
                                                 profileImage: data)
                    
                    self.socialLoginData = model
                    DispatchQueue.main.async {
                        completion(model)
                    }
                }
            } else {
                let model = SocialLoginModel(id          : idToken,
                                             loginType   : .google,
                                             fullName    : name,
                                             emailAddress: email,
                                             profileImage: nil)
                
                self.socialLoginData = model
                completion(model)
            }
        }
    }
    
    func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    func downloadGoogleProfileImage(from url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                completion(data)
            } else {
                completion(nil)
            }
        }.resume()
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
        parameters.promptType = .selectAccount
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
    
    func gmailSignInOAuth(
        presentingVC: UIViewController,
        completion: @escaping (String?) -> Void
    ) {
        
        GIDSignIn.sharedInstance.signOut()
        
        let config = GIDConfiguration(
            clientID: Constants.googleClientId,
            serverClientID: Constants.webClientId
        )
        GIDSignIn.sharedInstance.configuration = config
        let scopes = [
            "https://www.googleapis.com/auth/gmail.readonly"
        ]
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingVC,
            hint: nil,
            additionalScopes: scopes
        ) { result, error in
            if let error = error {
                print("Google Sign-In error:", error.localizedDescription)
                completion(nil)
                return
            }
            guard let result = result else {
                completion(nil)
                return
            }
            let serverAuthCode = result.serverAuthCode
            completion(serverAuthCode)
        }
    }
    
    func microsoftSignInOAuth(
        presentingVC: UIViewController,
        completion: @escaping (String?) -> Void
    ) {
        guard let application = application else {
            print("MSAL Application not initialized")
            completion(nil)
            return
        }
        let emailScopes = [
            "Mail.Read",
            "User.Read",
        ]
        let webParams = MSALWebviewParameters(authPresentationViewController: presentingVC)
        let parameters = MSALInteractiveTokenParameters(scopes: emailScopes, webviewParameters: webParams)
        parameters.promptType = .consent
        application.acquireToken(with: parameters) { (result, error) in
            if let error = error as NSError? {
                print("Microsoft OAuth error: \(error.localizedDescription)")
                print("Error Domain: \(error.domain), Code: \(error.code)")
                if let msalError = error.userInfo[MSALErrorDescriptionKey] {
                    print("MSAL Error Description: \(msalError)")
                }
                completion(nil)
                return
            }
            guard let result = result else {
                print("No MSAL result received")
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                self.account = result.account
            }
            let authCode = result.accessToken
            print("Microsoft OAuth Success. Token obtained.")
            completion(authCode)
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

extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
