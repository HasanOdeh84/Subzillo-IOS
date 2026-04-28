//
//  SubscriptionMatchModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/11/25.
//

import Foundation

public struct GetSubscriptionDetailsRequest: Codable {
    var userId                 : String?
    var subscriptionId         : String?
}

public struct GetSubscriptionDetailsResponse: Codable {
    var message                 : String?
    var data                    : SubscriptionData?
}

public struct GetSubscriptionDetailsResponseData: Codable {
    let id                      : String?
    let serviceName             : String?
    let serviceLogo             : String?
    let amount                  : Double?
    let currency                : String?
    let currencySymbol          : String?
    let nextPaymentDate         : String?
    let subscriptionType        : String?
    let renewalReminders        : [String]?
    let status                  : String?
    let paymentMethod           : String?
    let paymentMethodName       : String?
    let cardName                : String?
    let cardNumber              : String?
    let category                : String?
    let categoryName            : String?
    let subscriptionFor         : String?
    let nickName                : String?
    let color                   : String?
}

public struct RenewalUpdateRequest: Codable {
    var userId                 : String?
    var subscriptionId         : String?
    var type                   : Int?
    var serviceName            : String?
    var amount                 : Double?
    var currency               : String?
    var currencySymbol         : String?
    var billingCycle           : String?
    var nextPaymentDate        : String?
    var subscriptionType       : String?
    var paymentMethod          : String?
    var paymentMethodDataId    : String?
    var category               : String?
    var subscriptionFor        : String?
    var renewalReminder        : [String]?
    var notes                  : String?
}
