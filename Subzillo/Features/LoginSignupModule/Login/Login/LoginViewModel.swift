//
//  LoginViewModel.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var loginResponse        : LoginResponse?
    @Published var showRestoreAccSheet  : Bool = false
    private let router                  : AppIntentRouter
    private let sessionManager          : SessionManager
    private var cancellables            = Set<AnyCancellable>()
    @Published var socialLoginFullName  : String = ""

    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared) {
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func login(input:checkLoginRequest, formattedPhNo: String) {
        showRestoreAccSheet = false
        apiReference.postApi(endPoint: APIEndpoint.checkLogin, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: LoginResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.checkLogin)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            KeychainHelperApp.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelperApp.save(response.data?.refreshToken, account: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.userId, key: Constants.userId)
            self.loginResponse = response
            let data = LoginSignupVerifyData(verifyType         : input.loginType,
                                             email              : input.email,
                                             phoneNumber        : input.phoneNumber,
                                             formattedPhNo      : formattedPhNo,
                                             countryCode        : input.countryCode,
                                             userId             : response.data?.userId ?? "",
                                             isNewUser          : response.data?.isNewUser ?? false,
                                             isSignupCompleted  : response.data?.signupCompleted ?? false,
                                             fullName           : response.data?.fullName,
                                             onboardingStatus   : response.data?.onboardingStatus ?? false)
            self.sessionManager.saveLoginData(data)
            if response.data?.deleteStatus ?? false{
                showRestoreAccSheet = true
            }else{
                ToastManager.shared.showToast(message: response.message ?? "")
                self.router.navigate(to: .verifyOtp(fromLogin: true))
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func socialLogin(loginType:loginType,deviceId: String, createNewAcc: Bool?){
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "image_\(timestamp).jpg"
        if loginType == .google{
            SocialLogins.shared.signInWithGoogle { [weak self] data in
                guard let data else { return }
                self?.socialLoginApi(input: SocialLoginRequest(authProvider         : data.loginType,
                                                               email                : data.emailAddress ?? "",
                                                               socialId             : data.id ?? "",
                                                               deviceId             : deviceId,
                                                               fullName             : data.fullName ?? ""
                                                               ,
                                                               referralCode         : Constants.getUserDefaultsValue(for: Constants.referrerId),
                                                               createNewAcc         : createNewAcc
                                                              ),
                                     fileData: [MultiPartFileInput(
                                        fieldName   : "profile",
                                        fileName    : filename,
                                        mimeType    : "image/jpeg",
                                        fileData    : data.profileImage ?? Data()
                                     )])
            }
        }else if loginType == .apple{
            SocialLogins.shared.signInWithApple { [weak self] data in
                guard let data else {
                    return
                }
                self?.socialLoginApi(input: SocialLoginRequest(authProvider         : data.loginType,
                                                               email                : data.emailAddress ?? "",
                                                               socialId             : data.id ?? "",
                                                               deviceId             : deviceId,
                                                               fullName             : data.fullName ?? ""
                                                               ,
                                                               referralCode         : Constants.getUserDefaultsValue(for: Constants.referrerId),
                                                               createNewAcc         : createNewAcc
                                                              ),
                                     fileData: [])
            }
        }else if loginType == .microsoft{
            SocialLogins.shared.signInWithMicrosoft { [weak self] data in
                guard let data else {
                    return
                }
                self?.socialLoginApi(input: SocialLoginRequest(authProvider         : data.loginType,
                                                               email                : data.emailAddress ?? "",
                                                               socialId             : data.id ?? "",
                                                               deviceId             : deviceId,
                                                               fullName             : data.fullName ?? ""
                                                               ,
                                                               referralCode         : Constants.getUserDefaultsValue(for: Constants.referrerId),
                                                               createNewAcc         : createNewAcc
                                                              ),
                                     fileData: [])
            }
        }
    }
    
    func socialLoginApi(input:SocialLoginRequest, fileData:[MultiPartFileInput]) {
        showRestoreAccSheet = false
        apiReference.postMultipartApi(endPoint: APIEndpoint.socialLogin, method: .POST,token: defaultAuthKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: LoginResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.socialLogin)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            KeychainHelperApp.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelperApp.save(response.data?.refreshToken, account: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.id, key: Constants.userId)
            let data = LoginSignupVerifyData(verifyType             : 2,//input.authProvider?.rawValue ?? 1,
                                             email                  : input.authProvider == loginType.apple ? response.data?.email : input.email,//input.email,
                                             userId                 : response.data?.id ?? "",
                                             isNewUser              : response.data?.isNewUser ?? false,
                                             isSignupCompleted      : response.data?.signupCompleted ?? false,
                                             fullName               : input.authProvider == loginType.apple ? response.data?.fullName : input.fullName,
                                             socialLoginType        : input.authProvider,
                                             onboardingStatus       : response.data?.onboardingStatus ?? false)
            self.sessionManager.saveLoginData(data)
            DispatchQueue.main.async { [self] in
                if response.data?.deleteStatus ?? false{
                    socialLoginFullName = input.fullName
                    showRestoreAccSheet = true
                }else{
                    if response.data?.isNewUser ?? false{
                        self.router.navigate(to: .signup(fromSocialLogin:true))
                    }else{
                        ToastManager.shared.showToast(message: response.message ?? "")
                        if response.data?.signupCompleted == true{
                            AppState.shared.login()
                            router.navigate(to: .home)
                        }else{
                            router.navigate(to: .signup(fromSocialLogin:true))
                        }
                    }
                }
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func restoreUser(input:RestoreUserRequest, fromLogin: Bool = true, email:String?, phoneNo:String?, formattedPhNo:String?, countryCode:String?) {
        apiReference.postApi(endPoint: APIEndpoint.restoreUser, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: RestoreUserResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.restoreUser)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            KeychainHelperApp.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelperApp.save(response.data?.refreshToken, account: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.userId, key: Constants.userId)
            let data = LoginSignupVerifyData(verifyType         : fromLogin ? input.loginType : 2,
                                             email              : input.loginType == loginType.apple.rawValue ? response.data?.email : email,
                                             phoneNumber        : phoneNo,
                                             formattedPhNo      : formattedPhNo,
                                             countryCode        : countryCode,
                                             userId             : response.data?.userId ?? "",
                                             isNewUser          : response.data?.isNewUser ?? false,
                                             isSignupCompleted  : response.data?.signupCompleted ?? false,
                                             fullName           : fromLogin ? response.data?.fullName : (input.loginType == loginType.apple.rawValue ? response.data?.fullName : self.socialLoginFullName),
                                             onboardingStatus   : response.data?.onboardingStatus ?? false)
            self.sessionManager.saveLoginData(data)
            if fromLogin{
                self.router.navigate(to: .verifyOtp(fromLogin: true))
            }else{
                self.router.navigate(to: .signup(fromSocialLogin:true))
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func logout(input:LogoutRequest) {
        apiReference.postApi(endPoint: APIEndpoint.logout, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.logout)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            SocialLogins.shared.googleSignOut()
            AppState.shared.logout()
            self.router.navigate(to: .login)
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

