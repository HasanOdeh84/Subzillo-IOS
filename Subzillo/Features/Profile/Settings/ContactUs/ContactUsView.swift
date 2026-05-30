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
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                Spacer()
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Contact Us")
                        .font(.geistBold(16))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                }
                
                Spacer()
                
                // MARK: - Empty Space
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.bottom, 22)
            .padding(.top, 56)
            
            VStack(alignment: .leading, spacing: 30) {
                // MARK: Description
                Text("We're here to help! Reach out to us for any suggestions, complaints, or issues. We'll get back to you as soon as possible.")
                    .font(.geistMedium(12))
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    .lineSpacing(4)
                    .padding(.horizontal, 5)
                
                // MARK: Contact Cards
                VStack(spacing: 16) {
                    ContactCard(
                        iconName: "call",
                        title: "Call Us",
                        value: "Talk to our support team directly.",//settingsVM.privacyData?.phone ?? "",
                        action: {
                            makeCall()
                        }
                    )
                    
                    ContactCard(
                        iconName: "mail",
                        title: "Email Us",
                        value: "Send us an email anytime.",//settingsVM.privacyData?.email ?? "",
                        action: {
                            sendEmail()
                        }
                    )
                }
                .padding(.horizontal, 5)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .applyAppBackground()
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
    @EnvironmentObject var themeManager         : ThemeManager
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading,spacing: 0) {
                HStack(spacing: 12) {
                    // Icon Container
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.accentGradient)
                            .frame(width: 58, height: 58)
                        
                        Image(iconName)
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                    .padding(.bottom, 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // Title
                        Text(title)
                            .font(.geistSemiBold(16))
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                            )
                        
                        // Subtitle
                        Text(value)
                            .font(.geistMedium(10))
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                    }
                    
                    Spacer()
                    
                    // Arrow
                    Image("backGrayright")
                        .renderingMode(.template)
                        .frame(width: 14, height: 14)
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.36)
                        )
                }
                
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(themeManager.white_white4)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.textPrimary0E101AF4F1FB
                            .opacity(0.1),
                        lineWidth: 1
                    )
            )
            //                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContactUsView()
}
