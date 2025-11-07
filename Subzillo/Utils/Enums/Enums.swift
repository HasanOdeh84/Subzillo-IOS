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
    case addSubscription(serviceName: String, planName: String, price: Double, billingCycle: String)
    case emailIntegration
    case bankStatement
    case chat
    case appearance
    case notifications
    case home
    case signup
    case login
    case onboarding
    case verifyOtp(fromLogin: Bool)
    case resetPassword(username:String? = "")
    case termsAndPrivacy(isTerm:Bool?)
    case SuccessView(isOtp:Bool?)
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
    case google   = 1
    case apple    = 2
    case facebook = 3
}

enum loginCheckType: Int, Codable{
    case mobile   = 1
    case email    = 2
}

enum Segment {
    case first, second
}
