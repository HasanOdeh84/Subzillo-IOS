//
//  DuplicateSubscriptionsModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 19/11/25.
//

struct ModifiedDuplicateDataInfo: Codable, Hashable  {
    var originalData            : DuplicateDataInfo?
    var selectedIndexs          : [Int]?
    var selectedData            : [SubscriptionInfo]?
    var selectedExistingData    : SubscriptionInfo?
    var isKeepAll               : Bool?
    var subscriptionIds         : [String]?
}

struct DuplicateDataInfo: Identifiable, Codable, Hashable {
    var id                      : String
    var serviceName             : String?
    var newSubscriptions        : [SubscriptionInfo]?
    var existingSubscriptions   : [SubscriptionInfo]?
}

public struct SubscriptionInfo: Codable, Hashable {
    var id                      : String?
    var serviceName             : String?
    var serviceLogo             : String?
    var amount                  : Double?
    var currency                : String?
    var currencySymbol          : String?
    var billingCycle            : String?
    var subscriptionType        : String?
    var subscriptionFor         : String?
    var nextPaymentDate         : String?
    var category                : String?
    var paymentMethod           : String?
    var paymentMethodDataId     : String?
    var notes                   : String?
    var renewalReminder         : [String]?
    var status                  : String?
    var source                  : Int?
    var sourceReference         : Int?
    var paymentMethodName       : String?
    var categoryName            : String?
    var cardNumber              : String?
    var cardName                : String?
}

public struct ResolveDuplicateSubscriptionRequest: Codable {
    let userId                  : String
    let action                  : Int
    let existingSubscription    : String
    let newSubscriptions        : [SubscriptionInfo]
}

public struct ResolveDuplicateSubscriptionResponse: Codable, Hashable {
    var message                 : String?
    var data                    : ResolveDuplicateSubscriptionResponseData?
}

public struct ResolveDuplicateSubscriptionResponseData: Codable, Hashable {
    var subscriptionIds         : [String]
}
