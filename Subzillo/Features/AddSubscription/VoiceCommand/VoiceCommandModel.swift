//
//  VoiceCommandModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/09/25.
//

import Foundation

public struct VoiceSubscriptionRequest: Codable {
    var userId                      : String
    var text                        : String
}

public struct VoiceSubscriptionResponse: Codable {
    var message                     : String?
    var providerLogoBaseUrl         : String?
    var data                        : VoiceSubscriptionResponseData?
}

public struct VoiceSubscriptionResponseData: Codable, Hashable {
    var subscriptions               : [SubscriptionData]?
    var hasMultipleSubscriptions    : Bool?
}

public struct SubscriptionData: Codable, Hashable {
    var id                          : String?
    var serviceName                 : String?
    var serviceNameConfidence       : Double?
    var serviceLogo                 : String?
    var subscriptionType            : String?
    var subscriptionTypeConfidence  : Double?
    var amount                      : Double?
    var amountConfidence            : Double?
    var currency                    : String?
    var currencySymbol              : String?
    var currencyConfidence          : Double?
    var billingCycle                : String?
    var billingCycleConfidence      : Double?
    var lastPaymentDate             : String?
    var nextPaymentDate             : String?
    var nextPaymentDateConfidence   : Double?
    var paymentMethodId             : String?
    var paymentMethod               : String?
    var paymentMethodName           : String?
    var paymentMethodStatus         : Bool?
    var paymentMethodConfidence     : Double?
    var categoryId                  : String?
    var category                    : String?
    var categoryName                : String?
    var categoryConfidence          : Double?
    var confidenceOverall           : Double?
    var isSubscription              : Bool?
    var reason                      : String?
    var subscriptionForName         : String?
    var subscriptionFor             : String?
    var paymentMethodDataId         : String?
    var paymentMethodDataName       : String?
    var renewalReminder             : [String]?
    var renewalReminders            : [String]?
    var renewalReminderValue        : String?
    var notes                       : String?
    var status                      : String?
    var cardName                    : String?
    var cardNumber                  : String?
    var nickName                    : String?
    var color                       : String?
}
