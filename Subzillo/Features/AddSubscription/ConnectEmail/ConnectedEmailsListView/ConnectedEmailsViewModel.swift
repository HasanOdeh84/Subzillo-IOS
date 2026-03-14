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
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.listConnectedEmails)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.connectedEmails = response.data ?? []
        }
        .store(in: &self.subscriptions)
    }
    
    func deleteEmailAPI(input: DeleteEmailRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.deleteEmail, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.deleteEmail)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
        }
        .store(in: &self.subscriptions)
    }
    
    func syncEmailAPI(input: SyncEmailRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.syncEmail, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: SyncEmailResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.syncEmail)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.listConnectedEmails(input: ListConnectedEmailsRequest(userId: Constants.getUserId()))
            navigate(to: .emailSyncProgress(logId: response.data?.logId ?? ""))
        }
        .store(in: &self.subscriptions)
    }
    
    func emailSubscriptionsList(input: EmailSubscriptionsListRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.emailSubscriptionsList, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: VoiceSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.emailSubscriptionsList)
                    self.showErrorPopup = true
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            if response.data == nil || response.data?.subscriptions?.count == 0
            {
                self.showErrorPopup = true
            }
            else{
                NotificationCenter.default.post(name: .closeAllBottomSheets, object: nil)
                Constants.saveDefaults(value: response.providerLogoBaseUrl, key: Constants.providerBaseUrl)
                globalSubscriptionData = nil
                self.router.navigate(to: .extractedSubscriptions(subscriptions: response.data?.subscriptions ?? [], fromEmailSync: false))
//                self.router.navigate(to: .subscriptionPreviewView(subscriptionsData: response.data?.subscriptions, content: "", isFromImage:false, isFromEmail: true, audioUrl: nil))
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func downloadLogAPI(input: ExportGmailSyncLogsRequest,showLoader:Bool = true) {
        apiReference.postApiData(endPoint: APIEndpoint.exportGmailSyncLogs, method: .POST,token: authKey,body: input,showLoader: showLoader)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.exportGmailSyncLogs)
                }
            }
        receiveValue: { [unowned self] data in
            self.saveDataToFile(data: data)
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
        deleteEmailAPI(input: DeleteEmailRequest(userId         : Constants.getUserId(),
                                                 integrationId     : email.id ?? ""))
    }
    
    func syncEmail(_ email: ListConnectedEmailsData) {
        syncEmailAPI(input: SyncEmailRequest(userId         : Constants.getUserId(),
                                             integrationId  : email.id ?? "",
                                             type           : email.type ?? 1))

    }
    
    func viewEmail(_ email: ListConnectedEmailsData) {
        emailSubscriptionsList(input: EmailSubscriptionsListRequest(userId          : Constants.getUserId(),
                                                                    integrationId   : email.id ?? ""))
    }
    
    func downloadLogs(_ email: ListConnectedEmailsData) {
        downloadLogAPI(input: ExportGmailSyncLogsRequest(userId         : Constants.getUserId(),
                                                         integrationId  : email.id ?? ""))
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
