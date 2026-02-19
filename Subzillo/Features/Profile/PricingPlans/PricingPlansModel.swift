//
//  PricingPlansModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 19/02/26.
//

import Foundation

struct PricingPlanResponse: Codable {
    let message     : String?
    let data        : [PricingPlan]?
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
}
