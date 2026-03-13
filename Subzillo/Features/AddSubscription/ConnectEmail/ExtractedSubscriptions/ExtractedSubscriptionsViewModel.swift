//
//  ExtractedSubscriptionsViewModel.swift
//  Subzillo
//
//  Created by Antigravity on 13/03/26.
//

import Combine
import SwiftUI

class ExtractedSubscriptionsViewModel: ObservableObject {
    
    private var subscriptionsCancellables            = Set<AnyCancellable>()
    private let router                              : AppIntentRouter
    
    @Published var subscriptions                    : [SubscriptionData] = []
    @Published var selectedIds                      : Set<String> = []
    
    var showActionButtons: Bool {
        !selectedIds.isEmpty
    }
    
    init(subscriptions: [SubscriptionData], router: AppIntentRouter = .shared) {
        self.subscriptions = subscriptions
        self.router = router
    }
    
    func toggleSelection(for id: String) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
    
    func deleteSelected() {
        subscriptions.removeAll { sub in
            if let id = sub.id {
                return selectedIds.contains(id)
            }
            return false
        }
        selectedIds.removeAll()
        
        checkIfListIsEmpty()
    }
    
    func skipAll() {
        router.navigate(to: .connectedEmailsList(isIntegrations: false))
    }
    
    func continueAction() {
        let selectedSubs = subscriptions.filter { sub in
            if let id = sub.id {
                return selectedIds.contains(id)
            }
            return false
        }
        
        router.navigate(to: .subscriptionPreviewView(
            subscriptionsData   : selectedSubs,
            content             : "",
            isFromImage         : false,
            isFromEmail         : true,
            audioUrl            : nil
        ))
    }
    
    func checkIfListIsEmpty() {
        if subscriptions.isEmpty {
            router.navigate(to: .connectedEmailsList(isIntegrations: false))
        }
    }
}
