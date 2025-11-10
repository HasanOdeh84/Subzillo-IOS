//
//  AddSubscriptionsView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct AddSubscriptionsView: View {
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            // MARK: - Header
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: - Title
                    Text("Add subscription")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    // MARK: - SubTitle
                    Text("Choose how you'd like to add your subscription")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                }
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    Button(action: goToNotifications) {
                        
                        Image("notification-03")
                            .frame(width: 32, height: 32)
                    }
                    
                    Text("3")
                        .font(.appBold(11))
                        .foregroundColor(Color.white)
                        .frame(width: 16, height: 16)
                        .background(Color.redBadge)
                        .cornerRadius(4)
                        .offset(x: 0, y: -5)
                    
                }
                .offset(x: 0, y: -10)
                
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            ScrollView {
                GradientBorderView(title: "Smart Assistant", subTitle: "Conversational flow to guide and confirm details", buttonImage: "SmartAssistntIcon", action: clickOnSmartAssistant, titleColor: Color.blueMain700)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Add by Voice", subTitle: "Conversational flow to guide and confirm details", buttonImage: "AddVoiceIcon", action: clickOnAddByVoice, titleColor: Color.primeryBlue900)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Connect Email", subTitle: "Conversational flow to guide and confirm details", buttonImage: "connectEmailIcon", action: clickOnConnectEmail, titleColor: Color.linearGradient3)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Upload Screenshot", subTitle: "Conversational flow to guide and confirm details", buttonImage: "uploadScreenshotIcon", action: clickOnUploadScreenshot, titleColor: Color.secondaryPurple700)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Manual Entry", subTitle: "Conversational flow to guide and confirm details", buttonImage: "ManuvalEntryIcon", action: clickOnManuvalEntry, titleColor: Color.secondaryNavyBlue400)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Upload Bank Notification", subTitle: "Conversational flow to guide and confirm details", buttonImage: "uploadBankIcon", action: clickOnUploasBankNotification, titleColor: Color.purple500)
                    .padding(.bottom, 16)
                
                GradienCustomeView(title: "Upload Bank Notification", subTitle: "Try voice recording for the fastest way to add multiple subscriptions at once.", isBtn: true, action: clickOnUploasBankNotification)
                    .padding(.bottom, 16)
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .padding(.top, 10)
        .background(Color.neutralBg100)
    }
    
    //MARK: - Button actions
    private func goToNotifications() {
    }
    private func clickOnSmartAssistant() {
    }
    private func clickOnAddByVoice() {
    }
    private func clickOnConnectEmail() {
    }
    private func clickOnUploadScreenshot() {
    }
    private func clickOnManuvalEntry() {
    }
    private func clickOnUploasBankNotification() {
    }
}

#Preview {
    AddSubscriptionsView()
}
