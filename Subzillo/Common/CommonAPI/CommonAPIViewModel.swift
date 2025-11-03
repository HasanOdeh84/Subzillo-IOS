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
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var currencyResponse     : [Currency]?
    @Published var error                : Error?
    
    func getCategories(path: Binding<NavigationPath>) {
        apiReference.getApi(endPoint: APIEndpoint.getCategories, token: defaultAuthKey, responseType: getCategoriesResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.getCategories)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
        }
        .store(in: &self.subscriptions)
    }
    
    func getCurrencies() {
        apiReference.getApi(endPoint: APIEndpoint.getCurrencies, token: defaultAuthKey, responseType: getCurrenciesResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.error = error
                    self.handleError(error,endPoint: APIEndpoint.getCurrencies)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            currencyResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
