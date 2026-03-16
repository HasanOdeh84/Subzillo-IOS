//
//  ExtractedSubscriptionsViewModel.swift
//  Subzillo
//
//  Created by Antigravity on 13/03/26.
//

import Combine
import SwiftUI

class ExtractedSubscriptionsViewModel: ObservableObject {
    
    var apiReference                                = NetworkRequest.shared
    private var subscriptionsCancellables           = Set<AnyCancellable>()
    private let router                              : AppIntentRouter
    
    @Published var subscriptions                    : [SubscriptionData] = []
    @Published var selectedIds                      : Set<String> = []
    @Published var showDeletePopup                  : Bool = false
    @State var fromEmailSyncScreen                  : Bool = false
    
    var showActionButtons: Bool {
        !selectedIds.isEmpty
    }
    
    init(router: AppIntentRouter = .shared) {
//    init(subscriptions: [SubscriptionData], router: AppIntentRouter = .shared) {
//        self.subscriptions = subscriptions
        self.router = router
    }
    
    func toggleSelection(for id: String) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
    
    func deleteSelected(fromEmailSyncScreen:Bool) {
        self.fromEmailSyncScreen = fromEmailSyncScreen
        var deleteIds : [String]?
        deleteIds = Array(selectedIds)
        discardEmailSubscriptionApi(input: DiscardEmailSubscriptionRequest(userId: Constants.getUserId(), subscriptionIds: deleteIds ?? []))
    }
    
//    func skipAll() {
//        router.navigate(to: .connectedEmailsList(isIntegrations: false))
//    }
    
    func continueAction() {
        let selectedSubs = subscriptions.filter { sub in
            if let id = sub.id {
                return selectedIds.contains(id)
            }
            return false
        }
        
//        router.navigate(to: .subscriptionPreviewView(
        router.navigateAndReplace(to: .subscriptionPreviewView(
            subscriptionsData   : selectedSubs,
            content             : "",
            isFromImage         : false,
            isFromEmail         : true,
            audioUrl            : nil,
            fromEmailSync       : true
        ))
    }
    
    func checkIfListIsEmpty() {
        if subscriptions.isEmpty {
            if fromEmailSyncScreen{
                AppIntentRouter.shared.navigateAndReplace(to: .connectedEmailsList(isIntegrations: false))
//                AppIntentRouter.shared.pop(count: 2)
            }else{
                AppIntentRouter.shared.navigateAndReplace(to: .connectedEmailsList(isIntegrations: false))
//                AppIntentRouter.shared.pop(count: 1)
            }
        }
    }
    
    func discardEmailSubscriptionApi(input: DiscardEmailSubscriptionRequest) {
        apiReference.postApi(endPoint: APIEndpoint.discardEmailSubscription, method: .POST, token: authKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error, endPoint: APIEndpoint.discardEmailSubscription)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            subscriptions.removeAll { sub in
                if let id = sub.id {
                    return selectedIds.contains(id)
                }
                return false
            }
            selectedIds.removeAll()
            checkIfListIsEmpty()
        }
        .store(in: &self.subscriptionsCancellables)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
