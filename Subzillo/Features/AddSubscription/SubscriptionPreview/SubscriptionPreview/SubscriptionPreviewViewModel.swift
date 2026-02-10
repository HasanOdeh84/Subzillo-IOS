//
//  SubscriptionPreviewViewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 14/11/25.
//


import Foundation
import Combine
import SwiftUICore
class SubscriptionPreviewViewModel: NSObject, ObservableObject {
    
    private var subscriptions                   = Set<AnyCancellable>()
    var apiReference                            = NetworkRequest.shared
    private let router                          : AppIntentRouter
    @Published var isEntrySuccess               : Bool?
    @Published var addSubscriptionResponse      : PendingSubscriptionConfirmResponseData?
    @Published var isDiscardSuccess             : Bool?
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func updateSubscriptions(input:PendingSubscriptionConfirmRequest) {
        addSubscriptionResponse = nil
        self.isEntrySuccess = false
        apiReference.postApi(endPoint: APIEndpoint.pendingSubscriptionConfirm, method: .POST,token: authKey,body: input,showLoader: true, responseType: PendingSubscriptionConfirmResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.pendingSubscriptionConfirm)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            if response.data != nil {
                self.addSubscriptionResponse = response.data
            }
//            else{
//                ToastManager.shared.showToast(message: response.message ?? "")
//            }
            self.isEntrySuccess = true
        }
        .store(in: &self.subscriptions)
    }
    
    func discardEmailSubscriptionApi(input: DiscardEmailSubscriptionRequest) {
        self.isDiscardSuccess = false
        apiReference.postApi(endPoint: APIEndpoint.discardEmailSubscription, method: .POST, token: authKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error, endPoint: APIEndpoint.discardEmailSubscription)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.isDiscardSuccess = true
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
