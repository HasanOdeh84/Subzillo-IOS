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
    @State private var selectedCurrency         : Currency?
    @State private var selectedCountry          : Country?
    @State var segmentSelected                  : Segment? = .first
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    
    //MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Welcome to")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                
                Image("logo_svg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128,height: 88)
                
                //                VStack(spacing: 4) {
                //                    Text("You're not logged in")
                //                        .font(.appRegular(24))
                //                        .foregroundColor(.neutralMain700)
                //                        .multilineTextAlignment(.center)
                //                    Text("Sign in to your Subzillo account")
                //                        .font(.appRegular(16))
                //                        .foregroundColor(Color.neutralMain700)
                //                        .multilineTextAlignment(.center)
                //                }
                
                //                HStack(){
                //                    Text("Login your account using your preferred method")
                //                        .font(.appRegular(16))
                //                        .foregroundColor(Color.neutralMain700)
                //                        .padding(.bottom, -17)
                //                        .multilineTextAlignment(.leading)
                //                    Spacer()
                //                }
                
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
                                         selectedCurrency   : $selectedCurrency,
                                         selectedCountry    : $selectedCountry,
                                         isCountry          : true)
                        .addDoneButton{
                            
                        }
                    }else{
                        ReusableTextField(placeholder   : "name@example.com",
                                          text          : $email,
                                          isEmail       : true,
                                          header        : "Enter your email address")
                    }
                    
                    CustomButton(title: "Log In"){
                        loginApi()
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.neutral300Border, lineWidth: 1)
                )
                .background(Color.whiteNeutralCardBG)
                .cornerRadius(16)
                
                HStack{
                    Rectangle()
                        .fill(Color.lineGray)
                        .frame(height: 1)
                    Text("Or")
                        .font(.appRegular(14))
                        .foregroundStyle(.neutral2500)
                    Rectangle()
                        .fill(Color.lineGray)
                        .frame(height: 1)
                }
                
                // Social logins
                VStack(spacing: 8) {
                    /*
                     AppleSignInButtonView {
                     loginVM.socialLogin(loginType: .apple,deviceId: appDelegate.deviceToken ?? "")
                     }
                     
                     GradientBorderButton(title: "Continue with Google",isBtn:true, buttonImage: "google") {
                     loginVM.socialLogin(loginType: .google,deviceId: appDelegate.deviceToken ?? "")
                     }
                     .background(.whiteBlackBG)
                     
                     GradientBorderButton(title: "Continue with Microsoft",isBtn:true, buttonImage: "microsoft") {
                     loginVM.socialLogin(loginType: .microsoft,deviceId: appDelegate.deviceToken ?? "")
                     }
                     .background(.whiteBlackBG)
                     */
                    
                    SignInBorderButton(title: "Continue with Apple", buttonImage: "apple_withoutPadding"){
                        loginVM.socialLogin(loginType: .apple,deviceId: appDelegate.deviceToken ?? "")
                    }
                    .background(.whiteBlack)
                    
                    SignInBorderButton(title: "Continue with Google", buttonImage: "google"){
                        loginVM.socialLogin(loginType: .google,deviceId: appDelegate.deviceToken ?? "")
                    }
                    .background(.whiteBlack)
                    
                    SignInBorderButton(title: "Continue with Microsoft", buttonImage: "microsoft"){
                        loginVM.socialLogin(loginType: .microsoft,deviceId: appDelegate.deviceToken ?? "")
                    }
                    .background(.whiteBlack)
                }
                .padding(.top, 10)
                
                TermsAndPrivacyText(
                    onTapTerms: {
                        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        //                        loginVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: true))
                    },
                    onTapPrivacy: {
                        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                        //                        loginVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: false))
                    }
                )
                .padding(.top,6)
                .padding(.bottom,20)
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
            .onAppear{
                if commonApiVM.countryError != nil {
                    commonApiVM.getCountries()
                } else if let data = commonApiVM.countriesResponse {
                    selectedCountry = data.first(where: { $0.countryCode == Constants.shared.regionCode })
                }
            }
        }
        .keyboardAdaptive()
        .dismissKeyboardOnBackgroundTap()
        .background(.neutralBg100)
        .ignoresSafeArea()
    }
    
    //MARK: - User defined methods
    func loginApi(){
        let phone = phoneNumber.normalizedPhoneNumber()
        let ph = PhoneNumberFormatterService(regionCode: selectedCountry?.countryCode ?? "").formattedNumber(digits: phoneNumber)
        print("phone no is \(phone) \(ph)")
        let input = checkLoginRequest(
            loginType       : (segmentSelected == .first ? loginCheckType.mobile : loginCheckType.email).rawValue,
            email           : email.trimmed,
            phoneNumber     : phone,
            countryCode     : selectedCountry?.dialCode ?? "",
            deviceId        : appDelegate.deviceToken ?? ""
        )
        if let errorMessage = LoginSignupValidations().validateLogin(input: input) {
            ToastManager.shared.showToast(message: errorMessage,style: ToastStyle.error)
        } else {
            loginVM.login(input: input, formattedPhNo: ph)
        }
    }
}

#Preview {
    LoginView()
}

//MARK: - Apple signin button
struct AppleSignInButtonView: View {
    var action : () -> Void
    var body: some View {
        SignInWithAppleButton(.continue, onRequest: { request in
            action()
        }, onCompletion: { result in
            print("success")
            // handle result
        })
        .frame(height: 50)
        .signInWithAppleButtonStyle(.whiteOutline)
    }
}
