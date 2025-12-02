//
//  UploadImageViewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 13/11/25.
//

import Foundation
import Combine
import SwiftUICore
import SwiftUI

class UploadImageViewModel: ObservableObject {
    
    private var subscriptions                   = Set<AnyCancellable>()
    var apiReference                            = NetworkRequest.shared
    private let router                          : AppIntentRouter
    @Published var showErrorPopup               : Bool = false
    @Published var hideLoader                   : Bool = false
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func imageSubscription(input:UpdateProfileImageRequest,fileData:[MultiPartFileInput]) {
        apiReference.postMultipartApi(endPoint: APIEndpoint.imageSubscription, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: false, responseType: VoiceSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.imageSubscription)
                    self.showErrorPopup = true
                }
                self.hideLoader = true
            }
        receiveValue: { response in
            self.hideLoader = true
            PrintLogger.modelLog(response, type: .response, isInput: false)
            if response.data?.subscriptions?.count == 0
            {
                self.showErrorPopup = true
            }
            else{
                self.router.navigate(to: .subscriptionPreviewView(subscriptionsData: response.data?.subscriptions, content: "", isFromImage:true, audioUrl: nil))
            }
           // self.router.navigate(to: .subscriptionPreviewView(subscriptionsData: response.data?.subscriptions, content: "", isFromImage:true))
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
