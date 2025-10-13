//
//  ProfileViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 09/10/25.
//

import Foundation
import Combine
import SwiftUICore
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    private var subscriptions           = Set<AnyCancellable>()
    var apiReference                    = NetworkRequest.shared
    
    func updateUserInfo(input:UpdateUserInfoRequest) {
        apiReference.postApi(endPoint: APIEndpoint.updateUserInfo, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.updateUserInfo)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
        }
        .store(in: &self.subscriptions)
    }
    
    func updatePassword(input:UpdatePasswordRequest) {
        apiReference.postApi(endPoint: APIEndpoint.updatePassword, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.updatePassword)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
        }
        .store(in: &self.subscriptions)
    }
    
    func updateProfileImage(input:UpdateProfileImageRequest,fileData:[MultiPartFileInput]){
        apiReference.postMultipartApi(endPoint: APIEndpoint.updateProfileImage, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.updateProfileImage)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
        }
        .store(in: &self.subscriptions)
    }   
    
    func imageSubscription(input:ImageSubscriptionRequest,fileData:[MultiPartFileInput]){
        apiReference.postMultipartApi(endPoint: APIEndpoint.imageSubscription, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: ImageSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.imageSubscription)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
