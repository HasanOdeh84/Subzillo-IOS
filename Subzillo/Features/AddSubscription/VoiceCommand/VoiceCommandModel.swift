//
//  VoiceCommandModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/09/25.
//

import Foundation
public struct VoiceSubscriptionRequest: Codable {
  let userId : String
  public init(
    userId: String) {
      self.userId   = userId
    }
}

public struct VoiceSubscriptionResponse: Codable {
    var message : String?
    var data    : VoiceSubscriptionData?
}

public struct VoiceSubscriptionData: Codable {
  var serviceName                   : String?
  var subscriptionType              : String?
  var amount                        : Double?
  var currency                      : String?
  var billingCycle                  : String?
  var nextPaymentDate               : String?
  var paymentMethod                 : String?
  var category                      : String?
  var status                        : String?
  var email                         : String?
  public init(
    serviceName                      : String? = nil,
    subscriptionType                 : String? = nil,
    amount                           : Double? = nil,
    currency                         : String? = nil,
    billingCycle                     : String? = nil,
    nextPaymentDate                  : String? = nil,
    paymentMethod                    : String? = nil,
    category                         : String? = nil,
    status                           : String? = nil,
    email                            : String? = nil
  ) {
    self.serviceName                = serviceName
    self.subscriptionType           = subscriptionType
    self.amount                     = amount
    self.currency                   = currency
    self.billingCycle               = billingCycle
    self.nextPaymentDate            = nextPaymentDate
    self.paymentMethod              = paymentMethod
    self.category                   = category
    self.status                     = status
    self.email                      = email
  }
}
