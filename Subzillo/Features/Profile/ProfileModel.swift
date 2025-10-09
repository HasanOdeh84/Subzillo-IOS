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
