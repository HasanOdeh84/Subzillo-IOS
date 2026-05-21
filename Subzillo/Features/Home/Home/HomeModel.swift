//
//  HomeModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 12/11/25.
//

import Foundation
import SwiftUI

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
    var totalSubscriptionCount  : Int? = nil
    var whereItGoes             : whereItGoes?
    var nextRenewals            : [nextRenewals]?
    var preferredCurrency       : String? = ""
    var stats                   : statsObjc?
    var preferredCurrencySymbol : String? = ""
    var spendProjection         : spendProjection?
    var monthlyOverview         : monthlyOverview?
    var topSpenders             : [topSpenders]?
}
struct whereItGoes: Codable, Hashable{
    var currency                : String? = ""
    var currencySymbol          : String? = ""
    var totalAmount             : Float? = nil
    var categories              : [categoriesObjc]?
}
struct categoriesObjc: Codable, Hashable{
    var color                   : String? = ""
    var categoryId              : String? = ""
    var totalAmount             : Float? = nil
    var amountPercentage        : Double? = nil
    var subscriptionCount       : Int? = nil
    var currency                : String? = ""
    var currencySymbol          : String? = ""
    var categoryName            : String? = ""
}
struct nextRenewals: Codable, Hashable{
    var id                      : String? = ""
    var serviceName             : String? = ""
    var serviceLogo             : String? = ""
    var amount                  : Float? = nil
    var currency                : String? = ""
    var currencySymbol          : String? = ""
    var nextPaymentDate         : String? = ""
    var planName                : String? = ""
    var billingCycle            : String? = ""
    var billingCycleShortLabel  : String? = ""
    var daysUntil               : Int? = nil
}
struct statsObjc: Codable, Hashable{
    var activeSubscriptions             : Int? = nil
    var yearlySpend                     : Float? = nil
    var currency                        : String? = ""
    var currencySymbol                  : String? = ""
    var highestActiveSubscription       : highestActiveSubscription?
}
struct spendProjection: Codable, Hashable{
    var peakMonth               : String? = ""
    var projectedAnnualSpend    : Double? = nil
    var peakAmount              : Float? = nil
    var currency                : String? = ""
    var currencySymbol          : String? = ""
    var months                  : [monthObjc]?
}

struct highestActiveSubscription: Codable, Hashable{
    var id                          : String? = ""
    var serviceName                 : String? = nil
    var serviceLogo                 : String? = nil
    var planName                    : String? = ""
    var amount                      : Double? = nil
    var currency                    : String?
    var currencySymbol              : String?
    var billingCycle                : String?
    var billingCycleShortLabel      : String?
}

struct monthObjc: Codable, Hashable{
    var month                   : String? = ""
    var year                    : Int? = nil
    var amount                  : Double? = nil
}
struct monthlyOverview: Codable, Hashable{
    var deltaDirection          : String? = ""
    var benchmarkAmount         : Float? = nil
    var amount                  : Float? = nil
    var currency                : String? = ""
    var currencySymbol          : String? = ""
    var deltaAmount             : Float? = nil
    var benchmarkRange          : String? = ""
    var status                  : String? = ""
}
struct topSpenders: Codable, Hashable{
    var id                      : String? = ""
    var progressPercentage      : Float? = nil
    var amount                  : Float? = nil
    var currency                : String? = ""
    var currencySymbol          : String? = ""
    var planName                : String? = ""
    var serviceName             : String? = ""
    var serviceLogo             : String? = ""
}

struct HomeYearlyGraphRequest: Codable{
    var userId : String
    var year   : Int
}

public struct HomeYearlyGraphResponse: Codable {
    let message : String?
    let data    : HomeYearlyGraphData?
}

public struct HomeYearlyGraphData: Codable, Hashable, Identifiable{
    public var id               : String?
    let monthlySpend            : [MonthlySpendData]?
    let userCurrencySymbol      : String?
    let userCurrency            : String?
}

struct MonthlySpendData: Codable, Hashable, Identifiable{
    var id       = UUID()
    var month    : String
    var amount   : Double
    
    enum CodingKeys: String, CodingKey {
        case month
        case amount
    }
}

public struct SubscriptionListData: Codable, Hashable, Identifiable{
    public let id               : String?
    let serviceName             : String?
    let serviceLogo             : String?
    let amount                  : Double?
    let currency                : String?
    let currencySymbol          : String?
    let billingCycle            : String?
    let subscriptionType        : String?
    let subscriptionFor         : String?
    let category                : String?
    let paymentMethod           : String?
    let paymentMethodName       : String?
    let paymentMethodDataId     : String?
    let nextPaymentDate         : String?
    let renewalReminder         : [String]?
    let nickName                : String?
    let color                   : String?
    let cardName                : String?
    let notes                   : String?
    let status                  : String?
    var isSelected              : Bool? = false
    var cardNumber              : String?
    var categoryName            : String?
    var paymentMethodDataName   : String?
    var viewStatus              : Bool? //for lock and unlock subscriptions
    var renewBtnStatus          : Bool? 
    var billingCycleShortLabel  : String? 
}

public struct TopCategoriesData: Codable, Hashable, Identifiable {
    public var id               : String {categoryId ?? "\(UUID())"}
    let categoryId              : String?
    let categoryName            : String?
    let color                   : String?
    let currencySymbol          : String?
    let subscriptionCount       : Int?
    let percentage              : Double?
    let totalAmount             : Double?
}

struct CategoryItem: Identifiable {
    let id                      = UUID()
    let name                    : String
    let amount                  : Float
    let amountStr               : String
    let color                   : String
    let currencySymbol          : String
}

// MARK: - Model

struct SubscriptionItemNew {
    let id              : String
    let name            : String
    let amountStr       : String
    let amount          : Float
    let progress        : Float
    let serviceLogo     : String
    let currencySymbol  : String
}
