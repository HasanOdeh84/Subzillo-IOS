//
//  SubscriptionMatchViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/11/25.
//

import Foundation
import Combine

class SubscriptionMatchViewModel: NSObject, ObservableObject {
    
    private var subscriptions                   = Set<AnyCancellable>()
    var apiReference                            = NetworkRequest.shared
    private let router                          : AppIntentRouter
    @Published var getSubsDetailsResponse       : SubscriptionData?
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func getSubscriptionDetails(input:GetSubscriptionDetailsRequest) {
        self.getSubsDetailsResponse = nil
        apiReference.postApi(endPoint: APIEndpoint.getSubscriptionDetails, method: .POST,token: authKey,body: input,showLoader: true, responseType: GetSubscriptionDetailsResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.getSubscriptionDetails)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.getSubsDetailsResponse = response.data
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
