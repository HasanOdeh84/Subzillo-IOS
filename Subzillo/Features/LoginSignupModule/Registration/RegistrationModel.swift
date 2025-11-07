//
//  RegistrationModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import Foundation

public struct RegisterRequest: Codable {
  let userId                 : String
  let fullName               : String
  let email                  : String
  let countryCode            : String
  let phoneNumber            : String
}

public struct RegisterResponse: Codable {
    var message : String?
//    var data    : RegisterResponseData?
}

public struct RegisterResponseData: Codable {
  var id                    : String?
  var username              : String?
  var email                 : String?
  var accessToken           : String?
  var refreshToken          : String?
  public init(
    id                      : String? = nil,
    username                : String? = nil,
    email                   : String? = nil,
    accessToken             : String? = nil,
    refreshToken            : String? = nil
  ) {
    self.id                 = id
    self.username           = username
    self.email              = email
    self.accessToken        = accessToken
    self.refreshToken       = refreshToken
  }
}
