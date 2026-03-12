//
//  PricingPlansModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 19/02/26.
//

import Foundation

struct PricingPlanRequest: Codable {
    let userId  : String
    let type    : Int // type -> 1-Monthly,2-Yearly
}

struct PricingPlanResponse: Codable {
    let message                     : String?
    let data                        : pricingPlanData?
}

struct pricingPlanData : Codable{
    let plans                       : [PricingPlan]?
    let currentInternalPlanType     : Int?// 0: Free, 1: Silver Monthly, 2: Silver Yearly, 3: Gold Monthly, 4: Gold Yearly
    var subscribedPlatformType      : Int? = 2// 1: Android, 2: iOS, 3: Web
}

struct PricingPlan: Identifiable, Equatable, Codable  {
    let id                  : String?
    let planName            : String?
    let description         : String?
    let price               : Double?
    let currencyCode        : String?
    let currencySymbol      : String?
    let subscriptionLimit   : Int?
    let isCurrentPlan       : Bool?
    let iosProductId        : String?
    let internalPlanType    : Int? // Must match UserInfo.planType ranking
}

struct SubscribePlanRequest: Codable {
    let userId              : String
    let pricingPlanId       : String
    let platform            : Int
    let transactionId       : String
}
