//
//  CommonApiViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 13/10/25.
//

import Combine
import SwiftUICore
import SwiftUI

class CommonAPIViewModel: ObservableObject {
    
    //MARK: - Properties
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var currencyResponse     : [Currency]?
    @Published var countriesResponse    : [Country]?
    @Published var currencyError        : Error?
    @Published var countryError         : Error?
    private let router                  : AppIntentRouter
    
    @Published var categoriesResponse   : [Category]?
    @Published var categoryError        : Error?
    @Published var paymentMethodResponse: [PaymentMethod]?
    @Published var paymentMethodError   : Error?
    
    @Published var userInfoResponse     : UserInfo?
    @Published var userInfError         : Error?
    
    @Published var unreadCountResponse  : UnreadNotificationCountData?
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    //MARK: - API calls
    func getUserInfo(input:getUserInfoRequest) {
        self.userInfoResponse = nil
        apiReference.postApi(endPoint: APIEndpoint.getUserInfo, method: .POST,token: authKey,body: input,showLoader: true, responseType: getUserInfoResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.userInfError = error
                    self.handleError(error,endPoint: APIEndpoint.getUserInfo)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.userInfoResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func unreadNotificationCount(input:UnreadNotificationCountRequest) {
        self.unreadCountResponse = nil
        apiReference.postApi(endPoint: APIEndpoint.unreadNotificationCount, method: .POST,token: authKey,body: input,showLoader: false, responseType: UnreadNotificationCountResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.userInfError = error
                    self.handleError(error,endPoint: APIEndpoint.unreadNotificationCount)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.unreadCountResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func updateDeviceId(input:UpdateDeviceIdRequest) {
        apiReference.postApi(endPoint: APIEndpoint.updateDeviceId, method: .POST,token: authKey,body: input,showLoader: false, responseType: UpdateDeviceIdResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.userInfError = error
                    self.handleError(error,endPoint: APIEndpoint.updateDeviceId)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            KeychainHelperApp.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelperApp.save(response.data?.refreshToken, account: Constants.refreshKey)
        }
        .store(in: &self.subscriptions)
    }
    
    func getPaymentMethods() {
        self.paymentMethodResponse = nil
        apiReference.getApi(endPoint: APIEndpoint.getPaymentMethods, token: defaultAuthKey, responseType: getPaymentMethodResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.paymentMethodError = error
                    self.handleError(error,endPoint: APIEndpoint.getPaymentMethods)
                }
            }
        receiveValue: { response in
            self.paymentMethodResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func getCategories() {
        self.categoriesResponse = nil
        apiReference.getApi(endPoint: APIEndpoint.getCategories, token: defaultAuthKey, responseType: getCategoriesResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.categoryError = error
                    self.handleError(error,endPoint: APIEndpoint.getCategories)
                }
            }
        receiveValue: { response in
            self.categoriesResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func getCurrencies() {
        apiReference.getApi(endPoint: APIEndpoint.getCurrencies, token: defaultAuthKey, responseType: getCurrenciesResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.currencyError = error
                    self.handleError(error,endPoint: APIEndpoint.getCurrencies)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            currencyResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func getCurrencies1() async -> Bool {
        await withCheckedContinuation { continuation in
            apiReference
                .getApi(endPoint: APIEndpoint.getCurrencies,
                        token: defaultAuthKey,
                        responseType: getCurrenciesResponse.self)
                .sink { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currencyError = error
                        self?.handleError(error, endPoint: APIEndpoint.getCurrencies)
                        
                        continuation.resume(returning: false)   // ❌ failed
                    }
                } receiveValue: { [weak self] response in
                    PrintLogger.modelLog(response, type: .response, isInput: false)
                    self?.currencyResponse = response.data
                    
                    continuation.resume(returning: true)  // ✅ success
                }
                .store(in: &self.subscriptions)
        }
    }
    
    func getCountries() {
        apiReference.getApi(endPoint: APIEndpoint.getCountryCodes, token: defaultAuthKey, responseType: getCountriesResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.countryError = error
                    self.handleError(error,endPoint: APIEndpoint.getCountryCodes)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            countriesResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
