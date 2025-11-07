//
//  RegistrationViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import Combine
import SwiftUICore
import SwiftUI  

class RegistrationViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var registerResponse     : RegisterResponse?
    private let router                  : AppIntentRouter
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func register(input:RegisterRequest) {
        apiReference.postApi(endPoint: APIEndpoint.registration, method: .POST,token: authKey,body: input,showLoader: true, responseType: RegisterResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.registration)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.registerResponse = response
            DispatchQueue.main.async { [self] in
                router.navigate(to: .verifyOtp(fromLogin: false))
//                router.navigate(to: .SuccessView(isOtp: false))
            }
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
