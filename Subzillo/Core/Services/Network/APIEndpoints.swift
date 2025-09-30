import Foundation
import UIKit
import Combine

let baseurl         = "https://devsubzillo.krify.com/api"
let defaultAuthKey  = "CeZwFhHrhiK8bBG2sH9XuwGbsHfeRp0kdTr6ZAwZzxP5jOLbCRBtfaz3qHLPhg1v"

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

enum Endpoint: String {
    case login                          = "/login"
    case registration                   = "/register"
    case voiceSubscription              = "/voiceSubscription"
    case regenerateAccessToken          = "/regenerateAccessToken"
    case verifyOtp                      = "/verifyOtp"
    case forgotPassword                 = "/forgotPassword"
    case resetPassword                  = "/resetPassword"
    case resendOtp                      = "/resendOtp"
    case logout                         = "/logout"
}

var authKey: String {
    get {
        return "Bearer \(KeychainHelper.read(account: Constants.authKey) ?? "")"
    }
}
