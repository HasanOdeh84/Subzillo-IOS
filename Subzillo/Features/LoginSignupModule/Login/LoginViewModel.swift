//
//  LoginViewModel.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import Combine
import SwiftUI
import SwiftUICore

class LoginViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var loginResponse        : LoginResponse?
    @Published var isLoading            : Bool = false
    private let router                  : AppIntentRouter
    private let sessionManager          : SessionManager

    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared) {
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func login(input:checkLoginRequest) {
        isLoading = true
        apiReference.postApi(endPoint: APIEndpoint.checkLogin, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: LoginResponse.self)
            .sink { [unowned self] completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.checkLogin)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            KeychainHelper.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelper.save(response.data?.refreshToken, account: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.userId, key: Constants.userId)
            self.loginResponse = response
//            if response.data?.emailOtpVerified ?? false{
//                //                DispatchQueue.main.async {
//                //                self.router.navigate(to: .home)
//                //                }
//                AppState.shared.login()
//            }else{
//                
//            }
//            DispatchQueue.main.async {
//                self.router.navigate(to: .verifyOtp(emailId: response.data?.email, from: .login, username: response.data?.username))
//            }
            let data = LoginSignupVerifyData(verifyType   : input.loginType,
                                             email        : input.email,
                                             phoneNumber  : input.phoneNumber,
                                             countryCode  : input.countryCode,
                                             userId       : response.data?.userId ?? "",
                                             isNewUser: response.data?.isNewUser ?? false,
                                             isSignupCompleted: response.data?.signupCompleted ?? false)
            self.sessionManager.saveLoginData(data)
            self.router.navigate(to: .verifyOtp(fromLogin: true))
        }
        .store(in: &self.subscriptions)
    }
    
    func socialLogin(loginType:loginType){
        if loginType == .google{
            SocialLogins.shared.signInWithGoogle()
        }else{
            SocialLogins.shared.signInWithGoogleApple()
        }
        let data = SocialLogins.shared.socialLoginData
        if SocialLogins.shared.isSocialLoggedIn ?? false{
            socialLoginApi(input: SocialLoginRequest(socialId       : data?.id ?? "",
                                                     authProvider   : data?.loginType,
                                                     email          : data?.emailAddress ?? "",
                                                     fullName       : data?.fullName ?? "",
                                                     username       : data?.fullName ?? "",
                                                     deviceId       : AppDelegate.shared.deviceToken ?? ""))
        }
    }
    
    func socialLoginApi(input:SocialLoginRequest) {
        isLoading = true
        apiReference.postApi(endPoint: APIEndpoint.socialLogin, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: LoginResponse.self)
            .sink { [unowned self] completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.socialLogin)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            KeychainHelper.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelper.save(response.data?.refreshToken, account: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.userId, key: Constants.userId)
            DispatchQueue.main.async {
                self.router.navigate(to: .home)
            }
            AppState.shared.login()
        }
        .store(in: &self.subscriptions)
    }
    
    func logout(input:LogoutRequest) {
        apiReference.postApi(endPoint: APIEndpoint.logout, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.logout)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            AppState.shared.logout()
            //            DispatchQueue.main.async {
            //            self.router.navigate(to: .login)
            //            }
        }
        .store(in: &self.subscriptions)
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}

