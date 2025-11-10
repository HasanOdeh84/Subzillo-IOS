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
