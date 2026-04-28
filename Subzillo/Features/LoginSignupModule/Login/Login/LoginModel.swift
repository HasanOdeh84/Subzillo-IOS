//
//  LoginModel.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import Foundation

public struct checkLoginRequest: Codable {
    let loginType       : Int
    let email           : String
    let phoneNumber     : String
    let countryCode     : String
    var platform        : Int = Constants.platform
    let deviceId        : String
    var uniqueId        : String = UUID().uuidString
    var pushMode        : Int = Constants.shared.pushMode
    var referralCode    : String?
    var createNewAcc    : Bool?
}

public struct LoginResponse: Codable {
    var message : String?
    var data    : LoginResponseData?
}

public struct LoginResponseData: Codable {
    var id                          : String?
    var email                       : String?
    var userId                      : String?
    var fullName                    : String?
    var isNewUser                   : Bool?
    var signupCompleted             : Bool?
    var loginType                   : Int?
    var onboardingStatus            : Bool?
    var accessToken                 : String?
    var refreshToken                : String?
    var deleteStatus                : Bool?
    public init(
        userId              : String? = nil,
        fullName            : String? = nil,
        isNewUser           : Bool? = nil,
        signupCompleted     : Bool? = nil,
        onboardingStatus    : Bool? = nil,
        accessToken         : String? = nil,
        refreshToken        : String? = nil,
        deleteStatus        : Bool? = nil
    ) {
        self.userId                     = userId
        self.fullName                   = fullName
        self.isNewUser                  = isNewUser
        self.signupCompleted            = signupCompleted
        self.onboardingStatus           = onboardingStatus
        self.accessToken                = accessToken
        self.refreshToken               = refreshToken
        self.deleteStatus               = deleteStatus
    }
}

public struct LogoutRequest: Codable {
    let userId : String
}

// Social login model
struct SocialLoginModel:Codable{
    var id            : String?     = nil
    var loginType     : loginType?  = nil
    var fullName      : String?     = nil
    var emailAddress  : String?     = nil
    var profileImage  : Data?       = Data()
}

public struct SocialLoginRequest: Codable {
    var authProvider : loginType?  = nil
    let email        : String
    let socialId     : String
    var platform     : Int = Constants.platform
    let deviceId     : String
    var uniqueId     : String = UUID().uuidString
    var pushMode     : Int = Constants.shared.pushMode
    let fullName     : String
    let referralCode : String?
    var createNewAcc : Bool?
}

public struct RestoreUserRequest: Codable {
    let userId          : String
    var platform        : Int = Constants.platform
    let deviceId        : String
    var uniqueId        : String = UUID().uuidString
    var pushMode        : Int = Constants.shared.pushMode
    let loginType       : Int
}

public struct RestoreUserResponse: Codable {
    var message : String?
    var data    : RestoreUserResponseData?
}

public struct RestoreUserResponseData: Codable {
    var userId                      : String?
    var fullName                    : String?
    var email                       : String?
    var isNewUser                   : Bool?
    var signupCompleted             : Bool?
    var onboardingStatus            : Bool?
    var accessToken                 : String?
    var refreshToken                : String?
}
