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
    @Published var otpVerified          : Bool = false
    private let router                  : AppIntentRouter
    private let sessionManager          : SessionManager

    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared) {
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func verifyOtp(input:OtpVerifyRequest,fromLogin:Bool,fromSocialLogin:Bool = false) {
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
            if fromSocialLogin && input.verifyType == 2{
                let data = LoginSignupVerifyData(verifyType         : 1,
                                                 email              : input.email,
                                                 phoneNumber        : input.phoneNumber,
                                                 countryCode        : input.countryCode,
                                                 userId             : SessionManager.shared.loginData?.userId ?? "",
                                                 isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                                 isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                                 fullName           : SessionManager.shared.loginData?.fullName ?? "",
                                                 socialLogin        : true)//optional
                self.sessionManager.saveLoginData(data)
                otpVerified = true
            }else{
                if sessionManager.loginData?.isNewUser == true && fromLogin{
                    router.navigate(to: .SuccessView(isOtp: true,isMobile: input.verifyType == 1 ? true : false))
                }else{
                    if sessionManager.loginData?.isSignupCompleted == true{
                        if !(sessionManager.loginData?.onboardingStatus ?? false) && sessionManager.loginData?.isSignupCompleted == true{
                            AppIntentRouter.shared.navigate(to: .onboarding)
                        }else{
                            AppState.shared.login()
                            router.navigate(to: .home)
                        }
                    }
//                    else if !(sessionManager.loginData?.onboardingStatus ?? false) && sessionManager.loginData?.isSignupCompleted == true{
//                        AppIntentRouter.shared.navigate(to: .onboarding)
//                    }
                    else{
                        if fromLogin{
                            router.navigate(to: .signup())
                        }else{
                            router.navigate(to: .SuccessView(isOtp: false))
                        }
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

