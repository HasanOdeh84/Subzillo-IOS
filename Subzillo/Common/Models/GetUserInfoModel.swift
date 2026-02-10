//
//  GetUserInfoModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 11/11/25.
//

import Foundation

public struct getUserInfoRequest: Codable {
    let userId : String
}

public struct getUserInfoResponse: Codable {
    let message : String?
    let data    : UserInfo?
}

public struct UserInfo: Codable, Hashable {
    var id                      : String?
    var fullName                : String?
    var email                   : String?
    var phoneNumber             : String?
    var countryCode             : String?
    var preferredCurrency       : String?
    var preferredCurrencySymbol : String?
    var noofSubscriptions       : Int?
    var averageMonthlySpend     : Int?
    var profileImage            : String?
    var registrationComplete    : Bool?
    var emailNotifications      : Bool?
    var smsNotifications        : Bool?
    var pushNotifications       : Bool?
    var createdAt               : String?
    var tierId                  : String?
    var tierName                : String?
    var familyMembersLimit      : Int?
    var renewalReminders        : Bool?
    var priceChangeReminders    : Bool?
    var isEmailConnection       : Bool?
}

public struct UnreadNotificationCountRequest: Codable {
    let userId : String
}

public struct UnreadNotificationCountResponse: Codable {
    let message : String?
    let data    : UnreadNotificationCountData?
}

public struct UnreadNotificationCountData: Codable, Hashable {
    var unreadCount             : Int?
}

public struct UpdateDeviceIdRequest: Codable {
    let userId      : String
    let deviceId    : String
    let uniqueId    : String
}

public struct UpdateDeviceIdResponse: Codable {
    let message : String?
    let data    : UpdateDeviceIdData?
}

public struct UpdateDeviceIdData: Codable, Hashable {
    var accessToken             : String?
    var refreshToken            : String?
}
