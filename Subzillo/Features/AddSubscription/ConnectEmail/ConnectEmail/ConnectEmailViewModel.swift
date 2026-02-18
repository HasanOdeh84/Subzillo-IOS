//
//  ConnectEmailViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/01/26.
//

import Combine
import SwiftUI
import SwiftUICore
import UIKit

class ConnectEmailViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    var apiReference                                = NetworkRequest.shared
    private let router                              : AppIntentRouter
    private let sessionManager                      : SessionManager
    @Published var oauthUrlResponse                 : OauthUrlData?
    @Published var isSuccess                        : Bool = false
    
    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared){
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func oauthUrl(input:OauthUrlRequest) {
        isSuccess = false
        apiReference.postApi(endPoint: APIEndpoint.OauthUrl, method: .POST,token: authKey,body: input,showLoader: true, responseType: OauthUrlResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.OauthUrl)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
//            ToastManager.shared.showToast(message: response.message ?? "")
            self.oauthUrlResponse = response.data
            self.isSuccess = true
        }
        .store(in: &self.subscriptions)
    }
    
    func gmailOauthCallBack(input:GmailOauthCallBackRequest) {
        apiReference.postApi(endPoint: APIEndpoint.oauthCallback, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.oauthCallback)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.navigate(to: NavigationRoute.connectedEmailsList(isIntegrations: false))
        }
        .store(in: &self.subscriptions)
    }
    
    func microsoftOauthCallBack(input:GmailOauthCallBackRequest) {
        apiReference.postApi(endPoint: APIEndpoint.oauthCallback, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.oauthCallback)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
//            ToastManager.shared.showToast(message: response.message ?? "Microsoft email connected successfully")
        }
        .store(in: &self.subscriptions)
    }
    
    func handleOAuthCallback(url: URL) {
        print("OAuth Callback URL: \(url.absoluteString)")
        if url.absoluteString.contains("oauth-error"){
            ToastManager.shared.showToast(message: "Microsoft account connection failed")
        }else if url.absoluteString.contains("oauth-success"){
            ToastManager.shared.showToast(message: "Microsoft account connected successfully")
            navigate(to: .connectedEmailsList(isIntegrations: false))
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
