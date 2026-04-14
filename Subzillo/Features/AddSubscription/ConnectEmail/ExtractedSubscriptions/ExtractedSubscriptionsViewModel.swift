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
    @Published var integrationId                    : String = ""
    @State var fromEmailSyncScreen                  : Bool = false
    
    var showActionButtons: Bool {
        !selectedIds.isEmpty
    }
    
    init(router: AppIntentRouter = .shared) {
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
    
    func continueAction() {
        let selectedSubs = subscriptions.filter { sub in
            if let id = sub.id {
                return selectedIds.contains(id)
            }
            return false
        }
        
        router.navigate(to: .subscriptionPreviewView(
            //        router.navigateAndReplace(to: .subscriptionPreviewView(
            subscriptionsData   : selectedSubs,
            content             : "",
            isFromImage         : false,
            isFromEmail         : true,
            audioUrl            : nil,
            fromEmailSync       : true
        ))
    }
    
    func getEmailSubscriptionsList() {
        let input = EmailSubscriptionsListRequest(userId: Constants.getUserId(), integrationId: integrationId)
        apiReference.postApi(endPoint: APIEndpoint.emailSubscriptionsList, method: .POST, token: authKey, body: input, showLoader: true, responseType: VoiceSubscriptionResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error, endPoint: APIEndpoint.emailSubscriptionsList)
                }
            }
        receiveValue: { [weak self] response in
            guard let self = self else { return }
            self.subscriptions.removeAll()
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.subscriptions = response.data?.subscriptions ?? []
        }
        .store(in: &self.subscriptionsCancellables)
    }
    
    func discardEmailSubscriptionApi(input: DiscardEmailSubscriptionRequest) {
        apiReference.postApi(endPoint: APIEndpoint.discardEmailSubscription, method: .POST, token: authKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error, endPoint: APIEndpoint.discardEmailSubscription)
                }
            }
        receiveValue: { [weak self] response in
            guard let self = self else { return }
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.subscriptions.removeAll { sub in
                if let id = sub.id {
                    return self.selectedIds.contains(id)
                }
                return false
            }
            self.selectedIds.removeAll()
        }
        .store(in: &self.subscriptionsCancellables)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
