//
//  OtpVerificationViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 24/09/25.
//

import Combine
import SwiftUICore
import SwiftUI

class OtpVerifyViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var otpVerifyResponse    : GeneralResponse?
    @Published var resendOtpResponse    : Bool = false
    private let router                  : AppIntentRouter
    private let sessionManager          : SessionManager

    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared) {
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func verifyOtp(input:OtpVerifyRequest,fromLogin:Bool) {
        apiReference.postApi(endPoint: APIEndpoint.verifyOtp, method: .POST, token: authKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.verifyOtp)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.otpVerifyResponse = response
            if sessionManager.loginData?.isNewUser == true && fromLogin{
                router.navigate(to: .SuccessView(isOtp: true,isMobile: input.verifyType == 1 ? true : false))
            }else{
                if sessionManager.loginData?.isSignupCompleted == true{
                    AppState.shared.login()
                    router.navigate(to: .home)
                }else{
                    if fromLogin{
                        router.navigate(to: .signup)
                    }else{
                        router.navigate(to: .SuccessView(isOtp: false))
                    }
                }
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func resendOtp(input:ResendOtpRequest) {
        apiReference.postApi(endPoint: APIEndpoint.resendOtp, method: .POST, token: authKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.resendOtp)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.resendOtpResponse = true
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
