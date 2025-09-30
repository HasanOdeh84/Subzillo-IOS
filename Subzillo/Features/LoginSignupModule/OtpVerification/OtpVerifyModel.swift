//
//  OtpVerifyModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 24/09/25.
//

import Foundation

public struct OtpVerifyRequest: Codable {
    var email         : String? = ""
    let otp           : Int
    var userId        : String? = ""
    var username      : String? = ""
}

public struct ResendOtpRequest: Codable {
    var userId        : String? = nil
    var username      : String? = nil
}
