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
    
    //MARK: - body
    var body: some View{
        ZStack{
            Group {
                Color(.appBackground)
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
                        PhoneNumberField(phoneNumber        : $phoneNumber,
                                         header             : verifyData?.verifyType == 1 ? "Enter your phone number" : "Enter your phone number [Optional]",
                                         placeholder        : "000 000 000",
                                         selectedCurrency   : $selectedCurrency,
                                         selectedCountry    : $selectedCountry,
                                         isCountry          : true)
                        .opacity(verifyData?.verifyType == 1 ? 0.5 : 1.0)
                        .disabled(verifyData?.verifyType == 1 ? true : false)
                        
                        ReusableTextField(placeholder: "Enter your full name", text: $fullName,header:"Full Name")
                        ReusableTextField(placeholder: "name@example.com", text: $email, isEmail: true,header: verifyData?.verifyType == 1 ? "Email [Optional]" : "Email")
                            .opacity(verifyData?.verifyType == 2 ? 0.5 : 1.0)
                            .disabled(verifyData?.verifyType == 2 ? true : false)
                    }
                    
                    CustomButton(title: "Finish Sign Up") {
                        signupApi()
                    }
                    
                    TermsAndPrivacyText(
                        onTapTerms: {
                            registerVM.navigate(to: .termsAndPrivacy(isTerm: true))
                        },
                        onTapPrivacy: {
                            registerVM.navigate(to: .termsAndPrivacy(isTerm: false))
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
        let input = RegisterRequest(userId              : verifyData?.userId ?? "",
                                    fullName            : fullName.trimmed,
                                    email               : verifyData?.verifyType == 1 ? email.trimmed : verifyData?.email ?? "",
                                    countryCode         : verifyData?.verifyType == 1 ? verifyData?.countryCode ?? "" : selectedCountry?.dialCode ?? "",
                                    phoneNumber         : verifyData?.verifyType == 1 ? verifyData?.phoneNumber ?? "" : phoneNumber.trimmed)
        if let errorMessage = LoginSignupValidations().validateSignup(input: input) {
            ToastManager.shared.showToast(message: errorMessage,style: ToastStyle.error)
        } else {
            registerVM.register(input: input, verifyType: verifyData?.verifyType ?? 0)
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
