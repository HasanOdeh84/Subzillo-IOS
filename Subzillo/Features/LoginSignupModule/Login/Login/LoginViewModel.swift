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
    var socialLoginRequest              : SocialLoginRequest?
    var fileData                        : [MultiPartFileInput]?

    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared) {
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func login(input:checkLoginRequest, formattedPhNo: String) {
        showRestoreAccSheet = false
        apiReference.postApi(endPoint: APIEndpoint.checkLogin, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: LoginResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.checkLogin)
                }
            }
        receiveValue: { [weak self] response in
            guard let self = self else { return }
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
                let input = SocialLoginRequest(authProvider         : data.loginType,
                                               email                : data.emailAddress ?? "",
                                               socialId             : data.id ?? "",
                                               deviceId             : deviceId,
                                               fullName             : data.fullName ?? ""
                                               ,
                                               referralCode         : Constants.getUserDefaultsValue(for: Constants.referrerId),
                                               createNewAcc         : createNewAcc)
                let fileData: [MultiPartFileInput] = [MultiPartFileInput(
                    fieldName   : "profile",
                    fileName    : filename,
                    mimeType    : "image/jpeg",
                    fileData    : data.profileImage ?? Data()
                 )]
                self?.socialLoginApi(input      : input,
                                     fileData   : fileData)
                self?.socialLoginRequest = input
                self?.fileData           = fileData
            }
        }else if loginType == .apple{
            SocialLogins.shared.signInWithApple { [weak self] data in
                guard let data else {
                    return
                }
                let input = SocialLoginRequest(authProvider         : data.loginType,
                                               email                : data.emailAddress ?? "",
                                               socialId             : data.id ?? "",
                                               deviceId             : deviceId,
                                               fullName             : data.fullName ?? ""
                                               ,
                                               referralCode         : Constants.getUserDefaultsValue(for: Constants.referrerId),
                                               createNewAcc         : createNewAcc)
                self?.socialLoginApi(input      : input,
                                     fileData   : [])
                self?.socialLoginRequest = input
            }
        }else if loginType == .microsoft{
            SocialLogins.shared.signInWithMicrosoft { [weak self] data in
                guard let data else {
                    return
                }
                let input = SocialLoginRequest(authProvider         : data.loginType,
                                               email                : data.emailAddress ?? "",
                                               socialId             : data.id ?? "",
                                               deviceId             : deviceId,
                                               fullName             : data.fullName ?? ""
                                               ,
                                               referralCode         : Constants.getUserDefaultsValue(for: Constants.referrerId),
                                               createNewAcc         : createNewAcc)
                self?.socialLoginApi(input      : input,
                                     fileData   : [])
                self?.socialLoginRequest = input
            }
        }
    }
    
    func socialLogin_createAcc(loginType:loginType,deviceId: String, createNewAcc: Bool?){
        self.socialLoginRequest?.createNewAcc = createNewAcc
        if loginType == .google{
            if let data = socialLoginRequest{
                self.socialLoginApi(input      : data,
                                    fileData   : self.fileData ?? [])
            }
        }else if loginType == .apple{
            if let data = socialLoginRequest{
                self.socialLoginApi(input      : data,
                                    fileData   : [])
            }
        }else if loginType == .microsoft{
            if let data = socialLoginRequest{
                self.socialLoginApi(input      : data,
                                    fileData   : [])
            }
        }
    }
    
    func socialLoginApi(input:SocialLoginRequest, fileData:[MultiPartFileInput]) {
        showRestoreAccSheet = false
        apiReference.postMultipartApi(endPoint: APIEndpoint.socialLogin, method: .POST,token: defaultAuthKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: LoginResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.socialLogin)
                }
            }
        receiveValue: { [weak self] response in
            guard let self = self else { return }
            PrintLogger.modelLog(response, type: .response, isInput: false)
            KeychainHelperApp.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelperApp.save(response.data?.refreshToken, account: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.userId, key: Constants.userId)
            let data = LoginSignupVerifyData(verifyType             : 2,//input.authProvider?.rawValue ?? 1,
                                             email                  : input.authProvider == loginType.apple ? response.data?.email : input.email,//input.email,
                                             userId                 : response.data?.userId ?? "",
                                             isNewUser              : response.data?.isNewUser ?? false,
                                             isSignupCompleted      : response.data?.signupCompleted ?? false,
                                             fullName               : input.authProvider == loginType.apple ? response.data?.fullName : input.fullName,
                                             socialLoginType        : input.authProvider,
                                             onboardingStatus       : response.data?.onboardingStatus ?? false)
            self.sessionManager.saveLoginData(data)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if response.data?.deleteStatus ?? false{
                    self.socialLoginFullName = input.fullName
                    self.showRestoreAccSheet = true
                }else{
                    if response.data?.isNewUser ?? false{
                        self.router.navigate(to: .signup(fromSocialLogin:true))
                    }else{
                        ToastManager.shared.showToast(message: response.message ?? "")
                        if response.data?.signupCompleted == true{
                            if !(response.data?.onboardingStatus ?? false) && response.data?.signupCompleted == true{
                                if Constants.getUserDefaultsBooleanValue(for: "isSyncing"){
                                    Constants.saveDefaults(value: false, key: "isSyncing")
                                }else{
                                    AppIntentRouter.shared.navigate(to: .onboarding)
                                }
                            }else{
                                AppState.shared.login()
                                self.router.navigate(to: .home)
                            }
                        }else{
                            self.router.navigate(to: .signup(fromSocialLogin:true))
                        }
                    }
                }
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func restoreUser(input:RestoreUserRequest, fromLogin: Bool = true, email:String?, phoneNo:String?, formattedPhNo:String?, countryCode:String?) {
        apiReference.postApi(endPoint: APIEndpoint.restoreUser, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: RestoreUserResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.restoreUser)
                }
            }
        receiveValue: { [weak self] response in
            guard let self = self else { return }
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
//                self.router.navigate(to: .signup(fromSocialLogin:true))
                AppState.shared.login()
                self.router.navigate(to: .home)
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func logout(input:LogoutRequest) {
        apiReference.postApi(endPoint: APIEndpoint.logout, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.logout)
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            SocialLogins.shared.googleSignOut()
            AppState.shared.logout()
            self?.router.navigate(to: .login)
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

