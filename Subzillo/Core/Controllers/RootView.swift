//
//  RootView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 24/09/25.
//

import SwiftUI

struct RootView: View {
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if LoginStatus().isLogin() {
                    RootTabBar(path: $path)
                } else {
                    LoginView(path: $path)
                }
            }
            .navigationDestination(for: PendingRoute.self) { screen in
                switch screen {
                case .addSubscription(let service, let plan, let price, let cycle):
                    AddSubscriptionView(
                        serviceName: service,
                        planName: plan,
                        price: price,
                        billingCycle: cycle
                    )
                case .emailIntegration:
                    AddSubscriptionView(
                        serviceName: "service",
                        planName: "plan",
                        price: 990,
                        billingCycle: "cycle"
                    )
                case .bankStatement:
                    Text("Test")
                case .chat:
                    Text("Test")
                case .appearance:
                    Text("Test")
                case .notifications:
                    Text("Test")
                case .home:
                    RootTabBar(path: $path)
                case .forgot:
                    ForgotPasswordView(path:$path)
                case .signup:
                    RegistrationView(path: $path)
                case .login:
                    LoginView(path: $path)
                case .onboarding:
                    OnboardingView()
                case .verifyOtp(let emailId, let from, let username):
                    OtpVerifyView(path:$path, email:emailId ?? "", username:username ?? "", from:from)
                case .resetPassword(let username):
                    ResetPasswordView(username:username ?? "", path:$path)
                }
            }
        }
    }
}


#Preview {
    RootView()
}
