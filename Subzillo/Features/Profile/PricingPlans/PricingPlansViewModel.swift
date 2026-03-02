//
//  PricingPlansViewModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 19/02/26.
//

import Foundation
import Combine

class PricingPlansViewModel: ObservableObject {
    
    private var subscriptions                       = Set<AnyCancellable>()
    var apiReference                                = NetworkRequest.shared
    @Published var pricingPlans                     : [PricingPlan] = []
    private let router                              : AppIntentRouter
    private let sessionManager                      : SessionManager
    @Published var isSubscribe                      : Bool = false
    
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
                self.pricingPlans = plans
            }
        }
        .store(in: &self.subscriptions)
    }
    
    func subscribePlan(input: SubscribePlanRequest) {
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
            if case .failure(let error) = completion {
                self.handleError(error, endPoint: .subscribePlan)
            }
        } receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.isSubscribe = true
            Constants.saveDefaults(value: false, key: Constants.subscribeApiFail)
            self.clearPendingSubscribePlan()
        }
        .store(in: &self.subscriptions)
    }

    // MARK: - Pending SubscribePlan persistence helpers
    func savePendingSubscribePlan(_ input: SubscribePlanRequest) {
        if let data = try? JSONEncoder().encode(input) {
            Constants.saveDefaults(value: data, key: Constants.pendingSubscribePlan)
        }
    }

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
        SubscribePlanRetryManager.shared.retryIfNeeded()
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}

