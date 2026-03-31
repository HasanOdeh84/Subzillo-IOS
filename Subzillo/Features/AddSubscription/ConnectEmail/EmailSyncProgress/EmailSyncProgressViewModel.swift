//
//  EmailSyncProgressViewModel.swift
//  Subzillo
//
//  Created by Antigravity on 13/03/26.
//

import Combine
import SwiftUI

class EmailSyncProgressViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    private var pollingCancellable                  : AnyCancellable?
    var apiReference                                = NetworkRequest.shared
    private let router                              : AppIntentRouter
    
    @Published var emailsScannedCount               : Int = 0
    @Published var subscriptionsFoundCount          : Int = 0
    @Published var recentlyFoundSubscriptions       : [RecentSubscriptionData] = []
    @Published var syncStatusData                   : SyncStatusData?
    @Published var showErrorPopup                   : Bool = false
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func startPolling(logId:String) {
        self.fetchSyncProgress(logId:logId)
        // Poll every 3 seconds
        pollingCancellable = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchSyncProgress(logId:logId)
            }
    }
    
    func stopPolling() {
        pollingCancellable?.cancel()
        pollingCancellable = nil
    }
    
    func fetchSyncProgress(logId:String) {
        let extraParams = "/\(logId)"
        apiReference.getApi(endPoint: .syncStatus, token: authKey, showLoader: false, extraParams: extraParams, responseType: SyncStatusResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error, endPoint: .syncStatus)
                    self?.stopPolling()
                }
            } receiveValue: { [weak self] response in
                PrintLogger.modelLog(response, type: .response, isInput: false)
                self?.handleResponse(response)
            }
            .store(in: &subscriptions)
    }
    
    private func handleResponse(_ response: SyncStatusResponse) {
        guard let data = response.data else { return }
        syncStatusData = data
        self.emailsScannedCount         = data.emailsAnalyzed ?? 0
        self.subscriptionsFoundCount    = data.subscriptionsFound ?? 0
        self.recentlyFoundSubscriptions = data.recentSubscriptions ?? []
        if data.syncStatus == "completed" { //syncStatus -> pending, in_progress, completed, failed
            self.stopPolling()
            if data.subscriptionsFound == 0{
                self.stopPolling()
//                ToastManager.shared.showToast(message: "No Subscriptions found", style: .error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AppIntentRouter.shared.pop(count: 1)
                }
            }else{
                emailSubscriptionsList(input: EmailSubscriptionsListRequest(userId: Constants.getUserId(), integrationId: response.data?.integrationId ?? ""))
            }
        }else if data.syncStatus == "failed" {
            self.stopPolling()
            ToastManager.shared.showToast(message: "Email Syncing failed", style: .error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppIntentRouter.shared.pop(count: 1)
            }
        }
    }
    
    func emailSubscriptionsList(input: EmailSubscriptionsListRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.emailSubscriptionsList, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: VoiceSubscriptionResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.emailSubscriptionsList)
//                    self.showErrorPopup = true
                    ToastManager.shared.showToast(message: "No Subscriptions found", style: .error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        AppIntentRouter.shared.pop(count: 1)
                    }
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            if response.data == nil || response.data?.subscriptions?.count == 0
            {
//                self.showErrorPopup = true
                ToastManager.shared.showToast(message: "No Subscriptions found", style: .error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AppIntentRouter.shared.pop(count: 1)
                }
            }
            else{
                NotificationCenter.default.post(name: .closeAllBottomSheets, object: nil)
                Constants.saveDefaults(value: response.providerLogoBaseUrl, key: Constants.providerBaseUrl)
                globalSubscriptionData = nil
                self?.router.navigateAndReplace(to: .extractedSubscriptions(subscriptions: response.data?.subscriptions ?? [], fromEmailSync: true, integrationId: input.integrationId))
                //                self.router.navigate(to: .subscriptionPreviewView(subscriptionsData: response.data?.subscriptions, content: "", isFromImage:false, isFromEmail: true, audioUrl: nil))
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func goBack() {
        stopPolling()
    }
    
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
