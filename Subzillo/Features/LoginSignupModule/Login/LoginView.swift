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
    @State private var username                 : String = ""
    @State private var password                 : String = ""
    @State private var isPasswordVisible        : Bool = false
    @Binding var path                           : NavigationPath
    @EnvironmentObject var appDelegate          : AppDelegate
    
    //MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Welcome to")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                
                Image("splash_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128,height: 88)
                
                VStack(spacing: 4) {
                    Text("You're not logged in")
                        .font(.appRegular(24))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                    Text("Sign in to your Subzillo account")
                        .font(.appRegular(16))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                }
                
                PhoneNumberField()
                
                CustomButton(title: "Log In") {
                    if let errorMessage = LoginSignupValidations().validateLogin(username: username,
                                                                                 password: password) {
                        ToastManager.shared.showToast(message: errorMessage)
                    } else {
                        let input = LoginRequest(
                            username: username,
                            password: password,
                            deviceId: appDelegate.deviceToken ?? ""
                            //                            pushMode: 1
                        )
                        loginVM.login(input: input,path:$path)
                    }
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
                    
                    GradientBorderButton(title: "Continue with Google",isSocialBtn:true) {
                        //Need to configure
//                        loginVM.socialLogin(loginType: .google, path: $path)
                        ToastManager.shared.showToast(message: "coming soon")
                    }
                    .background(Color.white)
                }
                .padding(.top, 10)
                
                Spacer()
                Text(getAttriText())
                    .font(.appRegular(14))
                    .padding(.horizontal,20)
                    .padding(.bottom,48)
                    .multilineTextAlignment(.center)
                    .environment(\.openURL, OpenURLAction(handler: { url in
                        if url.absoluteString.contains("privacy") {
                            ToastManager.shared.showToast(message: "privacy policy coming soon")
                        }
                        
                        if url.absoluteString.contains("terms") {
                            ToastManager.shared.showToast(message: "terms of service coming soon")
                        }
                        return .systemAction
                    }))
            }
            .frame(minHeight: UIScreen.main.bounds.height)
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
        }
        .background(Color.neutralBg100)
        .ignoresSafeArea()
    }
    
    func getAttriText() -> AttributedString {
        
        var attriString = AttributedString("By continuing, you agree to our Terms of Service and Privacy Policy")
        attriString.foregroundColor = .gray
        
        if let privacyRange = attriString.range(of: "Privacy Policy") {
            attriString[privacyRange].link                  = URL(string: "www.apple.com/privacy")
            attriString[privacyRange].underlineStyle        = .single
            attriString[privacyRange].foregroundColor       = .underlineGray
        }
        
        if let termsRange = attriString.range(of: "Terms of Service") {
            attriString[termsRange].link                = URL(string: "www.apple.com/terms")
            attriString[termsRange].underlineStyle      = .single
            attriString[termsRange].foregroundColor     = .underlineGray
        }
        
        return attriString
    }
}

#Preview {
    LoginView(path: .constant(NavigationPath()))
}
