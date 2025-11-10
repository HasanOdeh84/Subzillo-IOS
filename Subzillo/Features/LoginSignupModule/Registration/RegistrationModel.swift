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
    var data    : RegisterResponseData?
}

public struct RegisterResponseData: Codable {
  var status                    : Int?
  public init(
    status                      : Int? = nil
  ) {
    self.status                 = status
  }
}

public struct SendMergeOtpRequest: Codable {
    let mergeLoginType          : Int
    let email                   : String
    let countryCode             : String
    let phoneNumber             : String
}
