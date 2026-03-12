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
    var pendingTransaction                          : Transaction?
    private var isRetrying                          = false
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
        self.pricingPlans = []
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
        savePendingSubscribePlan(input)
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
            self.isRetrying = false
            if case .failure(let error) = completion {
                self.handleError(error, endPoint: .subscribePlan)
            }
        } receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.isSubscribe = true
            Constants.saveDefaults(value: false, key: Constants.subscribeApiFail)
            self.clearPendingSubscribePlan()
            if let transaction = self.pendingTransaction {
                Task {
                    await transaction.finish()
                    await StoreManager.shared.updatePurchasedProducts()
                }
                self.pendingTransaction = nil
            }
            else if let transactionId = UInt64(input.transactionId) {
                // If it was a retry from a previous session, find and finish it
                Task {
                    for await result in Transaction.unfinished {
                        if case .verified(let transaction) = result, transaction.id == transactionId {
                            await transaction.finish()
                            await StoreManager.shared.updatePurchasedProducts()
                            print("[PricingPlansViewModel] Result: Finished unfinished transaction \(transactionId)")
                            break
                        }
                    }
                }
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func cancelPurchase() {
        self.isSubscribe = false
        self.isRetrying = false
        Constants.saveDefaults(value: false, key: Constants.subscribeApiFail)
        self.clearPendingSubscribePlan()
        self.pendingTransaction = nil
    }
    
    // MARK: - Pending SubscribePlan persistence helpers
    func savePendingSubscribePlan(_ input: SubscribePlanRequest) {
        if let data = try? JSONEncoder().encode(input) {
            Constants.saveDefaults(value: data, key: Constants.pendingSubscribePlan)
        }
    }
    
    // MARK: - Persistence helpers
    func loadPendingSubscribePlan() -> SubscribePlanRequest? {
        guard let data = UserDefaults.standard.data(forKey: Constants.pendingSubscribePlan),
              let request = try? JSONDecoder().decode(SubscribePlanRequest.self, from: data) else {
            return nil
        }
        return request
    }
    
    func clearPendingSubscribePlan() {
        Constants.removeDefaults(key: Constants.pendingSubscribePlan)
    }
    
    // Retry the subscribePlan API if a previous attempt failed.
    func retryPendingSubscribePlanIfNeeded() {
        retryIfNeeded()
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
    
    func retryIfNeeded() {
        guard !isRetrying else { return }
        let hasFailed = Constants.getUserDefaultsBooleanValue(for: Constants.subscribeApiFail)
        guard hasFailed, let pending = loadPendingSubscribePlan() else { return }
        // Ensure we are logged in and not currently processing another IAP in the UI
        if AppState.shared.isLoggedIn {
            isRetrying = true
            print("[PricingPlansViewModel] Retrying pending subscribePlan...")
            subscribePlan(input: pending)
        }
    }
}
