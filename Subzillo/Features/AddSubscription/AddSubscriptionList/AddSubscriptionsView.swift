//
//  AddSubscriptionsView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct AddSubscriptionsView: View {
    
    @State var showUploadPopup                 : Bool = false
    @State private var isUploading             = false
    
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
                NormalOptionView(title: "Smart Assistant", subTitle: "Let AI detect and add your subscriptions automatically", buttonImage: "SmartAssistntIcon", titleColor: Color.blueMain700, action: clickOnSmartAssistant)
                    .innerBorder(cornerRadius: 8)
                    .padding(.bottom, 16)
                
                NormalOptionView(title: "Add by Voice", subTitle: "Speak your subscription details to add them easily", buttonImage: "AddVoiceIcon", titleColor: Color.primeryBlue900, action: clickOnAddByVoice)
                    .innerBorder(cornerRadius: 8)
                    .padding(.bottom, 16)
                
                NormalOptionView(title: "Connect Email", subTitle: "Link your inbox to fetch subscriptions from receipts", buttonImage: "connectEmailIcon", titleColor: Color.linearGradient3, action: clickOnConnectEmail)
                    .innerBorder(cornerRadius: 8)
                    .padding(.bottom, 16)
                
                NormalOptionView(title: "Upload a Screenshot", subTitle: "Upload a bill or receipt screenshot to detect details", buttonImage: "uploadScreenshotIcon", titleColor: Color.secondaryPurple700, action: clickOnUploadScreenshot)
                    .innerBorder(cornerRadius: 8)
                    .padding(.bottom, 16)
                
                NormalOptionView(title: "Manual Entry", subTitle: "Fill in your subscription details manually", buttonImage: "ManuvalEntryIcon", titleColor: Color.secondaryNavyBlue400, action: clickOnManuvalEntry)
                    .innerBorder(cornerRadius: 8)
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
            UploadImageSheet(isUploading: $isUploading)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(550)])
                .interactiveDismissDisabled(isUploading)
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
        AppIntentRouter.shared.navigate(to: .connectEmail)
//        ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
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
