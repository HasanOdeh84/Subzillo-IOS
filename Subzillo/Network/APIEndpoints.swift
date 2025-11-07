import Foundation
import UIKit
import Combine

let baseurl         = "https://devsubzillo.krify.com/api"
let defaultAuthKey  = "CeZwFhHrhiK8bBG2sH9XuwGbsHfeRp0kdTr6ZAwZzxP5jOLbCRBtfaz3qHLPhg1v"

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

enum APIEndpoint: String {
    case checkLogin                     = "/checkLogin"
    case verifyOtp                      = "/verifyOtp"
    case resendOtp                      = "/resendOtp"
    case registration                   = "/completeRegistration"
    case getCurrencies                  = "/getCurrencies"
    case getCountryCodes                = "/getCountryCodes"

    case voiceSubscription              = "/voiceSubscription"
    case regenerateAccessToken          = "/regenerateAccessToken"
    case forgotPassword                 = "/forgotPassword"
    case resetPassword                  = "/resetPassword"
    case logout                         = "/logout"
    case addSubscription                = "/addSubscription"
    case updateUserInfo                 = "/updateUserInfo"
    case updatePassword                 = "/updatePassword"
    case updateProfileImage             = "/updateProfileImage"
    case imageSubscription              = "/imageSubscription"
    case socialLogin                    = "/socialLogin"
    case getCategories                  = "/getCategories"
}

var authKey: String {
    get {
        return "Bearer \(KeychainHelper.read(account: Constants.authKey) ?? "")"
    }
}
