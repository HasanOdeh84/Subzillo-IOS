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
}

public struct LoginResponse: Codable {
    var message : String?
    var data    : LoginResponseData?
}

public struct LoginResponseData: Codable {
    var userId                      : String?
    var fullName                    : String?
    var isNewUser                   : Bool?
    var signupCompleted             : Bool?
    var accessToken                 : String?
    var refreshToken                : String?
    public init(
        userId          : String? = nil,
        fullName        : String? = nil,
        isNewUser       : Bool? = nil,
        signupCompleted : Bool? = nil,
        accessToken     : String? = nil,
        refreshToken    : String? = nil
    ) {
        self.userId                     = userId
        self.fullName                   = fullName
        self.isNewUser                  = isNewUser
        self.signupCompleted            = signupCompleted
        self.accessToken                = accessToken
        self.refreshToken               = refreshToken
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
    var mobileNumber  : String?     = nil
}

public struct SocialLoginRequest: Codable {
    let socialId     : String
    var authProvider : loginType?  = nil
    let email        : String
    let fullName     : String
    let username     : String
    var platform     : Int = Constants.platform
    let deviceId     : String
    var uniqueId     : String = UUID().uuidString
}
