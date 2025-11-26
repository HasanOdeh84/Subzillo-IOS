//
//  OtpSuccessView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 03/11/25.
//

import SwiftUI

enum SuccessRedirection{
    case signup
    case onboarding
}

struct SuccessView: View {
    
    //MARK: - Properties
    var isOtp: Bool?
    var isMobile: Bool?
    var toScreen: SuccessRedirection = .signup
    
    var body: some View {
        ZStack{
            Group {
                Color(.neutralBg100)
            }
            .ignoresSafeArea()
            
            VStack() {
                if isOtp ?? false{
                    Text("Welcome to")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .multilineTextAlignment(.center)
                        .padding(.top,20)
                    
                    Image("logo_svg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128,height: 88)
                        .padding(.top,24)
                        .padding(.bottom,106)
                    
                    LottieView(name: "success")
                        .frame(width: 127,height: 127)
                    
                    Text((isMobile ?? false) ? "Phone Number\n Verified" : "Email\n Verified")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .multilineTextAlignment(.center)
                        .padding(.top,24)
                    Spacer()
                }else{
                    SignupSuccessView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if self.isOtp ?? false{
                        AppIntentRouter.shared.navigate(to: .signup())
                    }else{
                        AppIntentRouter.shared.navigate(to: .onboarding)
                    }
                }
            }
        }
    }
}

struct SignupSuccessView: View {
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image("logo_svg")
                .resizable()
                .scaledToFit()
                .frame(width: 128,height: 88)
            
            Text("Welcome to")
                .font(.appRegular(24))
                .foregroundColor(Color.neutralMain700)
                .multilineTextAlignment(.center)
            
            LottieView(name: "success")
                .frame(width: 127,height: 127)
            
            Text("Account created successfully")
                .font(.appRegular(24))
                .foregroundColor(Color.neutralMain700)
                .multilineTextAlignment(.center)
            
            GradienCustomeView(title    : "Quick tip",
                               subTitle : "Start by adding your first subscription to see how Subzillo helps you stay organized.")
            .padding(.horizontal,24)
            Spacer()
        }
    }
}

#Preview {
    SuccessView()
}
