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
    
    private var subscriptions                   = Set<AnyCancellable>()
    var apiReference                            = NetworkRequest.shared
    @Published var voiceSubscriptionResponse    : VoiceSubscriptionResponse?
    
    func voiceSubscription(input:VoiceSubscriptionRequest,fileData:[MultiPartFileInput]){
        apiReference.postMultipartApi(endPoint: Endpoint.voiceSubscription, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: VoiceSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: Endpoint.voiceSubscription)
                }
            }
        receiveValue: { [unowned self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            voiceSubscriptionResponse = response
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : Endpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
