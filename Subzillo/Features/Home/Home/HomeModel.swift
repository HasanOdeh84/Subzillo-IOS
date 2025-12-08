//
//  HomeModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 12/11/25.
//

import Foundation

struct ActiveSubscription: Decodable, Encodable, Hashable, Identifiable{
    var id = UUID()
    var serviceLogo     : String?
    var serviceName     : String?
    var planType        : String?
    var nextRenewal     : String?
    var billingCycle    : String?
    var currency        : String?
    var price           : Double?
    var relation        : String?
    var relationColor   : String?
    public init(
        serviceLogo             : String? = nil,
        serviceName             : String? = nil,
        planType                : String? = nil,
        nextRenewal             : String? = nil,
        billingCycle            : String? = nil,
        currency                : String? = nil,
        price                   : Double? = nil,
        relation                : String? = nil,
        relationColor           : String? = nil
    ) {
        self.serviceLogo           = serviceLogo
        self.serviceName           = serviceName
        self.planType              = planType
        self.nextRenewal           = nextRenewal
        self.billingCycle          = billingCycle
        self.currency              = currency
        self.price                 = price
        self.relation              = relation
        self.relationColor         = relationColor
    }
}

struct HomeRequest: Codable{
    var userId : String
}

public struct HomeResponse: Codable {
    let message : String?
    let data    : HomeResponseData?
}

public struct HomeResponseData: Codable, Hashable{
    let monthlySpend          : Double?
    let monthlySpendCurrency  : String?
    let totalSubscriptions    : Int?
    let subscriptionList      : [SubscriptionListData]?
    let topCategories         : [TopCategoriesData]?
    let expiringSoon          : [SubscriptionListData]?
}

public struct SubscriptionListData: Codable, Hashable, Identifiable{
    public let id         : String?
    let serviceName       : String?
    let serviceLogo       : String?
    let amount            : Double?
    let currency          : String?
    let currencySymbol    : String?
    let billingCycle      : String?
    let subscriptionType  : String?
    let subscriptionFor   : String?
    let category          : String?
    let paymentMethod       : String?
    let paymentMethodName   : String?
    let paymentMethodDataId : String?
    let nextPaymentDate   : String?
    let renewalReminder   : [String]?
    let nickName          : String?
    let color             : String?
    let cardName          : String?
    let notes             : String?
    let status            : String?
    var isSelected        : Bool? = false
    var cardNumber        : String?
    var categoryName      : String?
    var paymentMethodDataName: String?
    
}

public struct TopCategoriesData: Codable, Hashable, Identifiable {
    public var id           : String {categoryId ?? "\(UUID())"}
    let categoryId          : String?
    let categoryName        : String?
    let subscriptionCount   : Int?
    let percentage          : Double?
}
