import Foundation
import UIKit
import Combine

enum urlType:Int{
    case dev   = 0
    case stage = 1
    case prod  = 2
}

let Environment = urlType.dev
var baseurl: String {
    switch Environment {
    case .dev:
        return "https://devsubzillo.krify.com/api"
    case .stage:
        return "https://stagingsubzillo.krify.com/api"
    case .prod:
        return ""
    }
}

//com.subzillo.app
//com.krify.Subzillo
let defaultAuthKey  = "CeZwFhHrhiK8bBG2sH9XuwGbsHfeRp0kdTr6ZAwZzxP5jOLbCRBtfaz3qHLPhg1v"

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

enum APIEndpoint: String {
    case checkLogin                     = "/checkLogin"
    case verifyOtp                      = "/verifyOtp"
    case resendOtp                      = "/resendOtp"
    case registration                   = "/completeRegistration"
    case sendMergeOtp                   = "/sendMergeOtp"
    case socialLogin                    = "/socialLogin"
    case logout                         = "/logout"
    case updateOnboarding               = "/updateOnboarding"
    case regenerateAccessToken          = "/regenerateAccessToken"
    case addSubscription                = "/addSubscription"
    case imageSubscription              = "/imageSubscription"
    case voiceSubscription              = "/voiceSubscription"
    case pendingSubscriptionConfirm     = "/pendingSubscriptionConfirm"
    case getUserInfo                    = "/getUserInfo"
    case addCard                        = "/addCard"
    case listUserCards                  = "/listUserCards"
    case addFamilyMember                = "/addFamilyMember"
    case listFamilyMembers              = "/listFamilyMembers"
    case home                           = "/home"
    case listSubscriptions              = "/listSubscriptions"
    case getSubscriptionsByMonth        = "/getSubscriptionsByMonth"
    case deleteSubscription             = "/deleteSubscription"
    case getSubscriptionDetails         = "/getSubscriptionDetails"
    case editSubscription               = "/editSubscription"
    case resolveDuplicateSubscription   = "/resolveDuplicateSubscription"
    case textSubscription               = "/textSubscription"
    case getServiceProvidersList        = "/getServiceProvidersList"
    case fetchProviderData              = "/fetchProviderData"
    case editFamilyMember               = "/editFamilyMember"
    case deleteCard                     = "/deleteCard"
    case editCard                       = "/editCard"
    case deleteFamilyMember             = "/deleteFamilyMember"
    case updateProfile                  = "/updateProfile"
    case homeYearlyGraph                = "/homeYearlyGraph"
    case OauthUrl                       = "/OauthUrl"
    
    //common api's
    case getCategories                  = "/getCategories"
    case getPaymentMethods              = "/getPaymentMethods"
    case getCurrencies                  = "/getCurrencies"
    case getCountryCodes                = "/getCountryCodes"
    
    //old api's
    case updateUserInfo                 = "/updateUserInfo"
    case updatePassword                 = "/updatePassword"
    case updateProfileImage             = "/updateProfileImage"
}

var authKey: String {
    get {
        return "Bearer \(KeychainHelper.read(account: Constants.authKey) ?? "")"
    }
}
