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
    
    func verifyOtp(input:OtpVerifyRequest, path: Binding<NavigationPath>,from:ToVerify?) {
        apiReference.postApi(endPoint: Endpoint.verifyOtp, method: .POST, token: defaultAuthKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.verifyOtp)
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
        apiReference.postApi(endPoint: Endpoint.resendOtp, method: .POST, token: defaultAuthKey, body: input, showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.resendOtp)
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
    func handleError(_ apiError: APIError, endPoint : Endpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
