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
    
    //Missing details
    @Published var storedSubscriptions              : [SubscriptionData] = []
    @Published var missingDetailsList               : [MissingDetails] = []
    @Published var attemptCount                     : Int = 1
    var maxAttempts                                 : Int = 0
    @Published var showMissingDetailsBottomSheet    : Bool = false
    @Published var recordedAudioURLs                : [URL] = []
    @Published var mergedAudioURL                   : URL?
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func voiceSubscription(input:VoiceSubscriptionRequest,fileData:[MultiPartFileInput], audioUrl: URL?){//, attempt: Int){
        if let url = audioUrl{
            print("audio url is \(url)")
        }
        apiReference.postMultipartApi(endPoint: APIEndpoint.voiceSubscription, method: .POST,token: authKey,body: MultipartInput(parameters: input, fileInput: fileData),showLoader: true, responseType: VoiceSubscriptionResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.voiceSubscription)
                    self.showErrorPopup = true
                }
            }
        receiveValue: { [self] response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            //            if response.data?.subscriptions?.count == 0
            //            {
            //                self.showErrorPopup = true
            //            }
            //            else{
            //                Constants.saveDefaults(value: response.providerLogoBaseUrl, key: Constants.providerBaseUrl)
            //                globalSubscriptionData = nil // i have added because previous data is displaying instead of new one
            //                self.router.navigate(to: .subscriptionPreviewView(subscriptionsData: response.data?.subscriptions, content: "", isFromImage:false, audioUrl: audioUrl))
            //            }
            
            guard let data = response.data,
                  let subs = data.subscriptions,
                  !subs.isEmpty else {
                if storedSubscriptions.isEmpty{
                    self.showErrorPopup = true
                }else{
                    if attemptCount > response.data?.userFinalRecordingCount ?? 0 {
                        showMissingDetailsBottomSheet = false
                        router.navigate(
                            to: .subscriptionPreviewView(
                                subscriptionsData   : storedSubscriptions,
                                content             : "",
                                isFromImage         : false,
                                audioUrl            : mergedAudioURL
                            )
                        )
                        return
                    }else{
                        attemptCount += 1
                        print("attemptCount \(attemptCount)")
                        print("Stored subscriptions \(storedSubscriptions)")
                        showMissingDetailsBottomSheet = true
                    }
                }
                return
            }
            Constants.saveDefaults(value: response.providerLogoBaseUrl, key: Constants.providerBaseUrl)
            if let audioUrl {
                if attemptCount == 1{
                    print("added url \(attemptCount)")
                    mergedAudioURL = audioUrl
                    //                    recordedAudioURLs.append(audioUrl)
                }
            }
            globalSubscriptionData = nil // i have added because previous data is displaying instead of new one
            self.handleResponse(
                subscriptions: subs,
                userFinalRecordingCount: data.userFinalRecordingCount ?? 0,
                audioUrl: audioUrl
            )
        }
        .store(in: &self.subscriptions)
    }
    
    func mergeSubscriptions(
        old: [SubscriptionData],
        new: [SubscriptionData]
    ) -> [SubscriptionData] {
        var updated = old
        for newSub in new {
            if let index = updated.firstIndex(where: {
                $0.serviceName == newSub.serviceName
            }) {
                var existing = updated[index]
                //                if existing.amount == nil {
                //                    existing.amount = newSub.amount
                //                }
                //                if existing.categoryName == nil {
                //                    existing.categoryName = newSub.categoryName
                //                }
                //                if existing.subscriptionType == nil {
                //                    existing.subscriptionType = newSub.subscriptionType
                //                }
                //                if existing.billingCycle == nil {
                //                    existing.billingCycle = newSub.billingCycle
                //                }
                if newSub.amount != nil {
                    existing.amount = newSub.amount
                }
                if newSub.categoryName != nil {
                    existing.categoryName = newSub.categoryName
                }
                if newSub.subscriptionType != nil {
                    existing.subscriptionType = newSub.subscriptionType
                }
                if newSub.billingCycle != nil {
                    existing.billingCycle = newSub.billingCycle
                }
                updated[index] = existing
            } else {
                // Completely new subscription
                updated.append(newSub)
            }
        }
        return updated
    }
    
    func handleResponse(
        subscriptions: [SubscriptionData],
        userFinalRecordingCount: Int,
        audioUrl: URL?
    ) {
        
        attemptCount += 1
        maxAttempts = userFinalRecordingCount
        
        if storedSubscriptions.isEmpty {
            // First API call
            storedSubscriptions = subscriptions
        } else {
            // Subsequent calls → merge
            storedSubscriptions = mergeSubscriptions(
                old: storedSubscriptions,
                new: subscriptions
            )
        }
        
        //        let hasMissing = storedSubscriptions.contains {
        //            !$0.hasAllRequiredFields()
        //        }
        
        missingDetailsList.removeAll()
        
        for sub in storedSubscriptions {
            let missingFields = sub.missingRequiredFields()
            
            if !missingFields.isEmpty {
                let item = MissingDetails(
                    title: sub.serviceName ?? "Unknown service",
                    description: missingFields.joined(separator: ", ")
                )
                missingDetailsList.append(item)
            }
        }
        
        let hasMissing = !missingDetailsList.isEmpty
        
        // NAVIGATION RULES
        if !hasMissing {
            // All fields filled
            showMissingDetailsBottomSheet = false
            router.navigate(
                to: .subscriptionPreviewView(
                    subscriptionsData   : storedSubscriptions,
                    content             : "",
                    isFromImage         : false,
                    audioUrl            : mergedAudioURL
                )
            )
            return
        }
        
        if attemptCount > maxAttempts {
            // Attempts exceeded → navigate anyway
            showMissingDetailsBottomSheet = false
            router.navigate(
                to: .subscriptionPreviewView(
                    subscriptionsData   : storedSubscriptions,
                    content             : "",
                    isFromImage         : false,
                    audioUrl            : mergedAudioURL
                )
            )
            return
        }
        
        // Still missing + attempts left → show bottom sheet
        print("attemptCount \(attemptCount)")
        print("Stored subscriptions \(storedSubscriptions)")
        showMissingDetailsBottomSheet = true
    }
    
    func resetVoiceFlow() {
        storedSubscriptions.removeAll()
        missingDetailsList.removeAll()
        attemptCount = 1
        maxAttempts = 0
        showMissingDetailsBottomSheet = false
        recordedAudioURLs.removeAll()
        mergedAudioURL = nil
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
