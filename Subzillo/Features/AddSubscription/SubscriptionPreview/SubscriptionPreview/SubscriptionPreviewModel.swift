//
//  SubscriptionPreviewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 14/11/25.
//
import Foundation


public struct PendingSubscriptionConfirmRequest: Codable {
    let userId                  : String
    let confirmedSubscription   : [ConfirmedSubscription]
}

public struct ConfirmedSubscription: Codable {
    let serviceName             : String
    let serviceLogo             : String
    let amount                  : Double
    let currency                : String
    let billingCycle            : String
    let nextPaymentDate         : String
    let subscriptionType        : String
    let paymentMethod           : String
    let paymentMethodDataId     : String
    let category                : String
    let subscriptionFor         : String
    let renewalReminder         : [String]
    let notes                   : String
    let currencySymbol          : String
    let source                  : Int
}

public struct PendingSubscriptionConfirmResponse: Codable {
    var message                 : String?
    var data                    : PendingSubscriptionConfirmResponseData?
}

public struct PendingSubscriptionConfirmResponseData: Codable {
    var duplicates              : [DuplicatesData]?
}
