//
//  Enums.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import Foundation

enum Tab {
    case home, subscriptions, addSubscription, smartAI, profile
}

enum NavigationRoute: Hashable{
    case login
    case termsAndPrivacy(isTerm:Bool?)
    case verifyOtp(fromLogin: Bool,verifyMergeType:Int = 1)
    case SuccessView(isOtp:Bool?,isMobile:Bool = true)
    case signup(fromSocialLogin:Bool = false)
    case onboarding
    case welcome
    case home
    case emailIntegration
    case bankStatement
    case chat
    case appearance
    case notifications
    case manualEntry(isFromEdit:Bool = false, isFromListEdit: Bool = false, subscriptionId:String = "", familyMemberId:String = "")
    case voiceCommandView
    case subscriptionPreviewView(subscriptionsData:[SubscriptionData]?, content: String, isFromImage:Bool, audioUrl:URL?)
    case subscriptionMatchView(subscriptionData:SubscriptionData = SubscriptionData(), fromList:Bool = false, subscriptionId:String = "")
    case pasteTextView
    case duplicateSubscriptionsView(duplicateSubsList: [DuplicateDataInfo], fromFamily:Bool = false)
    case duplicateUpdateView(duplicateSubsList: DuplicateDataInfo?, selectedIndex: Int, fromFamily:Bool = false)
    case addSubscriptionsView
    case duplicateSubDetailsView(subscriptionData: SubscriptionInfo?)
    case subscriptionsListView
    case myCards
    case familyMembersView
    case connectEmail
    case connectedEmailsList
}

enum FocusPin {
    case  pinOne, pinTwo, pinThree, pinFour, pinFive, pinSix
}

enum ToVerify{
    case forgot, register, login, profile
}

enum MediaSource {
    case camera, library, document
}

// Social login type enum
enum loginType:Int,Codable {
    case google    = 1
    case apple     = 2
    case microsoft = 3
    case none      = 4
}

enum loginCheckType: Int, Codable{
    case mobile   = 1
    case email    = 2
}

enum Segment {
    case first, second
}

enum ListType {
    case billing, cards, relations, reminders
}

enum OrderType: String, Codable {
    case asc, desc, none
}

enum ReviewExtractedType: String, Codable {
    case service, amount, nextChargeDate, currency, category, planType, billingCycle
}

enum FieldType {
    case serviceName
    case planType
    case amount
}

enum SubscriptionsMode {
    case list
    case calendar
    case analytics
}

enum AccountType : Int, Identifiable {
    case name       = 1
    case email      = 2
    case mobile     = 3
    case currency   = 4
    
    var id: Int { rawValue }
}
