//
//  RegistrationViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import Combine
import SwiftUICore
import SwiftUI  

class RegistrationViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var registerResponse     : RegisterResponse?
    private let router                  : AppIntentRouter
    private let sessionManager          : SessionManager

    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared) {
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func register(input:RegisterRequest,verifyType:Int,fromSocialLogin:Bool = false,appleEmail:String = "",verifyData: LoginSignupVerifyData?) {
        apiReference.postApi(endPoint: APIEndpoint.registration, method: .POST,token: authKey,body: input,showLoader: true, responseType: RegisterResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.registration)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.registerResponse = response
            if response.data?.status == 0{
                AlertManager.shared.showAlert(title: "Merge account", message: response.message ?? "",cancelText: "Cancel",isDestructive: true, okAction: {
                    self.mergeAccount(input     : SendMergeOtpRequest(mergeLoginType  : verifyType == 1 ? 2 : 1,
                                                                 email           : input.email,
                                                                 countryCode     : input.countryCode,
                                                                 phoneNumber     : input.phoneNumber),
                                      fullName  : input.fullName)
                })
            }else{
                ToastManager.shared.showToast(message: response.message ?? "")
                let data = LoginSignupVerifyData(verifyType         : verifyType,
                                                 email              : input.email,
                                                 phoneNumber        : input.phoneNumber,
                                                 countryCode        : input.countryCode,
                                                 userId             : SessionManager.shared.loginData?.userId ?? "",
                                                 isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                                 isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                                 fullName           : input.fullName,
                                                 socialLogin        : SessionManager.shared.loginData?.socialLogin ?? false)
                self.sessionManager.saveLoginData(data)
                if fromSocialLogin && verifyData?.socialLoginType == loginType.apple{
                    if response.data?.emailOtpVerifiedStatus == false && response.data?.mobileOtpVerifiedStatus == false{
                        if input.email != appleEmail{
                            var isMobileVerify = false
                            let verifyType = 2
                            if input.phoneNumber != ""{
                                isMobileVerify = true
                            }
                            let data = LoginSignupVerifyData(verifyType         : verifyType,
                                                             email              : input.email,
                                                             phoneNumber        : input.phoneNumber,
                                                             countryCode        : input.countryCode,
                                                             userId             : SessionManager.shared.loginData?.userId ?? "",
                                                             isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                                             isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                                             fullName           : input.fullName,
                                                             socialLogin        : isMobileVerify)
                            self.sessionManager.saveLoginData(data)
                            router.navigate(to: .verifyOtp(fromLogin: false))
                        }
                        else{
                            router.navigate(to: .SuccessView(isOtp: false))
                        }
                    }else if response.data?.emailOtpVerifiedStatus == false && response.data?.mobileOtpVerifiedStatus == true{
                        if input.email != appleEmail{
                            var isMobileVerify = false
                            let verifyType = 2
                            if input.phoneNumber != ""{
                                isMobileVerify = true
                            }
                            let data = LoginSignupVerifyData(verifyType         : verifyType,
                                                             email              : input.email,
                                                             phoneNumber        : input.phoneNumber,
                                                             countryCode        : input.countryCode,
                                                             userId             : SessionManager.shared.loginData?.userId ?? "",
                                                             isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                                             isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                                             fullName           : input.fullName,
                                                             socialLogin        : false)
                            self.sessionManager.saveLoginData(data)
                            router.navigate(to: .verifyOtp(fromLogin: false))
                        }
                        else{
                            router.navigate(to: .SuccessView(isOtp: false))
                        }
                    }else if response.data?.emailOtpVerifiedStatus == true && response.data?.mobileOtpVerifiedStatus == false{
                        let verifyType = 1
                        let data = LoginSignupVerifyData(verifyType         : verifyType,
                                                         email              : input.email,
                                                         phoneNumber        : input.phoneNumber,
                                                         countryCode        : input.countryCode,
                                                         userId             : SessionManager.shared.loginData?.userId ?? "",
                                                         isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                                         isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                                         fullName           : input.fullName,
                                                         socialLogin        : false)
                        self.sessionManager.saveLoginData(data)
                        router.navigate(to: .verifyOtp(fromLogin: false))
                    }
                    else{
                        router.navigate(to: .SuccessView(isOtp: false))
                    }
                }else if fromSocialLogin && (verifyData?.socialLoginType == loginType.google || verifyData?.socialLoginType == loginType.microsoft){
                    if input.phoneNumber != ""{
                        let data = LoginSignupVerifyData(verifyType         : 1,
                                                         email              : input.email,
                                                         phoneNumber        : input.phoneNumber,
                                                         countryCode        : input.countryCode,
                                                         userId             : SessionManager.shared.loginData?.userId ?? "",
                                                         isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                                         isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                                         fullName           : input.fullName,
                                                         socialLogin        : false)
                        self.sessionManager.saveLoginData(data)
                        router.navigate(to: .verifyOtp(fromLogin: false))
                    }
                    else{
                        router.navigate(to: .SuccessView(isOtp: false))
                    }
                }
                else{
                    if input.email != "" && input.phoneNumber != ""{
                        let verifyType = (SessionManager.shared.loginData?.verifyType ?? 0) == 1 ? 2 : 1
                        let data = LoginSignupVerifyData(verifyType         : verifyType,
                                                         email              : input.email,
                                                         phoneNumber        : input.phoneNumber,
                                                         countryCode        : input.countryCode,
                                                         userId             : SessionManager.shared.loginData?.userId ?? "",
                                                         isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                                         isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                                         fullName           : input.fullName)
                        self.sessionManager.saveLoginData(data)
                        router.navigate(to: .verifyOtp(fromLogin: false))
                    }else{
                        router.navigate(to: .SuccessView(isOtp: false))
                    }
                }
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func mergeAccount(input:SendMergeOtpRequest,fullName:String) {
        apiReference.postApi(endPoint: APIEndpoint.sendMergeOtp, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.sendMergeOtp)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            let verifyType = (SessionManager.shared.loginData?.verifyType ?? 0) == 1 ? 2 : 1
            let data = LoginSignupVerifyData(verifyType         : verifyType,
                                             email              : input.email,
                                             phoneNumber        : input.phoneNumber,
                                             countryCode        : input.countryCode,
                                             userId             : SessionManager.shared.loginData?.userId ?? "",
                                             isNewUser          : SessionManager.shared.loginData?.isNewUser ?? false,
                                             isSignupCompleted  : SessionManager.shared.loginData?.isSignupCompleted ?? false,
                                             fullName           : fullName)
            self.sessionManager.saveLoginData(data)
            router.navigate(to: .verifyOtp(fromLogin: false,verifyMergeType: 2))
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
