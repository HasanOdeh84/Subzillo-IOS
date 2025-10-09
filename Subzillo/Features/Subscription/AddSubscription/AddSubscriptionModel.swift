//
//  AddSubscriptionModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 09/10/25.
//

import Foundation

public struct AddSubscriptionRequest: Codable {
    let userId                : String
    let serviceName           : String
    let email                 : String
    let subscriptionType      : String
    let amount                : Double
    let currency              : String
    var billingCycle          : String
    var nextPaymentDate       : String
    var paymentMethod         : String
    var category              : String
    var source                : String
}

public struct AddSubscriptionResponse: Codable {
    var message : String?
    var data    : AddSubscriptionResponseData?
}

public struct AddSubscriptionResponseData: Codable {
    var id                      : String?
    var userId                  : String?
    var serviceName             : String?
    var email                   : String?
    var subscriptionType        : String?
    var amount                  : Double?
    var currency                : String?
    var billingCycle            : String?
    var nextPaymentDate         : String?
    var paymentMethod           : String?
    var category                : String?
    var status                  : String?
    var source                  : String?
    var sourceReference         : String?
    var createdAt               : String?
    var updatedAt               : String?
    public init(
        id                      : String? = nil,
        userId                  : String? = nil,
        serviceName             : String? = nil,
        email                   : String? = nil,
        subscriptionType        : String? = nil,
        amount                  : Double? = nil,
        currency                : String? = nil,
        billingCycle            : String? = nil,
        nextPaymentDate         : String? = nil,
        paymentMethod           : String? = nil,
        category                : String? = nil,
        status                  : String? = nil,
        source                  : String? = nil,
        sourceReference         : String? = nil,
        createdAt               : String? = nil,
        updatedAt               : String? = nil
    ) {
        self.id                 = id
        self.userId             = userId
        self.serviceName        = serviceName
        self.email              = email
        self.subscriptionType   = subscriptionType
        self.amount             = amount
        self.currency           = currency
        self.billingCycle       = billingCycle
        self.nextPaymentDate    = nextPaymentDate
        self.paymentMethod      = paymentMethod
        self.category           = category
        self.status             = status
        self.source             = source
        self.sourceReference    = sourceReference
        self.createdAt          = createdAt
        self.updatedAt          = updatedAt
    }
}
