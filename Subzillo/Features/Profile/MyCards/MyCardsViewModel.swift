//
//  MyCardsViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 26/12/25.
//

import Foundation
import Combine
import SwiftUI
import UIKit

class MyCardsViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    var apiReference                                = NetworkRequest.shared
    @Published var listUserCardsResponse            : [ListUserCardsResponseData]?
    private let router                              : AppIntentRouter
    private let sessionManager                      : SessionManager
    @Published var isDelete                         : Bool = false
    @Published var isEdit                           : Bool = false
    
    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared){
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func editCard(input:EditCardRequest) {
        isEdit = false
        apiReference.postApi(endPoint: APIEndpoint.editCard, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.editCard)
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self?.isEdit = true
        }
        .store(in: &self.subscriptions)
    }
    
    func deleteCard(input:DeleteCardRequest) {
        isDelete = false
        apiReference.postApi(endPoint: APIEndpoint.deleteCard, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.deleteCard)
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self?.isDelete = true
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
