//
//  GmailSyncProgressViewModel.swift
//  Subzillo
//
//  Created by Antigravity on 13/03/26.
//

import Combine
import SwiftUI

class GmailSyncProgressViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    private var pollingCancellable                  : AnyCancellable?
    var apiReference                                = NetworkRequest.shared
    private let router                              : AppIntentRouter
    
    @Published var emailsScannedCount               : Int = 0
    @Published var subscriptionsFoundCount          : Int = 0
    @Published var recentlyFoundSubscriptions       : [SubscriptionData] = []
    @Published var isSyncComplete                   : Bool = false
    @Published var errorMessage                      : String? = nil
    
    private let emailData                           : ListConnectedEmailsData
    
    init(emailData: ListConnectedEmailsData, router: AppIntentRouter = .shared) {
        self.emailData = emailData
        self.router = router
    }
    
    func startPolling() {
        // Poll every 3 seconds
        pollingCancellable = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchSyncProgress()
            }
    }
    
    func stopPolling() {
        pollingCancellable?.cancel()
        pollingCancellable = nil
    }
    
    func fetchSyncProgress() {
        let input = EmailSubscriptionsListRequest(
            userId: Constants.getUserId(),
            integrationId: emailData.id ?? "" // Hybrid or whichever mode is used for sync
        )
        
        // We use showLoader: false for polling to not interrupt the user
        apiReference.postApi(endPoint: APIEndpoint.emailSubscriptionsList, method: .POST, token: authKey, body: input, showLoader: false, responseType: VoiceSubscriptionResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] response in
                self?.handleResponse(response)
            }
            .store(in: &subscriptions)
    }
    
    private func handleResponse(_ response: VoiceSubscriptionResponse) {
        guard let data = response.data else { return }
        
        self.emailsScannedCount = data.emailsScanned ?? 0
        self.subscriptionsFoundCount = data.subscriptionsFoundCount ?? 0
        self.recentlyFoundSubscriptions = data.subscriptions ?? []
        
        // Check if sync is completed (syncStatus == 2)
        if data.syncStatus == 2 {
            self.isSyncComplete = true
            self.stopPolling()
            
            // Navigate to next screen automatically
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Constants.saveDefaults(value: response.providerLogoBaseUrl, key: Constants.providerBaseUrl)
                globalSubscriptionData = nil
                self.router.navigate(to: .extractedSubscriptions(subscriptions: data.subscriptions ?? []))
            }
        }
    }
    
    private func handleError(_ error: APIError) {
        print("API Error in Sync Progress: \(error.localizedDescription)")
        // Don't show toast every 3 seconds if it fails, maybe just update an error state if needed
        self.errorMessage = error.localizedDescription
    }
    
    func goBack() {
        stopPolling()
    }
}
