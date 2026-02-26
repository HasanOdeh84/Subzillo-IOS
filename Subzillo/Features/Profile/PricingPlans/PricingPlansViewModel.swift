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
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}

