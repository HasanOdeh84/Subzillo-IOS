//
//  ForgotPasswordView.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 03/09/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    //MARK: - Properties
    @State private var username         : String = ""
    @Environment(\.dismiss) private var dismiss   // To go back
    @StateObject var forgotVM           = ForgotPasswordViewModel()
    
    //MARK: - Body
    var body: some View {
        VStack(alignment: .leading,spacing: 24) {
            Button(action: {
                dismiss()  // Go back
            }) {
                HStack {
                    Image("back")
                }
                .foregroundColor(.blue)
            }
            .padding(.top,10)
            
            Text("Forgot Password?")
                .font(.appBold(24))
                .fontWeight(.bold)
            
            Text("Enter your registered username to reset your password.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            CustomTextField(placeholder: "Enter your username", text: $username)
            
            HStack{
                Spacer()
                CustomButton(title: "Reset") {
                    if let errorMessage = LoginSignupValidations().validateForgotPassword(username: username) {
                        ToastManager.shared.showToast(message: errorMessage)
                    } else {
                        forgotVM.forgotPassword(input: ForgotPasswordRequest(username: username))
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ForgotPasswordView()
}
