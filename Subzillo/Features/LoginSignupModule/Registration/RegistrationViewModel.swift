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
    
    func register(input:RegisterRequest, path: Binding<NavigationPath>) {
        apiReference.postApi(endPoint: APIEndpoint.registration, method: .POST,token: defaultAuthKey,body: input,showLoader: true, responseType: RegisterResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.registration)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            KeychainHelper.save(response.data?.accessToken, account: Constants.authKey)
            KeychainHelper.save(response.data?.refreshToken, account: Constants.refreshKey)
            Constants.saveDefaults(value: response.data?.id, key: Constants.userId)
            Constants.saveDefaults(value: response.data?.username, key: Constants.username)
            self.registerResponse = response
            DispatchQueue.main.async {
                path.wrappedValue.append(PendingRoute.verifyOtp(emailId:input.email, from: .register))
            }
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
