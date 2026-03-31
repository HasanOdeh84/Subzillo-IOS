import Foundation
import SwiftUI
import Combine
import SDWebImageSwiftUI

class ConnectedEmailsViewModel: ObservableObject {
    
    private var subscriptions                           = Set<AnyCancellable>()
    var apiReference                                    = NetworkRequest.shared
    private let router                                  : AppIntentRouter
    @Published var searchText                           : String = ""
    @Published var connectedEmails                      : [ListConnectedEmailsData] = []
    @Published var showErrorPopup                       : Bool = false
    
    // Inline Sync Progress Properties
    @Published var isInlineSyncing                      : Bool = false
    @Published var inlineSyncingId                      : String? = nil
    @Published var inlineEmailsScanned                  : Int = 0
    @Published var inlineSubscriptionsFound             : Int = 0
    private var pollingCancellable                      : AnyCancellable?
    
    var filteredEmails: [ListConnectedEmailsData] {
        if searchText.isEmpty {
            return connectedEmails
        } else {
            return connectedEmails.filter { $0.email?.lowercased().contains(searchText.lowercased()) ?? false }
        }
    }
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func listConnectedEmails(input: ListConnectedEmailsRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.listConnectedEmails, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: ListConnectedEmailsResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.listConnectedEmails)
                }
            }
        receiveValue: { [weak self] response in
            guard let self = self else { return }
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.connectedEmails = response.data ?? []
            
            // Persistence: Check if an inline sync should be active
            if self.connectedEmails.count == 1, let email = self.connectedEmails.first {
                if email.syncStatus == 1 {
                    self.isInlineSyncing = true
                    self.inlineSyncingId = email.id
                    if self.pollingCancellable == nil {
                        self.startInlinePolling(logId: email.syncLogId ?? "")
                    }
                }
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func deleteEmailAPI(input: DeleteEmailRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.deleteEmail, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: GeneralResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.deleteEmail)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
        }
        .store(in: &self.subscriptions)
    }
    
    func syncEmailAPI(input: SyncEmailRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.syncEmail, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: SyncEmailResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.syncEmail)
                }
            }
        receiveValue: { [weak self] response in
            guard let self = self else { return }
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.listConnectedEmails(input: ListConnectedEmailsRequest(userId: Constants.getUserId()))
            
            if self.connectedEmails.count == 1 {
                self.isInlineSyncing = true
                self.inlineSyncingId = input.integrationId
                self.startInlinePolling(logId: response.data?.logId ?? "")
            } else {
                self.navigate(to: .emailSyncProgress(logId: response.data?.logId ?? ""))
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func emailSubscriptionsList(input: EmailSubscriptionsListRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.emailSubscriptionsList, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: VoiceSubscriptionResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.emailSubscriptionsList)
                    self?.showErrorPopup = true
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            if response.data == nil || response.data?.subscriptions?.count == 0
            {
                self?.showErrorPopup = true
            }
            else{
                NotificationCenter.default.post(name: .closeAllBottomSheets, object: nil)
                Constants.saveDefaults(value: response.providerLogoBaseUrl, key: Constants.providerBaseUrl)
                globalSubscriptionData = nil
                self?.router.navigate(to: .extractedSubscriptions(subscriptions: response.data?.subscriptions ?? [], fromEmailSync: false, integrationId: input.integrationId))
//                self.router.navigate(to: .subscriptionPreviewView(subscriptionsData: response.data?.subscriptions, content: "", isFromImage:false, isFromEmail: true, audioUrl: nil))
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func downloadLogAPI(input: ExportGmailSyncLogsRequest,showLoader:Bool = true) {
        apiReference.postApiData(endPoint: APIEndpoint.exportGmailSyncLogs, method: .POST,token: authKey,body: input,showLoader: showLoader)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.exportGmailSyncLogs)
                }
            }
        receiveValue: { [weak self] data in
            self?.saveDataToFile(data: data)
        }
        .store(in: &self.subscriptions)
    }
    
    private func saveDataToFile(data: Data) {
        let fileName = "GmailSyncLogs_\(Int(Date().timeIntervalSince1970)).xlsx"
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not find documents directory")
            return
        }
        
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            DispatchQueue.main.async {
                ToastManager.shared.showToast(message: "File saved successfully to Files app")
            }
        } catch {
            print("Error saving file: \(error)")
            DispatchQueue.main.async {
                ToastManager.shared.showToast(message: "Failed to save file", style: .error)
            }
        }
    }
    
    func deleteEmail(_ email: ListConnectedEmailsData) {
        connectedEmails.removeAll { $0.id == email.id ?? "" }
        deleteEmailAPI(input: DeleteEmailRequest(userId            : Constants.getUserId(),
                                                 integrationId     : email.id ?? ""))
    }
    
    func syncEmail(_ email: ListConnectedEmailsData) {
//        if email.type ?? 1 == 3 {
//            ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
//        }else{
            syncEmailAPI(input: SyncEmailRequest(userId         : Constants.getUserId(),
                                                 integrationId  : email.id ?? "",
                                                 type           : email.type ?? 1))
//        }
    }
    
    func syncingEmail(_ email: ListConnectedEmailsData) {
//        if email.type ?? 1 == 3 {
//            ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
//        }else{
            navigate(to: .emailSyncProgress(logId: email.syncLogId ?? ""))
//        }
    }
    
    func viewEmail(_ email: ListConnectedEmailsData) {
//        if email.type ?? 1 == 3 {
//            ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
//        }else{
            emailSubscriptionsList(input: EmailSubscriptionsListRequest(userId          : Constants.getUserId(),
                                                                        integrationId   : email.id ?? ""))
//        }
    }
    
    func downloadLogs(_ email: ListConnectedEmailsData) {
        downloadLogAPI(input: ExportGmailSyncLogsRequest(userId         : Constants.getUserId(),
                                                         integrationId  : email.id ?? ""))
    }
    
    // MARK: - Inline Polling Logic
    func startInlinePolling(logId: String) {
        self.fetchInlineSyncProgress(logId: logId)
        pollingCancellable = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchInlineSyncProgress(logId: logId)
            }
    }
    
    func stopInlinePolling() {
        pollingCancellable?.cancel()
        pollingCancellable = nil
    }
    
    func fetchInlineSyncProgress(logId: String) {
        let extraParams = "/\(logId)"
        apiReference.getApi(endPoint: .syncStatus, token: authKey, showLoader: false, extraParams: extraParams, responseType: SyncStatusResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error, endPoint: .syncStatus)
                    self?.stopInlinePolling()
                    self?.isInlineSyncing = false
                }
            } receiveValue: { [weak self] response in
                PrintLogger.modelLog(response, type: .response, isInput: false)
                self?.handleInlineSyncResponse(response)
            }
            .store(in: &subscriptions)
    }
    
    private func handleInlineSyncResponse(_ response: SyncStatusResponse) {
        guard let data = response.data else { return }
        self.inlineEmailsScanned = data.emailsAnalyzed ?? 0
        self.inlineSubscriptionsFound = data.subscriptionsFound ?? 0
        
        if data.syncStatus == "completed" {
            self.stopInlinePolling()
            self.isInlineSyncing = false
            self.inlineSyncingId = nil
            self.listConnectedEmails(input: ListConnectedEmailsRequest(userId: Constants.getUserId()))
            
            if (data.subscriptionsFound ?? 0) > 0 {
                emailSubscriptionsList(input: EmailSubscriptionsListRequest(userId: Constants.getUserId(), integrationId: data.integrationId ?? ""))
            }
        } else if data.syncStatus == "failed" {
            // User requested to keep UI and polling even on failure
            self.isInlineSyncing = true 
            // We keep polling every 3 seconds as requested
            // self.stopInlinePolling() // Commented out to continue polling if that's what's intended
            // self.isInlineSyncing = false // Commented out to keep UI visible
            // self.inlineSyncingId = nil // Commented out
            ToastManager.shared.showToast(message: "Email Syncing failed", style: .error)
            // self.listConnectedEmails(input: ListConnectedEmailsRequest(userId: Constants.getUserId()))
        }
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
