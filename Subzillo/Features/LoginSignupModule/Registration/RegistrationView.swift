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
    @State private var selectedCurrency                 : Currency? = Currency(id: "7603cf97-e39c-48b8-86ec-629429072761", name: "United States Dollarr", symbol: "$", code: "USD")
    @State var verifyData                               : LoginSignupVerifyData
    
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
                                         header             : "Enter your phone number",
                                         placeholder        : "000 000 000",
                                         selectedCurrency   : $selectedCurrency)
                        .opacity(verifyData.verifyType == 1 ? 0.5 : 1.0)
                        .disabled(verifyData.verifyType == 1 ? true : false)
                        
                        ReusableTextField(placeholder: "Enter your full name", text: $fullName,header:"Full Name")
                        ReusableTextField(placeholder: "name@example.com", text: $email, isEmail: true,header: "Email")
                    }
                    
//                    if familyMembers?.count != 0 {
//                        ForEach(familyMembers?.indices, id: \.self) { index in
//                            VStack {
//                                FamilyMemberView(member: $familyMembers?[index], action: {
//                                    if familyMembers?.count > 0 {
//                                        familyMembers.remove(at: index)
//                                    }
//                                })
//                            }
//                        }
//                    }
//
//                    underlineText(text: "Add Family Member", image: "profile_add") {
//                        familyMembers.append(FamilyMember())
//                    }
                    
                    CustomButton(title: "Finish Sign Up") {
                    }

                    TermsAndPrivacyText(
                        onTapTerms: {
                            registerVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: true))
                        },
                        onTapPrivacy: {
                            registerVM.navigate(to: NavigationRoute.termsAndPrivacy(isTerm: false))
                        },
                        bottomPadding: 28
                    )
                    Spacer()
                }
//                .frame(minHeight: UIScreen.main.bounds.height)
                .padding(20)
                .navigationBarBackButtonHidden(true)
                .onAppear{
                    if verifyData.verifyType == 1{
                        phoneNumber = verifyData.phoneNumber ?? ""
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
    
//    //MARK: - Methods
//    // MARK: - Validation
//    private var isFormValid: Bool {
//        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
//        let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
//        let hasSpecial = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
//        
//        return !username.isEmpty &&
//        !fullName.isEmpty &&
//        !email.isEmpty &&
//        password.count >= 8 &&
//        hasUppercase &&
//        hasNumber &&
//        hasSpecial &&
//        password == confirmPassword &&
//        agreeTerms
//    }
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
//
//#Preview {
//    RegistrationView()
//}
