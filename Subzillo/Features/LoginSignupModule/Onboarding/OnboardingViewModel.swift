//
//  OnboardingViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 08/11/25.
//

import Combine
import SwiftUI

class OnboardingViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    private let router                  : AppIntentRouter
    private let sessionManager          : SessionManager

    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared) {
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func updateOnboarding(input:UpdateOnboardingRequest) {
        apiReference.postApi(endPoint: APIEndpoint.updateOnboarding, method: .POST, token: authKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.updateOnboarding)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            AppState.shared.login()
            router.navigate(to: .home)
        }
        .store(in: &self.subscriptions)
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
