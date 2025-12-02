//
//  AddSubscriptionsView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct AddSubscriptionsView: View {
    
    @State var showUploadPopup                 : Bool = false
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            //MARK: - Header
            HeaderView(title        : "Add subscription",
                       subTitle     : "Choose how you'd like to add your subscription",
                       titleFont    : 24) {
                goToNotifications()
            }
            .padding(.top, 50)
            .frame(alignment: .leading)
            
            ScrollView(showsIndicators: false) {
                GradientBorderView(title: "Smart Assistant", subTitle: "Let AI detect and add your subscriptions automatically", buttonImage: "SmartAssistntIcon", action: clickOnSmartAssistant, titleColor: Color.blueMain700)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Add by Voice", subTitle: "Speak your subscription details to add them easily", buttonImage: "AddVoiceIcon", action: clickOnAddByVoice, titleColor: Color.primeryBlue900)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Connect Email", subTitle: "Link your inbox to fetch subscriptions from receipts", buttonImage: "connectEmailIcon", action: clickOnConnectEmail, titleColor: Color.linearGradient3)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Upload Screenshot", subTitle: "Upload a bill or receipt screenshot to detect details", buttonImage: "uploadScreenshotIcon", action: clickOnUploadScreenshot, titleColor: Color.secondaryPurple700)
                    .padding(.bottom, 16)
                
                GradientBorderView(title: "Manual Entry", subTitle: "Fill in your subscription details manually", buttonImage: "ManuvalEntryIcon", action: clickOnManuvalEntry, titleColor: Color.secondaryNavyBlue400)
                    .padding(.bottom,90)
                
//                GradientBorderView(title: "Upload Bank Notification", subTitle: "Add subscriptions from your bank messages or alerts", buttonImage: "uploadBankIcon", action: clickOnUploasBankNotification, titleColor: Color.purple500)
//                    .padding(.bottom, 16)
//                
//                GradienCustomeView(title: "Upload Bank Notification", subTitle: "Try voice recording for the fastest way to add multiple subscriptions at once.")
//                    .padding(.bottom,90)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
        }
        .background(Color.neutralBg100)
        .padding(20)
        .sheet(isPresented: $showUploadPopup) {
            UploadImageSheet()
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(550)])
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showUploadPopup = false
        }
    }
    
    //MARK: - Button actions
    private func goToNotifications() {
        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
    }
    private func clickOnSmartAssistant() {
        ToastManager.shared.showToast(message: "Coming soon in S5",style:ToastStyle.info)
    }
    private func clickOnAddByVoice() {
        AppIntentRouter.shared.navigate(to: .voiceCommandView)
    }
    private func clickOnConnectEmail() {
        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
    }
    private func clickOnUploadScreenshot() {
        showUploadPopup = true
    }
    private func clickOnManuvalEntry() {
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
    }
    private func clickOnUploasBankNotification() {
        ToastManager.shared.showToast(message: "Coming soon in next version",style:ToastStyle.info)
    }
}

#Preview {
    AddSubscriptionsView()
}
