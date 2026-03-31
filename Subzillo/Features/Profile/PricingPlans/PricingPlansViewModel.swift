//
//  PricingPlansViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 19/02/26.
//

import StoreKit
import Combine

class PricingPlansViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    var apiReference                                = NetworkRequest.shared
    @Published var pricingPlans                     : [PricingPlan] = []
    @Published var pricingPlanResponse              : PricingPlanResponse?
    private let router                              : AppIntentRouter
    private let sessionManager                      : SessionManager
    @Published var isSubscribe                      : Bool = false
    static let shared                               = PricingPlansViewModel()
    
    init(router: AppIntentRouter = .shared,sessionManager: SessionManager = .shared){
        self.router = router
        self.sessionManager = sessionManager
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - API Calls
    func listPricingPlans(type:Int) {
        let request = PricingPlanRequest(userId : Constants.getUserId(),
                                         type   : type)
        self.apiReference.postApi(
            endPoint    : .listPricingPlans,
            method      : .POST,
            token       : authKey,
            body        : request,
            showLoader  : true,
            responseType: PricingPlanResponse.self
        )
        .sink { completion in
            if case .failure(let error) = completion {
                self.handleError(error, endPoint: .listPricingPlans)
            }
        } receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.pricingPlans = []
            if let plans = response.data {
                self.pricingPlans = plans.plans ?? []
            }
            self.pricingPlanResponse = response
        }
        .store(in: &self.subscriptions)
    }
    
    func subscribePlan(input: SubscribePlanRequest) {
        print("Plan ID: \(input.pricingPlanId), Transaction ID: \(input.transactionId)")
        isSubscribe = false
        Constants.saveDefaults(value: true, key: Constants.subscribeApiFail)
        self.apiReference.postApi(
            endPoint    : .subscribePlan,
            method      : .POST,
            token       : authKey,
            body        : input,
            showLoader  : true,
            responseType: GeneralResponse.self
        )
        .sink { completion in
            if case .failure(let error) = completion {
                self.handleError(error, endPoint: .subscribePlan)
            }
        } receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.isSubscribe = true
        }
        .store(in: &self.subscriptions)
    }
    
    // MARK: - Pre-payment Check API
    func checkOriginalTransactionIdUniqueness(originalId: String, completion: @escaping (Bool) -> Void) {
        let request = CheckTransactionRequest(originalTransactionId: originalId)
        self.apiReference.postApi(
            endPoint    : .checkInAppTransaction,
            method      : .POST,
            token       : authKey,
            body        : request,
            showLoader  : true,
            responseType: CheckTransactionResponse.self
        )
        .sink { completionStatus in
            if case .failure(let error) = completionStatus {
                self.handleError(error, endPoint: .checkInAppTransaction)
                completion(false) // Assume failure on API error for safety
            }
        } receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            let backendUserId = response.data?.userId ?? ""
            let currentUserId = Constants.getUserId()
            if backendUserId == "" || backendUserId == currentUserId {
                completion(true)
            } else {
                AlertManager.shared.showAlert(
                    title   : "Subscription Alert",
                    message : "This Apple ID is already linked to another Subzillo account. Please use the original account or a different Apple ID."
                )
                completion(false)
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func runPrePaymentCheck(completion: @escaping (Bool) -> Void) {
        Task {
            
            var originalId = ""
            if #available(iOS 15.0, *) {
                for await result in Transaction.all {
                    if case .verified(let transaction) = result {
                        originalId = String(transaction.originalID)
                        break
                    }
                }
            }
            
            if originalId == ""{
                // No past transactions found for this Apple ID, safe to proceed
                completion(true)
                return
            } else {
                // Check with backend
                await MainActor.run {
                    self.checkOriginalTransactionIdUniqueness(originalId: originalId, completion: completion)
                }
            }
        }
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}
