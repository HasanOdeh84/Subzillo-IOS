//
//  ResetPasswordView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 25/09/25.
//

import SwiftUI

struct ResetPasswordView: View {
    
    //MARK: - Properties
    @State var username                 : String
    @State private var password         = ""
    @State private var confirmPassword  = ""
    @Environment(\.dismiss) private var dismiss   // To go back
    @StateObject var resetVM            = ResetPasswordViewModel()
    @Binding var path                   : NavigationPath
    
    //MARK: - Body
    var body: some View {
        HStack{
            Button(action: {
                dismiss()  // Go back
            }) {
                HStack {
                    Image("back")
                }
                .foregroundColor(.blue)
            }
            .padding(.top,10)
            .padding(.horizontal, 24)
            Spacer()
        }
        ScrollView{
            VStack(alignment: .leading, spacing: 20){
                // Signup Title
                Text("Create New Password")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                // Input Fields
                Group {
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
                
                HStack{
                    Spacer()
                    CustomButton(title: "Reset Password") {
                        if let errorMessage = LoginSignupValidations().validateResetPassword(password: password, confirmPassword: confirmPassword) {
                            ToastManager.shared.showToast(message: errorMessage)
                        } else {
                            resetVM.resetPassword(input: ResetPasswordRequest(username: username,newPassword: password), path: $path)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    //    ResetPasswordView()
}
