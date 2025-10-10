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
        apiReference.postApi(endPoint: Endpoint.updateUserInfo, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.updateUserInfo)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
        }
        .store(in: &self.subscriptions)
    }
    
    func updatePassword(input:UpdatePasswordRequest) {
        apiReference.postApi(endPoint: Endpoint.updatePassword, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.updatePassword)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            ToastManager.shared.showToast(message: response.message ?? "")
        }
        .store(in: &self.subscriptions)
    }
    
    func updateProfileImage(input:UpdateProfileImageRequest,fileData:[MultiPartFileInput]){
        apiReference.postMultipartApi(endPoint: Endpoint.updateProfileImage, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.updateProfileImage)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
        }
        .store(in: &self.subscriptions)
    }   
    
    func imageSubscription(input:ImageSubscriptionRequest,fileData:[MultiPartFileInput]){
        apiReference.postMultipartApi(endPoint: Endpoint.imageSubscription, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: ImageSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.imageSubscription)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : Endpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
