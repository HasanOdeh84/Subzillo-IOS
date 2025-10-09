//
//  RefreshTokenModel.swift
//  CombineFrameworkiOS
//
//  Created by KSMACMINI-019 on 02/07/25.
//

import Foundation

public struct RefreshTokenResponse: Codable{
    let message     : String?
    let data        : RefreshTokenData?
    public init(message: String, data: RefreshTokenData) {
        self.message    = message
        self.data       = data
    }
}

public struct RefreshTokenData: Codable{
    let accessToken   : String?
    let refreshToken  : String?
    public init(accessToken: String, refreshToken: String) {
        self.accessToken    = accessToken
        self.refreshToken   = refreshToken
    }
}
