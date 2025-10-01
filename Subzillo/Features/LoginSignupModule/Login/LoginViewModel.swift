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
    
    func login(input:LoginRequest, path:Binding<NavigationPath>) {
        isLoading = true
        apiReference.postApi(endPoint: Endpoint.login, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: LoginResponse.self)
            .sink { [unowned self] completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.login)
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
                DispatchQueue.main.async {
                    path.wrappedValue.append(PendingRoute.home)
                }
                LoginStatus().loginUpdate(isLogin: true)
            }else{
                DispatchQueue.main.async {
                    path.wrappedValue.append(PendingRoute.verifyOtp(emailId: response.data?.email, from: .login, username: response.data?.username))
                }
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func logout(input:LogoutRequest, path:Binding<NavigationPath>) {
        apiReference.postApi(endPoint: Endpoint.logout, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.logout)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            Constants.resetDefaults()
            LoginStatus().loginUpdate(isLogin: false)
            DispatchQueue.main.async {
                path.wrappedValue.append(PendingRoute.login)
            }
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : Endpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}

