//
//  LoginModel.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import Foundation

public struct LoginRequest: Codable {
    let username    : String
    let password    : String
    let deviceId    : String
    var platform    : Int = Constants.platform
    //  let pushMode    : Int?
    var uniqueId    : String = UUID().uuidString
}

public struct LoginResponse: Codable {
    var message: String?
    var data: LoginResponseData?
}

public struct LoginResponseData: Codable {
    var id                          : String?
    var username                    : String?
    var email                       : String?
    var country                     : String?
    var preferredCurrency           : String?
    var onboardingStep              : Int?
    var onboardingCompleted         : Bool?
    var emailNotifications          : Bool?
    var smsNotifications            : Bool?
    var pushNotifications           : Bool?
    var emailOtpVerified            : Bool?
    var accessToken                 : String?
    var refreshToken                : String?
    public init(
        id                          : String? = nil,
        username                    : String? = nil,
        email                       : String? = nil,
        country                     : String? = nil,
        preferredCurrency           : String? = nil,
        onboardingStep              : Int? = nil,
        emailNotifications          : Bool? = nil,
        smsNotifications            : Bool? = nil,
        pushNotifications           : Bool? = nil,
        emailOtpVerified            : Bool? = nil,
        accessToken                 : String? = nil,
        refreshToken                : String? = nil
    ) {
        self.id                         = id
        self.username                   = username
        self.email                      = email
        self.country                    = country
        self.preferredCurrency          = preferredCurrency
        self.onboardingStep             = onboardingStep
        self.emailNotifications         = emailNotifications
        self.smsNotifications           = smsNotifications
        self.pushNotifications          = pushNotifications
        self.emailOtpVerified           = emailOtpVerified
        self.accessToken                = accessToken
        self.refreshToken               = refreshToken
    }
}

public struct LogoutRequest: Codable {
    let userId : String
}
