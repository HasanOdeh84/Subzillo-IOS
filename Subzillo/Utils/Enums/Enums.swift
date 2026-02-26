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
    case manualEntry(isFromEdit:Bool = false, isFromListEdit: Bool = false, isRenew: Bool = false, subscriptionId:String = "", familyMemberId:String = "", isFromEmail: Bool = false)
    case voiceCommandView
    case subscriptionPreviewView(subscriptionsData:[SubscriptionData]?, content: String, isFromImage:Bool, isFromEmail: Bool = false, audioUrl:URL?)
    case subscriptionMatchView(subscriptionData:SubscriptionData = SubscriptionData(), fromList:Bool = false, fromPush:Bool = false, subscriptionId:String = "")
    case pasteTextView
    case duplicateSubscriptionsView(duplicateSubsList: [DuplicateDataInfo], fromFamily:Bool = false, isFromEmail: Bool = false)
    case duplicateUpdateView(duplicateSubsList: DuplicateDataInfo?, selectedIndex: Int, fromFamily:Bool = false, isFromEmail: Bool = false)
    case addSubscriptionsView
    case duplicateSubDetailsView(subscriptionData: SubscriptionInfo?)
    case subscriptionsListView(selectedSegment: Segment = .first)
    case myCards
    case familyMembersView
    case connectEmail
    case connectedEmailsList(isIntegrations:Bool = false)
    case settings
    case contactUs
    case pricingPlans
    case inviteFriends
}

extension NavigationRoute {
    var subId: String? {
        switch self {
        case .manualEntry(_, _, _, let id, _, _):
            return id
        case .subscriptionMatchView(_, _, _, let id):
            return id
        default:
            return nil
        }
    }
    
    func isSameRoute(as other: NavigationRoute) -> Bool {
        switch (self, other) {
        case (.home, .home): 
            return true
        case (.subscriptionMatchView(_, _, _, let id1), .subscriptionMatchView(_, _, _, let id2)):
            return id1 == id2 && !id1.isEmpty
        case (.connectedEmailsList(let i1), .connectedEmailsList(let i2)):
            return i1 == i2
        case (.pricingPlans, .pricingPlans): 
            return true
        case (.notifications, .notifications): 
            return true
        case (.settings, .settings):
            return true
        case (.subscriptionsListView(let s1), .subscriptionsListView(let s2)):
            return s1 == s2
        default:
            return false
        }
    }
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
    case first, second, third
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

enum PendingUIAction {
    case selectPlanType
    case selectBilling
    case selectCategory
    case selectpaymentMethod
    case dateSelection
}
