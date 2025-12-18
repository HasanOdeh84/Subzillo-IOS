//
//  OtpVerifyModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 24/09/25.
//

import Foundation

public struct LoginSignupVerifyData: Codable, Hashable {
    let verifyType          : Int
    let email               : String?
    let phoneNumber         : String?
    let countryCode         : String?
    let userId              : String
    let isNewUser           : Bool
    let isSignupCompleted   : Bool
    let fullName            : String?
    let socialLogin         : Bool?
    let socialLoginType     : loginType?
    let onboardingStatus    : Bool?
    init(
        verifyType          : Int,
        email               : String? = nil,
        phoneNumber         : String? = nil,
        countryCode         : String? = nil,
        userId              : String,
        isNewUser           : Bool,
        isSignupCompleted   : Bool,
        fullName            : String? = nil,
        socialLogin         : Bool? = false,
        socialLoginType     : loginType? = loginType.none,
        onboardingStatus    : Bool? = false
    ) {
        self.verifyType         = verifyType
        self.email              = email
        self.phoneNumber        = phoneNumber
        self.countryCode        = countryCode
        self.userId             = userId
        self.isNewUser          = isNewUser
        self.isSignupCompleted  = isSignupCompleted
        self.fullName           = fullName
        self.socialLogin        = socialLogin
        self.socialLoginType    = socialLoginType
        self.onboardingStatus   = onboardingStatus
    }
}

public struct OtpVerifyRequest: Codable {
    let verifyType           : Int
    let email                : String
    let phoneNumber          : String
    let countryCode          : String
    let otp                  : Int
    let userId               : String
    var verifyMergeType      : Int = 1
}

public struct ResendOtpRequest: Codable {
    var userId        : String? = nil
    var verifyType    : Int? = nil
}
