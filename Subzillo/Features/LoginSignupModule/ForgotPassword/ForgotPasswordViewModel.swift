//
//  ForgotPasswordViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 25/09/25.
//

import Combine
import SwiftUI

class ForgotPasswordViewModel: ObservableObject {
    
    //MARK: - Properties
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var forgotResponse       : GeneralResponse?
    private let router                  : AppIntentRouter
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func forgotPassword(input:ForgotPasswordRequest) {
//        apiReference.postApi(endPoint: APIEndpoint.forgotPassword, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: GeneralResponse.self)
//            .sink { [unowned self] completion in
//                if case let .failure(error) = completion {
//                    self.handleError(error,endPoint: APIEndpoint.forgotPassword)
//                }
//            }
//        receiveValue: { [unowned self] response in
//            PrintLogger.modelLog(response, type: .response, isInput: false)
//            ToastManager.shared.showToast(message: response.message ?? "")
//            self.forgotResponse = response
//            DispatchQueue.main.async {
////                self.router.navigate(to: .verifyOtp(emailId: "", from: .forgot, username: input.username))
//            }
//        }
//        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
