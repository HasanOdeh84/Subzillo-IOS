//
//  LoginView.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import SwiftUI

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
                
                // App Title
                VStack(spacing: 4) {
                    Text("Subzillo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Smart way to manage all your subscriptions")
                        .font(.subheadline)
                        .foregroundColor(ColorConstants.black)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                
                HStack{
                    // Signup Title
                    Text("Login")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 24)
                    Spacer()
                }
                
                // Username
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                // Password
                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                HStack{
                    Spacer()
                    Button("Forgot Password?"){
                        path.append(PendingRoute.forgot)
                    }
                    .foregroundColor(.black)
                }
                
                CustomButton(title: "Login") {
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
                VStack(spacing: 15) {
                    SocialButton(title: "Continue with Google")
                    SocialButton(title: "Continue with Apple")
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Signup
                HStack {
                    Text("Don't have an account?")
                    Button(action: {
                        if !path.isEmpty {
                            path.removeLast()
                        }
                        path.append(PendingRoute.signup)
                    }) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 32)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    LoginView(path: .constant(NavigationPath()))
}
