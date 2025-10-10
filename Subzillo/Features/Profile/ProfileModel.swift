//
//  ProfileModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 09/10/25.
//

import Foundation

public struct UpdateUserInfoRequest: Codable {
    let userId      : String
    let fullName    : String
    let email       : String
    let type        : Int
    let phoneNumber : String
    let countryCode : String
}

public struct UpdatePasswordRequest: Codable {
    let userId          : String
    let currentPassword : String
    let newPassword     : String
}

public struct UpdateProfileImageRequest: Codable {
    let userId          : String
}

public struct ImageSubscriptionRequest: Codable {
    let userId          : String
}

public struct ImageSubscriptionResponse: Codable {
    var message : String?
    var data    : ImageSubscriptionResponseData?
}

public struct ImageSubscriptionResponseData: Codable {
    var subscriptions : [ImageSubscription]?
}

public struct ImageSubscription: Codable {
    var serviceName       : String?
    var subscriptionType  : String?
    var amount            : Double?
    var currency          : String?
    var billingCycle      : String?
    var nextPaymentDate   : String?
    var paymentMethod     : String?
    var category          : String?
    var status            : String?
    var email             : String?
}
