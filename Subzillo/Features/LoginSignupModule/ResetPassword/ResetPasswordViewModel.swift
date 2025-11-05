//
//  ResetPasswordViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 25/09/25.
//

import Combine
import SwiftUICore
import SwiftUI

class ResetPasswordViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var resetResponse        : GeneralResponse?
    private let router                  : AppIntentRouter
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func resetPassword(input:ResetPasswordRequest, path: Binding<NavigationPath>) {
        apiReference.postApi(endPoint: APIEndpoint.resetPassword, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.resetPassword)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.resetResponse = response
            DispatchQueue.main.async {
                path.wrappedValue.append(PendingRoute.login)
            }
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
