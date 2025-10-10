//
//  Enums.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

enum Tab {
    case home, subscriptions, analytics, activity, profile
}

enum PendingRoute: Hashable {
    case addSubscription(serviceName: String, planName: String, price: Double, billingCycle: String)
    case emailIntegration
    case bankStatement
    case chat
    case appearance
    case notifications
    case home
    case signup
    case login
    case forgot
    case onboarding
    case verifyOtp(emailId:String? = "",from:ToVerify,username:String? = "")
    case resetPassword(username:String? = "")
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
