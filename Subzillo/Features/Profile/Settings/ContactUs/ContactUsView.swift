//
//  ContactUSView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//

import SwiftUI

struct ContactUsView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject var settingsVM = SettingsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image("back_gray")
                        .frame(width: 24,height: 24)
                }
                
                Text("Contact Us")
                    .font(.appRegular(24))
                    .foregroundColor(.neutralMain700)
                
                Spacer()
            }
            .padding(.top, 60)
            .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 30) {
                // MARK: Description
                Text("Don't hesitate to contact us whether you have a suggestion on our improvement, a complain to discuss or an issue to solve.")
                    .font(.appRegular(14))
                    .foregroundColor(.neutralMain700)
                    .lineSpacing(4)
                    .padding(.horizontal, 5)
                
                // MARK: Contact Cards
                HStack(spacing: 16) {
                    ContactCard(
                        iconName: "call",
                        title: "Call Us",
                        value: settingsVM.privacyData?.phone ?? "",
                        action: {
                            makeCall()
                        }
                    )
                    
                    ContactCard(
                        iconName: "mail",
                        title: "Email Us",
                        value: settingsVM.privacyData?.email ?? "",
                        action: {
                            sendEmail()
                        }
                    )
                }
                .padding(.horizontal, 5)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color.neutralBg100)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear{
            settingsVM.getPrivacyData(type: 3)
        }
    }
    
    // MARK: - User defined Methods
    private func makeCall() {
        guard let phone = settingsVM.privacyData?.phone, !phone.isEmpty else { return }
        let phoneNumber = phone.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail() {
        guard let email = settingsVM.privacyData?.email, !email.isEmpty else { return }
        if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct ContactCard: View {
    let iconName    : String
    let title       : String
    let value       : String
    let action      : () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primaryBlue800)
                        .frame(width: 44, height: 44)
                    
                    Image(iconName)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                .padding(.bottom, 4)
                
                Text(title)
                    .font(.appSemiBold(18))
                    .foregroundColor(.black)
                
                Text(value)
                    .font(.appRegular(11))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.neutral300Border, lineWidth: 1)
            )
            //                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContactUsView()
}
