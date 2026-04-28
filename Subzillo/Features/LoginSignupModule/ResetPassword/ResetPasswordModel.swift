//
//  ResetPasswordModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 25/09/25.
//

import Foundation

public struct ResetPasswordRequest: Codable {
  let username              : String
  let newPassword           : String
}
