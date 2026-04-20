//
//  ConnectEmailViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/01/26.
//

import Combine
import SwiftUI
import UIKit

class ConnectEmailViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    var apiReference                                = NetworkRequest.shared
    private let router                              : AppIntentRouter
//    private let sessionManager                      : SessionManager
    @Published var oauthUrlResponse                 : OauthUrlData?
    @Published var isSuccess                        : Bool = false
    @Published var isIcloudSuccess                  : Bool = false
    @Published var isGmailSuccess                   : Bool = false
    @Published var isManualICloudSuccess            : Bool = false
    @Published var showReconnectSheet               : Bool = false
    
    init(router: AppIntentRouter = .shared){
        self.router = router
//        self.sessionManager = sessionManager
    }
    
    func oauthUrl(input:OauthUrlRequest) {
        isSuccess = false
        isIcloudSuccess = false
        apiReference.postApi(endPoint: APIEndpoint.OauthUrl, method: .POST,token: authKey,body: input,showLoader: true, responseType: OauthUrlResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.OauthUrl)
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
//            ToastManager.shared.showToast(message: response.message ?? "")
            self?.oauthUrlResponse = response.data
            if input.type == 2{
                self?.isSuccess = true
            }else if input.type == 3{
                self?.isIcloudSuccess = true
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func gmailOauthCallBack(input:GmailOauthCallBackRequest) {
        apiReference.postApi(endPoint: APIEndpoint.oauthCallback, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.oauthCallback)
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self?.isGmailSuccess = true
//            self?.navigate(to: NavigationRoute.connectedEmailsList(isIntegrations: false))
        }
        .store(in: &self.subscriptions)
    }
    
    func microsoftOauthCallBack(input:GmailOauthCallBackRequest) {
        apiReference.postApi(endPoint: APIEndpoint.oauthCallback, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.oauthCallback)
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
//            ToastManager.shared.showToast(message: response.message ?? "Microsoft email connected successfully")
        }
        .store(in: &self.subscriptions)
    }
    
    func handleOAuthCallback(url: URL, type:Int = 2) {
        print("OAuth Callback URL: \(url.absoluteString)")
        if url.absoluteString.contains("oauth-error"){
            ToastManager.shared.showToast(message: type == 2 ? "Microsoft account connection failed" : "iCloud account connection failed", style: .error)
        }else if url.absoluteString.contains("oauth-success"){
            ToastManager.shared.showToast(message: type == 2 ? "Microsoft account connected successfully" : "iCloud account connected successfully")
//            navigate(to: .connectedEmailsList(isIntegrations: false))
        }
    }
    
    func iCloudConnect(input:ICloudConnectRequest) {
        apiReference.postApi(endPoint: APIEndpoint.iCloudConnect, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error,endPoint: APIEndpoint.iCloudConnect)
                }
            }
        receiveValue: { [weak self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self?.isManualICloudSuccess = true
//            AppIntentRouter.shared.navigateAndReplace(to: NavigationRoute.connectedEmailsList(isIntegrations: false))
        }
        .store(in: &self.subscriptions)
    }

    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
        if apiError == .reauthenticationRequired && endPoint == .oauthCallback {
            self.showReconnectSheet = true
        }
    }
}
