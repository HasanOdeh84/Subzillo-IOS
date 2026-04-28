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
    var id                          : String?
    var fullName                    : String?
    var email                       : String?
    var phoneNumber                 : String?
    var countryCode                 : String?
    var preferredCurrency           : String?
    var preferredCurrencySymbol     : String?
    var noofSubscriptions           : Int?
    var averageMonthlySpend         : Int?
    var profileImage                : String?
    var registrationComplete        : Bool?
    var renewalReminders            : Bool?
    var priceChangeReminders        : Bool?
    var pricingPlanId               : String?
    var planName                    : String?
    var planSubscriptionLimit       : Int?
    var usedSubscriptionCount       : Int?
    var remainingSubscriptionLimit  : Int?
    var planBillingCycle            : String?
    var planExpiresAt               : String?
    var upgradeBtnStatus            : Bool?
    var internalPlanType            : Int? // 0: Free, 1: Silver Monthly, 2: Silver Yearly, 3: Gold Monthly, 4: Gold Yearly
    var subscribedPlatformType      : Int? = 2// 1: Android, 2: iOS, 3: Web
    var referralCode                : String?
    var referralLink                : String?
    var isoCountryCode              : String?
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

public struct AppVersionResponse: Codable {
    let message     : String?
    let data        : AppVersionData?
}

public struct AppVersionData: Codable {
    let forceUpdate : Bool?
    let appVersion  : String?
}
