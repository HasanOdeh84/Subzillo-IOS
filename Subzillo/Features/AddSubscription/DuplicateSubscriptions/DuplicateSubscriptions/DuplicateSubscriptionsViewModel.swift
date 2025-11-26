//
//  DuplicateSubscriptionsViewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 19/11/25.
//

import Foundation
import Combine
import SwiftUICore
import SwiftUI

class DuplicateSubscriptionsViewModel: ObservableObject {
    
    private var subscriptions                   = Set<AnyCancellable>()
    var apiReference                            = NetworkRequest.shared
    private let router                          : AppIntentRouter
    @Published var subscriptioIds               : ResolveDuplicateSubscriptionResponseData?
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func resolveDuplicateSubscription(input:ResolveDuplicateSubscriptionRequest) {
        apiReference.postApi(endPoint: APIEndpoint.resolveDuplicateSubscription, method: .POST,token: authKey,body: input,showLoader: true, responseType: ResolveDuplicateSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.resolveDuplicateSubscription)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.subscriptioIds = response.data
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
