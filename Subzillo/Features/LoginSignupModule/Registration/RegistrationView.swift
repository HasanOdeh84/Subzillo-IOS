//
//  RegistrationView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import SwiftUI

struct RegistrationView: View {
    
    //MARK: - Properties
    @State private var username         = ""
    @State private var fullName         = ""
    @State private var email            = ""
    @State private var mobile           = ""
    @State private var password         = ""
    @State private var confirmPassword  = ""
    @State private var agreeTerms       = false
    @StateObject private var registerVM         = RegistrationViewModel()
    @EnvironmentObject var notificationManager  : NotificationManager
    @Binding var path                           : NavigationPath
    
    //MARK: - Body
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
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
                    
                    // Signup Title
                    Text("Signup")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 20)
                    
                    // Input Fields
                    Group {
                        CustomTextField(placeholder: "User Name", text: $username)
                        CustomTextField(placeholder: "Full Name", text: $fullName)
                        CustomTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                        CustomTextField(placeholder: "Mobile Number (Optional)", text: $mobile, keyboardType: .phonePad)
                        CustomSecureField(placeholder: "Password", text: $password)
                        CustomSecureField(placeholder: "Confirm Password", text: $confirmPassword)
                    }
                    
                    // Password Rules
                    VStack(alignment: .leading, spacing: 8) {
                        PasswordRuleView(rule: "At least 8 characters", isValid: password.count >= 8)
                        PasswordRuleView(rule: "One uppercase letter (e.g., Subzillo1)", isValid: password.range(of: "[A-Z]", options: .regularExpression) != nil)
                        PasswordRuleView(rule: "One number (e.g., Secure123)", isValid: password.range(of: "\\d", options: .regularExpression) != nil)
                        PasswordRuleView(rule: "One special character (e.g., Pa$$word!)", isValid: password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil)
                    }
                    .font(.footnote)
                    .foregroundColor(ColorConstants.black)
                    
                    // Terms and Conditions
                    Toggle(isOn: $agreeTerms) {
                        Text("I agree to the terms and conditions")
                            .font(.footnote)
                            .foregroundStyle(.black)
                    }
                    .toggleStyle(CheckboxToggleStyle())   // ✅ Use directly
                    
                    HStack {
                        Spacer()
                        // Signup Button
                        Button(action: {
                            if let errorMessage = LoginSignupValidations().validateSignup(
                                username: username,
                                fullName: fullName,
                                email: email,
                                mobile: mobile,
                                password: password,
                                confirmPassword: confirmPassword,
                                termsPrivacy: agreeTerms
                            ) {
                                ToastManager.shared.showToast(message: errorMessage)
                            } else {
                                registerVM.register(input: RegisterRequest(username     : username,
                                                                           email        : email,
                                                                           password     : password,
                                                                           fullName     : fullName,
                                                                           platform     : Constants.platform,
                                                                           deviceId     : notificationManager.deviceToken ?? ""),path:$path)
                            }
                        }) {
                            Text("Signup")
                                .frame(width: 160,height: 50,alignment: .center)
    //                            .padding()
                                .background(.gray)
                            //                            .background(isFormValid ? Color.blue : Color.gray)
                                .foregroundColor(ColorConstants.black)
                                .cornerRadius(8)
                        }
                        //                    .disabled(!isFormValid)
                        .padding(.top, 10)
                        Spacer()
                    }
                    
                    // Social logins
                    VStack(spacing: 15) {
                        SocialButton(title: "Continue with Google")
                        SocialButton(title: "Continue with Apple")
                    }
                    .padding(.top, 10)
                    
                    // Login Option
                    HStack {
                        Text("Already have an account?")
                        Button(action: {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                            path.append(PendingRoute.login)
                        }) {
                            Text("Log In")
                                .fontWeight(.bold)
                                .foregroundColor(ColorConstants.black)
                        }
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 24)
                .navigationBarBackButtonHidden(true)
            }
    }
    
    //MARK: - Methods
    // MARK: - Validation
    private var isFormValid: Bool {
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        return !username.isEmpty &&
        !fullName.isEmpty &&
        !email.isEmpty &&
        password.count >= 8 &&
        hasUppercase &&
        hasNumber &&
        hasSpecial &&
        password == confirmPassword &&
        agreeTerms
    }
}

struct PasswordRuleView: View {
    var rule: String
    var isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark" : "checkmark")
                .foregroundColor(isValid ? .green : ColorConstants.black)
            Text(rule)
        }
    }
}

struct SocialButton: View {
    var title: String
    
    var body: some View {
        Button(action: {
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(ColorConstants.black)
                .cornerRadius(8)
        }
    }
}

// MARK: - Checkbox ToggleStyle
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? ColorConstants.primaryBlue : ColorConstants.gray)
                configuration.label
            }
        }
    }
}

#Preview {
//    RegistrationView()
}
