//
//  OtpVerificationViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 24/09/25.
//

import Combine
import SwiftUICore
import SwiftUI

class OtpVerifyViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    @Published var otpVerifyResponse    : GeneralResponse?
    @Published var resendOtpResponse    : Bool = false
    private let router                  : AppIntentRouter
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func verifyOtp(input:OtpVerifyRequest, path: Binding<NavigationPath>,from:ToVerify?) {
        apiReference.postApi(endPoint: APIEndpoint.verifyOtp, method: .POST, token: defaultAuthKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.verifyOtp)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.otpVerifyResponse = response
            DispatchQueue.main.async {
                if from == .forgot{
                    path.wrappedValue.append(PendingRoute.resetPassword(username: input.username))
                }else{
                    AppState.shared.login()
                    path.wrappedValue.append(PendingRoute.home)
                }
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func resendOtp(input:ResendOtpRequest) {
        apiReference.postApi(endPoint: APIEndpoint.resendOtp, method: .POST, token: defaultAuthKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.resendOtp)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.resendOtpResponse = true
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
