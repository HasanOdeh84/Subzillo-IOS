//
//  Enums.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

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
    case manualEntry(isFromEdit:Bool = false, isFromListEdit: Bool = false, subscriptionId:String = "")
    case voiceCommandView
    case subscriptionPreviewView(subscriptionsData:[SubscriptionData]?, content: String, isFromImage:Bool)
    case subscriptionMatchView(subscriptionData:SubscriptionData = SubscriptionData(), fromList:Bool = false, subscriptionId:String = "")
    case pasteTextView
    case duplicateSubscriptionsView(duplicateSubsList: [DuplicateDataInfo])
    case duplicateUpdateView(duplicateSubsList: DuplicateDataInfo?, selectedIndex: Int)
    case addSubscriptionsView
    case duplicateSubDetailsView(subscriptionData: SubscriptionInfo?)
    case subscriptionsListView
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
