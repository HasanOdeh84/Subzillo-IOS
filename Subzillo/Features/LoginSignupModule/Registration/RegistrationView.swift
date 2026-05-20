//
//  RegistrationView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import SwiftUI

struct RegistrationView: View {
    
    //MARK: - Properties
    @State private var phoneNumber                      : String = ""
    @State private var fullName                         = ""
    @State private var email                            = ""
    @State private var agreeTerms                       = false
    @StateObject private var registerVM                 = RegistrationViewModel()
    @EnvironmentObject var appDelegate                  : AppDelegate
    @State private var selectedCountry                  : Country?
    @State private var selectedCurrency                 : Currency?
    @State var verifyData                               : LoginSignupVerifyData?
    @EnvironmentObject var sessionManager               : SessionManager
    @State var fromSocialLogin                          = false
    @State var isEmailDisabled                          = false
    @State var isNameDisabled                           = false
    @State var appleEmail                               = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager                 : ThemeManager
    
    //MARK: - body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 24) {
                    // Back Button
//                    CircleBackButton {
//                        AppIntentRouter.shared.pop()
//                    }
                    
                    // Logo with Glow
                    ZStack {
                        Circle()
                            .fill(themeManager.accentColor.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)
                        
                        Image("logo_new")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 80)
                    }
                    .padding(.leading, -20)
                    .padding(.bottom, -15)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create your account")
                            .font(.geistBold(26))
                            .foregroundColor(.textPrimary0E101AF4F1FB)
                        
                        Text("Sign in to subzillo account")
                            .font(.geistRegular(14))
                            .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    }
                    .padding(.top, -2)
                }
                .padding(.top, 70)
                
                // Form Fields
                VStack(spacing: 14) {
                    Group {
                        if fromSocialLogin {
                            RegistrationFieldSection(header: email == "" ? "ENTER YOUR PHONE NUMBER" : "ENTER YOUR PHONE NUMBER [OPTIONAL]") {
                                PhoneNumberField(phoneNumber: $phoneNumber,
                                                 header: "",
                                                 placeholder: "00 000 0000",
                                                 selectedCurrency: $selectedCurrency,
                                                 selectedCountry: $selectedCountry,
                                                 isCountry: true,
                                                 fromSingup: true,
                                                 fromSocailLogin: fromSocialLogin)
                                .addDoneButton{}
                            }
                            
                            RegistrationFieldSection(header: "FULL NAME", icon: "person_new") {
                                TextField("", text: $fullName, prompt: Text("Enter your full name").foregroundColor(themeManager.textPrimaryLight6_dark62))
                                    .font(.geistMedium(14))
                                    .foregroundColor(.textPrimary0E101AF4F1FB)
                                    .disabled(isNameDisabled)
                            }
                            
                            RegistrationFieldSection(header: "EMAIL", icon: "email_login") {
                                TextField("", text: $email, prompt: Text(verbatim: "name@example.com").foregroundColor(themeManager.textPrimaryLight6_dark62))
                                    .font(.geistMedium(14))
                                    .foregroundColor(.textPrimary0E101AF4F1FB)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .opacity(isEmailDisabled ? 0.5 : 1.0)
                                    .disabled(isEmailDisabled)
                            }
                        } else {
                            let initialVerifyType = verifyData?.originalVerifyType ?? verifyData?.verifyType
                            RegistrationFieldSection(header: initialVerifyType == 1 ? "ENTER YOUR PHONE NUMBER" : "ENTER YOUR PHONE NUMBER [OPTIONAL]") {
                                PhoneNumberField(phoneNumber        : $phoneNumber,
                                                 header             : "",
                                                 placeholder        : "00 000 0000",
                                                 selectedCurrency   : $selectedCurrency,
                                                 selectedCountry    : $selectedCountry,
                                                 isCountry          : true,
                                                 fromSingup         : true,
                                                 fromSocailLogin    : fromSocialLogin)
                                .opacity(initialVerifyType == 1 ? 0.5 : 1.0)
                                .disabled(initialVerifyType == 1)
                                .if(initialVerifyType != 1) { view in
                                    view.addDoneButton{}
                                }
                            }
                            
                            RegistrationFieldSection(header: "FULL NAME", icon: "person_new") {
                                TextField("", text: $fullName, prompt: Text("Enter your full name").foregroundColor(themeManager.textPrimaryLight6_dark62))
                                    .font(.geistMedium(14))
                                    .foregroundColor(.textPrimary0E101AF4F1FB)
                                    .if(initialVerifyType == 1) { view in
                                        view.addDoneButton{}
                                    }
                            }
                            
                            RegistrationFieldSection(header: initialVerifyType == 1 ? "EMAIL [OPTIONAL]" : "EMAIL", icon: "email_login") {
                                TextField("", text: $email, prompt: Text(verbatim: "name@example.com").foregroundColor(themeManager.textPrimaryLight6_dark62))
                                    .font(.geistMedium(14))
                                    .foregroundColor(.textPrimary0E101AF4F1FB)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .opacity(initialVerifyType == 2 ? 0.5 : 1.0)
                                    .disabled(initialVerifyType == 2)
                            }
                        }
                    }
                    
                    GradientBgButton(
                        title       : "Create account",
                        isSolid     : true,
                        showChevron : true
                    ) {
                        signupApi()
                    }
                    .padding(.top, 12)
                    
                    TermsAndPrivacyText(
                        onTapTerms: {
                            Constants.FeatureConfig.performS4Action {
                                registerVM.navigate(to: .termsAndPrivacy(isTerm: true))
                            }
                        },
                        onTapPrivacy: {
                            Constants.FeatureConfig.performS4Action {
                                registerVM.navigate(to: .termsAndPrivacy(isTerm: false))
                            }
                        }
                    )
                    .padding(.top, 12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .applyAppBackground()
        .navigationBarBackButtonHidden(true)
        .keyboardAdaptive()
        .ignoresSafeArea()
        .onAppear {
            if let data = SessionManager.shared.loginData {
                verifyData = data
                let initialVerifyType = verifyData?.originalVerifyType ?? verifyData?.verifyType
                if initialVerifyType == 1 {
                    phoneNumber = verifyData?.formattedPhNo ?? verifyData?.phoneNumber ?? ""
                    if let savedEmail = verifyData?.email, !savedEmail.isEmpty {
                        email = savedEmail
                    }
                } else {
                    email = verifyData?.email ?? ""
                    if let savedPhone = verifyData?.formattedPhNo, !savedPhone.isEmpty {
                        phoneNumber = savedPhone
                    }
                }
                if let savedName = verifyData?.fullName, !savedName.isEmpty {
                    fullName = savedName
                }
                if fromSocialLogin {
                    isEmailDisabled = email == "" ? false : true
                    if verifyData?.email?.contains("@privaterelay.appleid.com") == true {
                        appleEmail = verifyData?.email ?? ""
                        email = ""
                        isEmailDisabled = false
                    } else {
                        email = verifyData?.email ?? ""
                        isEmailDisabled = email == "" ? false : true
                    }
                    fullName = verifyData?.fullName ?? ""
                    isNameDisabled = fullName == "" ? false : true
                }
            }
        }
    }
    
    //MARK: - Methods
    //MARK: - Signup API
    func signupApi() {
        let phone = phoneNumber.normalizedPhoneNumber()
        let countryCode = phoneNumber.trimmed == "" ? "" : (verifyData?.verifyType == 1 ? verifyData?.countryCode ?? "" : selectedCountry?.dialCode ?? "")
        var input = RegisterRequest(userId              : verifyData?.userId ?? "",
                                    fullName            : fullName.trimmed,
                                    email               : verifyData?.verifyType == 1 ? email.trimmed : verifyData?.email ?? "",
                                    countryCode         : countryCode,
                                    phoneNumber         : verifyData?.verifyType == 1 ? verifyData?.phoneNumber ?? "" : phone.trimmed)
        if fromSocialLogin {
            input = RegisterRequest(userId              : verifyData?.userId ?? "",
                                    fullName            : fullName.trimmed,
                                    email               : email.trimmed,
                                    countryCode         : phoneNumber.trimmed == "" ? "" : selectedCountry?.dialCode ?? "",
                                    phoneNumber         : phone.trimmed)
        }
        if let errorMessage = LoginSignupValidations().validateSignup(input: input, isSocialLogin: fromSocialLogin) {
            ToastManager.shared.showToast(message: errorMessage.localized, style: ToastStyle.error)
        } else {
            registerVM.register(input: input, verifyType: verifyData?.verifyType ?? 0, fromSocialLogin: fromSocialLogin, appleEmail: appleEmail, verifyData: verifyData, formattedPhNo: phoneNumber)
        }
    }
}

struct RegistrationFieldSection<Content: View>: View {
    let header: String
    var icon: String? = nil
    let content: Content
    
    @EnvironmentObject var themeManager: ThemeManager
    
    init(header: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.header = header
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(header))
                .font(.jetBrainsMedium(11))
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                .tracking(1.2)
            
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(icon)
//                        .renderingMode(.template)
//                        .foregroundColor(.textPrimary0E101AF4F1FB.opacity(0.6))
                        .frame(width: 20, height: 20)
                }
                
                content
            }
            .padding(.horizontal, icon != nil ? 16 : 0)
            .frame(height: 56)
            .background(icon != nil ? Color.cardBgLoginFFFFFFFFFFFF : Color.clear)
            .cornerRadius(12)
            .overlay(
                Group {
                    if icon != nil {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.cardBorderE2E8F0E2E8F0, lineWidth: 1)
                    }
                }
            )
        }
    }
}

struct PasswordRuleView: View {
    var rule: LocalizedStringKey
    var isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark" : "checkmark")
                .foregroundColor(isValid ? .green : Color.black)
            Text(rule)
        }
    }
}

// MARK: - Checkbox ToggleStyle
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? Color.blueMain700 : Color.gray)
                configuration.label
            }
        }
    }
}
