import Foundation
import Combine
import SwiftUI
import UIKit

class InviteFriendsViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    var apiReference                                = NetworkRequest.shared
    private let router                              : AppIntentRouter
    private let sessionManager                      : SessionManager
    @Published var rewards                          : [RewardsData] = []
    @Published var redeemSucess                     : Bool = false
    
    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared){
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func rewards(input:RewardsRequest) {
        apiReference.postApi(endPoint: APIEndpoint.rewards, method: .POST,token: authKey,body: input,showLoader: true, responseType: RewardsResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.rewards)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.rewards = response.data ?? []
        }
        .store(in: &self.subscriptions)
    }
    
    func redeemReward(input:RedeemRewardRequest) {
        redeemSucess = false
        apiReference.postApi(endPoint: APIEndpoint.redeemReward, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.redeemReward)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.redeemSucess = true
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
