//
//  LoginView.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import SwiftUI
import GoogleSignInSwift
import _AuthenticationServices_SwiftUI

struct LoginView: View {
    
    //MARK: - Properties
    @StateObject private var loginVM            = LoginViewModel()
    @State private var phoneNumber              : String = ""
    @State private var email                    : String = ""
    @State private var loginType                : loginType = .google
    @State private var isPasswordVisible        : Bool = false
    @EnvironmentObject var appDelegate          : AppDelegate
    @State private var selectedCurrency         : Currency? = Currency(id: "7603cf97-e39c-48b8-86ec-629429072761", name: "United States Dollarr", symbol: "$", code: "USD")
    //    @State private var selectedCountry          : Currency? = Currency(id: "7603cf97-e39c-48b8-86ec-629429072761", name: "United States Dollarr", symbol: "$", code: "USD")
    @State var segmentSelected  : Segment = .first
    
    //MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Welcome to")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                Image("logo_svg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128,height: 88)
                
                VStack(spacing: 4) {
                    Text("You're not logged in")
                        .font(.appRegular(24))
                        .foregroundColor(.appNeutralMain700)
                        .multilineTextAlignment(.center)
                    Text("Sign in to your Subzillo account")
                        .font(.appRegular(16))
                        .foregroundColor(.appNeutralMain700)
                        .multilineTextAlignment(.center)
                }
                
                HStack(){
                    Text("Login your account using your preferred method")
                        .font(.appRegular(16))
                        .foregroundColor(.appNeutralMain700)
                        .padding(.bottom, -17)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                SegmentView(selectedSegment : $segmentSelected,
                            leftImage       : "call",
                            rightImage      : "email",
                            leftText        : "Phone Number",
                            rightText       : "Email")
                
                
                VStack(spacing: 16){
                    if segmentSelected == .first{
                        PhoneNumberField(phoneNumber        : $phoneNumber,
                                         header             : "Enter your phone number",
                                         placeholder        : "000 000 000",
                                         selectedCurrency   : $selectedCurrency)
                    }else{
                        ReusableTextField(placeholder   : "name@example.com",
                                          text          : $email,
                                          isEmail       : true,
                                          header        : "Enter your email address")
                    }
                    
                    CustomButton(title: "Log In"){
                        let input = checkLoginRequest(
                            loginType       : (segmentSelected == .first ? loginCheckType.mobile : loginCheckType.email).rawValue,
                            email           : email,
                            phoneNumber     : phoneNumber,
                            countryCode     : "91",
                            deviceId        : appDelegate.deviceToken ?? ""
                        )
                        if let errorMessage = LoginSignupValidations().validateLogin(input: input) {
                            ToastManager.shared.showToast(message: errorMessage,style: ToastStyle.error)
                        } else {
                            loginVM.login(input: input)
                        }
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.appNeutral800, lineWidth: 1)
                )
                .background(.appNeutral900)
                .cornerRadius(16)
                
                HStack{
                    Rectangle()
                        .fill(Color.lineGray)
                        .frame(height: 1)
                    Text("Or")
                        .font(.appRegular(14))
                        .foregroundStyle(Color.neutral_2_500)
                    Rectangle()
                        .fill(Color.lineGray)
                        .frame(height: 1)
                }
                
                // Social logins
                VStack(spacing: 8) {
                    SignInWithAppleButton(.continue, onRequest: { request in
                        //Need to configure
                        //                        loginVM.socialLogin(loginType: .apple, path: $path)
                        ToastManager.shared.showToast(message: "coming soon")
                    }, onCompletion: { result in
                        // handle result
                    })
                    .frame(height: 50)
                    .signInWithAppleButtonStyle(.whiteOutline)
                    
                    GradientBorderButton(title: "Continue with Google",isBtn:true, buttonImage: "google") {
                        //Need to configure
                        //                        loginVM.socialLogin(loginType: .google, path: $path)
                        ToastManager.shared.showToast(message: "coming soon")
                    }
                    .background(.appBlackWhite)
                    
                    GradientBorderButton(title: "Continue with Microsoft",isBtn:true, buttonImage: "microsoft") {
                        //Need to configure
                        ToastManager.shared.showToast(message: "coming soon")
                    }
                    .background(.appBlackWhite)
                }
                .padding(.top, 10)
                
                Spacer()
                TermsAndPrivacyText(
                    onTapTerms: {
                        loginVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: true))
                    },
                    onTapPrivacy: {
                        loginVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: false))
                    },
                    bottomPadding: 48
                )
            }
//            .frame(minHeight: UIScreen.main.bounds.height)
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
            Spacer()
        }
        .background(.appBackground)
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView()
}
