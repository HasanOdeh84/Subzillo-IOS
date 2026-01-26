//
//  ConnectEmailModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/01/26.
//

import Foundation

struct OauthUrlRequest: Codable {
    var userId                      : String
    var type                        : Int //1- Gmail, 2- Microsoft
}

public struct OauthUrlResponse: Codable {
    var message                 : String?
    var data                    : OauthUrlData?
}

public struct OauthUrlData: Codable {
    var authUrl              : String?
}
