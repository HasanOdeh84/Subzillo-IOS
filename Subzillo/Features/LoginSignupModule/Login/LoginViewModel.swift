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
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func login(input:LoginRequest) {
        isLoading = true
        apiReference.postApi(endPoint: APIEndpoint.login, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: LoginResponse.self)
            .sink { [unowned self] completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.login)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            KeychainHelper.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelper.save(response.data?.refreshToken, account: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.id, key: Constants.userId)
            Constants.saveDefaults(value: response.data?.username, key: Constants.username)
            self.loginResponse = response
            if response.data?.emailOtpVerified ?? false{
//                DispatchQueue.main.async {
//                    path.wrappedValue.append(PendingRoute.home)
//                }
                AppState.shared.login()
            }else{
                DispatchQueue.main.async {
                    self.router.navigate(to: PendingRoute.verifyOtp(emailId: response.data?.email, from: .login, username: response.data?.username))
                }
            }
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
            Constants.saveDefaults(value: response.data?.id, key: Constants.userId)
            Constants.saveDefaults(value: response.data?.username, key: Constants.username)
            DispatchQueue.main.async {
                self.router.navigate(to: PendingRoute.home)
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
//                path.wrappedValue.append(PendingRoute.login)
//            }
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}

