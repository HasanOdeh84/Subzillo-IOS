//
//  SettingsViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    
    private var subscriptions               = Set<AnyCancellable>()
    var apiReference                        = NetworkRequest.shared
    private let router                      : AppIntentRouter
    @Published var privacyData              : PrivacyDataResponseData?
    @Published var content                  : String?
    @Published var isUpdateSuccess          : Bool = false
    @Published var isUpdateError1           : Bool = false
    @Published var isUpdateError2           : Bool = false
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func getPrivacyData(type:Int) {
        //type -> 1-privacy policy, 2- terms & Conditions, 3-contact us for contact us in data object in response, instead of content, there will email & phone
        apiReference.getApi(endPoint: APIEndpoint.privacyData, token: authKey, showLoader: true, extraParams: "/\(type)", responseType: PrivacyDataResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.privacyData)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.privacyData = response.data
            self.content = response.data?.content
        }
        .store(in: &self.subscriptions)
    }
    
    func deleteAccount(input:DeleteAccountRequest) {
        apiReference.postApi(endPoint: APIEndpoint.deleteAccount, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.deleteAccount)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            AppState.shared.logout()
            self.router.navigate(to: .login)
        }
        .store(in: &self.subscriptions)
    }
    
    func toggleReminders(input: ToggleRemindersRequest) {
        isUpdateSuccess = false
        isUpdateError1 = false
        isUpdateError2 = false
        apiReference.postApi(endPoint: APIEndpoint.toggleReminders, method: .POST, token: authKey, body: input, showLoader: false, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error, endPoint: APIEndpoint.toggleReminders)
                    if input.type == 1{
                        isUpdateError1 = true
                    }else if input.type == 2{
                        isUpdateError2 = true
                    }
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
//            ToastManager.shared.showToast(message: response.message ?? "")
            if input.type == 3{
                self.isUpdateSuccess = true
            }
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
