//
//  NotificationsViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//

import Foundation
import Combine

class NotificationsViewModel: ObservableObject {
    
    private var subscriptions               = Set<AnyCancellable>()
    var apiReference                        = NetworkRequest.shared
    private let router                      : AppIntentRouter
    @Published var notificationsList        : [NotificationData] = []
    @Published var notificationData         : NotificationsListResponseData?
    @Published var unreadCount              : Int = 0
    @Published var isLoading                : Bool = false
    private var currentPage                 : Int = 0
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
//        notificationsList.append(NotificationData(id: "1", title: "Hi", message: "Okay bye", readStatus: true, isSelected: false))
    }
    
    func notificationsListApi() {
        let input = NotificationsListRequest(userId: Constants.getUserId(), page: currentPage)
        if currentPage == 0{
            notificationsList.removeAll()
        }
        apiReference.postApi(endPoint: APIEndpoint.notificationsList, method: .POST, token: authKey, body: input, showLoader: true, responseType: NotificationsListResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error, endPoint: APIEndpoint.notificationsList)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.notificationData = response.data
            self.notificationsList.append(contentsOf: response.data?.notifications ?? [])
            //            self.notificationsList.append(NotificationData(id: "1", title: "ok", message: "bye", readStatus: false, isSelected: false, createdAt: "12/23/34"))
            self.updateUnreadCount()
        }
        .store(in: &self.subscriptions)
    }
    
    func loadMore() {
        currentPage += 1
        notificationsListApi()
    }
    
    func deleteNotificationAPI(input: DeleteNotificationRequest) {
        apiReference.postApi(endPoint: APIEndpoint.deleteNotification, method: .POST, token: authKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error, endPoint: APIEndpoint.deleteNotification)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            currentPage = 0
            notificationsList.removeAll()
            notificationsListApi()
        }
        .store(in: &self.subscriptions)
    }
    
    func deleteNotifications(ids: [String]) {
        notificationsList.removeAll { ids.contains($0.id) }
        deleteNotificationAPI(input: DeleteNotificationRequest(userId: Constants.getUserId(), notificationIds: ids))
        updateUnreadCount()
    }
    
    func markNotificationReadAPI(input: MarkNotificationReadRequest) {
        apiReference.postApi(endPoint: APIEndpoint.markNotificationRead, method: .POST, token: authKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error, endPoint: APIEndpoint.markNotificationRead)
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            currentPage = 0
            notificationsList.removeAll()
            notificationsListApi()
        }
        .store(in: &self.subscriptions)
    }
    
    func markAllAsRead() {
        for i in 0..<notificationsList.count {
            notificationsList[i].readStatus = true
        }
        unreadCount = 0
        let input = MarkNotificationReadRequest(userId: Constants.getUserId(), notificationId: "", type: 1)
        markNotificationReadAPI(input: input)
    }
    
    func markAsRead(id: String) {
        if let index = notificationsList.firstIndex(where: { $0.id == id }) {
            if notificationsList[index].readStatus == false{
                notificationsList[index].readStatus = true
                let input = MarkNotificationReadRequest(userId: Constants.getUserId(), notificationId: id, type: 2)
                markNotificationReadAPI(input: input)
            }
            switch notificationsList[index].type ?? 0{
            case 1:  navigate(to: .connectedEmailsList(isIntegrations: false))
            case 2:  navigate(to: .subscriptionMatchView(fromList: true, subscriptionId: notificationsList[index].subscriptionId ?? ""))
            case 3:  navigate(to: .pricingPlans())//removed as now, we don't have this type
            default:
                break
            }
        }
    }
    
    private func updateUnreadCount() {
        unreadCount = notificationData?.totalCount ?? 0//notificationsList.filter { !($0.readStatus ?? false) }.count
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
    
    var isAllLoaded: Bool {
//        guard let totalCount = notificationData?.totalCount else { return false }
//        return notificationsList.count >= totalCount
        guard let totalPageCount = notificationData?.totalPages else { return false }
        return currentPage >= totalPageCount
    }
}
