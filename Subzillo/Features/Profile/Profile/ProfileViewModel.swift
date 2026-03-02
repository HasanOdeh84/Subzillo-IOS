//
//  ProfileViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 09/10/25.
//

import Foundation
import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    private let router                  : AppIntentRouter
    @Published var isUpdate             = false
    @Published var isProfileUpdate      = false
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func updateProfile(input:UpdateProfileRequest) {
        isUpdate = false
        apiReference.postApi(endPoint: APIEndpoint.updateProfile, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.updateProfile)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.isUpdate = true
        }
        .store(in: &self.subscriptions)
    }
    
    func updateProfileImage(input:UpdateProfileImageRequest,fileData:[MultiPartFileInput]){
        isProfileUpdate = false
        apiReference.postMultipartApi(endPoint: APIEndpoint.updateProfileImage, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: false, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.updateProfileImage)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
            self.isProfileUpdate = true
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
