import Foundation
import UIKit
import Combine

enum urlType:Int{
    case dev    = 0
    case qa     = 1
    case stage  = 2
    case prod   = 3
}

let Environment = urlType.dev
var baseurl: String {
    switch Environment {
    case .dev:
        return "https://devsubzillo.krify.com/api"
    case .qa:
        return "https://qasubzillo.krify.com/api"
    case .stage:
        return "https://stagingsubzillo.krify.com/api"
    case .prod:
        return ""
    }
}

//com.subzillo.app
//com.krify.Subzillo
let defaultAuthKey = "CeZwFhHrhiK8bBG2sH9XuwGbsHfeRp0kdTr6ZAwZzxP5jOLbCRBtfaz3qHLPhg1v"

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
    case OauthUrl                       = "/OauthUrl" //No need
    case listConnectedEmails            = "/listConnectedEmails"
    case deleteEmail                    = "/deleteEmail"
    case oauthCallback                  = "/OauthCallback"
    case syncEmail                      = "/syncEmail"
    case emailSubscriptionsList         = "/emailSubscriptionsList"
    case privacyData                    = "/privacyData"
    case discardEmailSubscription       = "/discardEmailSubscription"
    case markNotificationRead           = "/markNotificationRead"
    case deleteNotification             = "/deleteNotification"
    case unreadNotificationCount        = "/unreadNotificationCount"
    case toggleReminders                = "/toggleReminders"
    case notificationsList              = "/notificationsList"
    case updateProfileImage             = "/updateProfileImage"
    case updateDeviceId                 = "/updateDeviceId"
    case analytics                      = "/analytics"
    case exportGmailSyncLogs            = "/exportGmailSyncLogs"
    case emailAutoSync                  = "/emailAutoSync"
    case exportSubscriptionData         = "/exportSubscriptionData"
    case listPricingPlans               = "/listPricingPlans"
    case listSyncPeriods                = "/listSyncPeriods"
    case updateSyncPeriod               = "/updateSyncPeriod"
    case renewalUpdate                  = "/renewalUpdate"
    case subscribePlan                  = "/subscribePlan"
    case appUpdate                      = "/appUpdate"

    //new api's
    case deleteAccount                  = "/deleteAccount"

    //common api's
    case getCategories                  = "/getCategories"
    case getPaymentMethods              = "/getPaymentMethods"
    case getCurrencies                  = "/getCurrencies"
    case getCountryCodes                = "/getCountryCodes"
}

var authKey: String {
    get {
        return "Bearer \(KeychainHelperApp.read(account: Constants.authKey) ?? "")"
    }
}
