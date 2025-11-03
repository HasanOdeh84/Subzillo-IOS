//
//  RegistrationView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct RegistrationView: View {
    
    //MARK: - Properties
    @State private var username                 = ""
    @State private var fullName                 = ""
    @State private var email                    = ""
    @State private var mobile                   = ""
    @State private var password                 = ""
    @State private var confirmPassword          = ""
    @State private var agreeTerms               = false
    @StateObject private var registerVM         = RegistrationViewModel()
    @EnvironmentObject var appDelegate          : AppDelegate
    @Binding var path                           : NavigationPath
    @State private var familyMembers: [FamilyMember] = [FamilyMember()]
    
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
                    
                    Image("logo_svg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128,height: 88)
                        .padding(.vertical,24)
                    
                    Group {
                        ReusableTextField(placeholder: "Enter your full name", text: $fullName,header:"Full Name")
                        ReusableTextField(placeholder: "name@example.com", text: $email, isEmail: true,header: "Email [Optional]")
                    }
                    
                    ForEach(familyMembers.indices, id: \.self) { index in
                        VStack {
                            FamilyMemberView(member: $familyMembers[index])
                            
                            if familyMembers.count > 1 {
                                Button(action: {
                                    familyMembers.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                    Text("Remove")
                                        .foregroundColor(.red)
                                }
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    
                    underlineText(text: "Add Family Member", image: "profile_add") {
                        familyMembers.append(FamilyMember())
                    }
                    
                    CustomButton(title: "Finish Sign Up") {
                    }
                    Spacer()
                    TermsAndPrivacyText(
                        onTapTerms: {
                            path.append(PendingRoute.termsAndPrivacy(isTerm: true))
                        },
                        onTapPrivacy: {
                            path.append(PendingRoute.termsAndPrivacy(isTerm: false))
                        },
                        bottomPadding: 38
                    )
                }
                .padding(20)
                .navigationBarBackButtonHidden(true)
            }
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
                .foregroundColor(isValid ? .green : Color.black)
            Text(rule)
        }
    }
}

struct SocialButton: View {
    var title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(Color.black)
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
                    .foregroundColor(configuration.isOn ? Color.blueMain700 : Color.gray)
                configuration.label
            }
        }
    }
}

#Preview {
    RegistrationView(path: .constant(NavigationPath()))
}
