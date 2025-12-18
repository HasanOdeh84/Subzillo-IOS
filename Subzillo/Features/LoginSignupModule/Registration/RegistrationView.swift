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
    @State private var familyMembers                    : [FamilyMember]?
    @State private var selectedCountry                  : Country?
    @State private var selectedCurrency                 : Currency?
    @State var verifyData                               : LoginSignupVerifyData?
    @EnvironmentObject var sessionManager               : SessionManager
    @State var fromSocialLogin                          = false
    @State var isEmailDisabled                          = false
    @State var isNameDisabled                           = false
    @State var appleEmail                               = ""
    
    //MARK: - body
    var body: some View{
        ZStack{
            Group {
                Color(.neutralBg100)
            }
            .ignoresSafeArea()
            
            ScrollView{
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
                        .padding(.vertical,24)
                    
                    Group {
                        if fromSocialLogin{
                            PhoneNumberField(phoneNumber        : $phoneNumber,
                                             header             : email == "" ? "Phone number" : "Phone number [Optional]",
                                             placeholder        : "000 000 000",
                                             selectedCurrency   : $selectedCurrency,
                                             selectedCountry    : $selectedCountry,
                                             isCountry          : true,
                                             fromSingup         : true,
                                             fromSocailLogin    : fromSocialLogin)
                            .addDoneButton{
                            }
                            ReusableTextField(placeholder: "Enter your full name", text: $fullName,header:"Full Name")
                                .disabled(isNameDisabled)
                            ReusableTextField(placeholder: "name@example.com", text: $email, isEmail: true,header: "Email")
                                .disabled(isEmailDisabled)
                        }else{
                            PhoneNumberField(phoneNumber        : $phoneNumber,
                                             header             : verifyData?.verifyType == 1 ? "Phone number" : "Phone number [Optional]",
                                             placeholder        : "000 000 000",
                                             selectedCurrency   : $selectedCurrency,
                                             selectedCountry    : $selectedCountry,
                                             isCountry          : true,
                                             fromSingup         : true,
                                             fromSocailLogin    : fromSocialLogin)
                            .opacity(verifyData?.verifyType == 1 ? 0.5 : 1.0)
                            .disabled(verifyData?.verifyType == 1 ? true : false)
                            .if(verifyData?.verifyType != 1) { view in
                                view.addDoneButton{}
                            }
                            ReusableTextField(placeholder: "Enter your full name", text: $fullName,header:"Full Name")
                                .if(verifyData?.verifyType == 1) { view in
                                    view.addDoneButton{}
                                }
                            ReusableTextField(placeholder: "name@example.com", text: $email, isEmail: true,header: verifyData?.verifyType == 1 ? "Email [Optional]" : "Email")
                                .opacity(verifyData?.verifyType == 2 ? 0.5 : 1.0)
                                .disabled(verifyData?.verifyType == 2 ? true : false)
                        }
                    }
                    
                    CustomButton(title: "Finish Sign Up") {
                        signupApi()
                    }
                    
                    TermsAndPrivacyText(
                        onTapTerms: {
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                            //                            registerVM.navigate(to: .termsAndPrivacy(isTerm: true))
                        },
                        onTapPrivacy: {
                            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
                            //                            registerVM.navigate(to: .termsAndPrivacy(isTerm: false))
                        },
                        bottomPadding: 28
                    )
                    Spacer()
                }
                //                .addDoneButtonToKeyboard()
                .padding(20)
                .navigationBarBackButtonHidden(true)
                .onAppear{
                    if let data = SessionManager.shared.loginData{
                        verifyData = data
                        if verifyData?.verifyType == 1{
                            phoneNumber = verifyData?.phoneNumber ?? ""
                        }else{
                            email       = verifyData?.email ?? ""
                        }
                        if fromSocialLogin{
                            isEmailDisabled = email == "" ? false : true
                            if verifyData?.email?.contains("@privaterelay.appleid.com") == true{
                                appleEmail  = verifyData?.email ?? ""
                                email       = ""
                                isEmailDisabled = false
                            }else{
                                email       = verifyData?.email ?? ""
                                isEmailDisabled = email == "" ? false : true
                            }
                            fullName        = verifyData?.fullName ?? ""
                            isNameDisabled = fullName == "" ? false : true
                        }
                    }
                }
            }
            .keyboardAdaptive()
            .ignoresSafeArea()
        }
    }
    
    //MARK: - Methods
    //MARK: - Signup API
    func signupApi(){
        let phone = phoneNumber.normalizedPhoneNumber()
        let countryCode = phoneNumber.trimmed == "" ? "" : (verifyData?.verifyType == 1 ? verifyData?.countryCode ?? "" : selectedCountry?.dialCode ?? "")
        var input = RegisterRequest(userId              : verifyData?.userId ?? "",
                                    fullName            : fullName.trimmed,
                                    email               : verifyData?.verifyType == 1 ? email.trimmed : verifyData?.email ?? "",
                                    countryCode         : countryCode,
                                    phoneNumber         : verifyData?.verifyType == 1 ? verifyData?.phoneNumber ?? "" : phone.trimmed)
        if fromSocialLogin{
            input = RegisterRequest(userId              : verifyData?.userId ?? "",
                                    fullName            : fullName.trimmed,
                                    email               : email.trimmed,
                                    countryCode         : phoneNumber.trimmed == "" ? "" : selectedCountry?.dialCode ?? "",
                                    phoneNumber         : phone.trimmed)
        }
        if let errorMessage = LoginSignupValidations().validateSignup(input: input,isSocialLogin: fromSocialLogin) {
            ToastManager.shared.showToast(message: errorMessage,style: ToastStyle.error)
        } else {
            registerVM.register(input: input, verifyType: verifyData?.verifyType ?? 0,fromSocialLogin:fromSocialLogin,appleEmail: appleEmail, verifyData: verifyData)
        }
    }
}

struct PasswordRuleView: View {
    var rule: String
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

//#Preview {
//    RegistrationView()
//}
