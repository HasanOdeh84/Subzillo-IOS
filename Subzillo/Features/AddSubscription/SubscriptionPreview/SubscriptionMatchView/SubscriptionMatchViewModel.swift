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
    @Published var isRenewSuccess               : Bool = false
    
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
    
    func renewalUpdate(input:RenewalUpdateRequest){
        isRenewSuccess = false
        apiReference.postApi(endPoint: APIEndpoint.renewalUpdate, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.renewalUpdate)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            isRenewSuccess = true
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
