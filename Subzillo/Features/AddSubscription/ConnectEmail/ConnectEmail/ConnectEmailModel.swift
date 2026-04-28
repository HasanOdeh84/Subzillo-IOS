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
    var platform                    : Int = 2 //1- Android, 2- iOS
}

public struct OauthUrlResponse: Codable {
    var message                 : String?
    var data                    : OauthUrlData?
}

public struct OauthUrlData: Codable {
    var authUrl              : String?
}

struct GmailOauthCallBackRequest: Codable {
    var userId                      : String
    var code                        : String
    var type                        : Int  //type -> 1- Gmail, 2- Microsoft
    var platform                    : Int = 2 //platform -> 1-android, 2- ios, 3- web
}

struct ICloudConnectRequest: Codable {
    var userId                      : String
    var email                       : String
    var appPassword                 : String
}
