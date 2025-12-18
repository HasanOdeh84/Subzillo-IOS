//
//  VoiceCommandViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/09/25.
//

import Foundation
import Combine
import AVFAudio
import AVFoundation
import SwiftUICore
class VoiceCommandViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    static let shared                           = VoiceCommandViewModel()
    private var subscriptions                   = Set<AnyCancellable>()
    var apiReference                            = NetworkRequest.shared
    private let router                          : AppIntentRouter
    @Published var showErrorPopup               : Bool = false
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func voiceSubscription(input:VoiceSubscriptionRequest,fileData:[MultiPartFileInput], audioUrl: URL?){
        apiReference.postMultipartApi(endPoint: APIEndpoint.voiceSubscription, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: VoiceSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.voiceSubscription)
                    self.showErrorPopup = true
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            if response.data?.subscriptions?.count == 0
            {
                self.showErrorPopup = true
            }
            else{
                Constants.saveDefaults(value: response.providerLogoBaseUrl, key: Constants.providerBaseUrl)
                globalSubscriptionData = nil // i have added because previous data is displaying instead of new one
                self.router.navigate(to: .subscriptionPreviewView(subscriptionsData: response.data?.subscriptions, content: "", isFromImage:false, audioUrl: audioUrl))
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func textSubscription(input:TextSubscriptionRequest, fromSiri:Bool = false) async -> Bool {//(success: Bool, popup: Bool) {
        await withCheckedContinuation { continuation in
            apiReference.postApi(endPoint: APIEndpoint.textSubscription, method: .POST,token: authKey,body: input,showLoader: true, responseType: VoiceSubscriptionResponse.self, fromSiri: fromSiri)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    if case let .failure(error) = completion {
                        self.handleError(error,endPoint: APIEndpoint.textSubscription)
                        continuation.resume(returning: false)
                    }
                }
            receiveValue: { [weak self] response in
                guard let self = self else { return }
                PrintLogger.modelLog(response, type: .response, isInput: false)
                if response.data?.subscriptions?.count == 0
                {
//                    self.showErrorPopup = true
                    continuation.resume(returning: false)
                }
                else{
                    Constants.saveDefaults(value: response.providerLogoBaseUrl, key: Constants.providerBaseUrl)
                    globalSubscriptionData = nil // i have added because previous data is displaying instead of new one
                    self.router.navigate(to: .subscriptionPreviewView(subscriptionsData: response.data?.subscriptions, content: "", isFromImage:false, audioUrl: nil))
                    continuation.resume(returning: true)
                }
            }
            .store(in: &self.subscriptions)
        }
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
