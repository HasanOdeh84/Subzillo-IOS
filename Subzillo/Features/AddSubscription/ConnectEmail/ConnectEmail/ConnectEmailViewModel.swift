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
    
    func handleOAuthCallback(url: URL) {
        // Here you can handle the redirect URL if there's any logic needed
        // For example, extracting tokens or verifying the state
        print("OAuth Callback URL: \(url.absoluteString)")
        // Typically you might refresh the connected emails list here
        ToastManager.shared.showToast(message: "Email connection initiated")
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
