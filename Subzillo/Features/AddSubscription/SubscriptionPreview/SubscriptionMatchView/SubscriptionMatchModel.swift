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
