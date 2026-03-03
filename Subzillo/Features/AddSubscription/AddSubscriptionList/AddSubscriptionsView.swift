//
//  AddSubscriptionsView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct AddSubscriptionsView: View {
    
    //MARK: Properties
    @State var showUploadPopup                 : Bool = false
    @State private var isUploading             = false
    @StateObject private var sharedImageManager = SharedImageManager.shared
    @StateObject private var uploadImageVM      = UploadImageViewModel()
    @StateObject var commonVM                   = CommonAPIViewModel()
    
    //MARK: Body
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            //MARK: Header
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
//                                GradienCustomeView(title: "Upload Bank Notification", subTitle: "Try voice recording for the fastest way to add multiple subscriptions at once.")
//                                    .padding(.bottom,90)
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
        .onAppear {
            if let image = sharedImageManager.sharedImage {
                handleSharedImageUpload(image)
                sharedImageManager.sharedImage = nil
            }
            commonVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
        }
        .sheet(isPresented: $uploadImageVM.showErrorPopup, onDismiss: {
            isUploading = false
        }) {
            UploadErrorImageSheet(
                onDelegate: {
                },
                onDismiss: {
                    isUploading = false
                }
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(560)])
        }
    }
    
    //MARK: User defined methods
    private func handleSharedImageUpload(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            isUploading = true
            let timestamp = Int(Date().timeIntervalSince1970)
            let filename = "shared_image_\(timestamp).jpg"
            
            uploadImageVM.imageSubscription(
                input       : UpdateProfileImageRequest(userId: Constants.getUserId()),
                fileData    : [MultiPartFileInput(
                    fieldName   : "screenshot",
                    fileName    : filename,
                    mimeType    : "image/jpeg",
                    fileData    : imageData
                )],
                showLoader  : true
            )
        }
    }
    
    //MARK: - Button actions
    private func goToNotifications() {
        Constants.FeatureConfig.performS4Action {
            uploadImageVM.navigate(to: .notifications)
        }
    }
    private func clickOnSmartAssistant() {
        Constants.FeatureConfig.performS5Action {
        }
    }
    private func clickOnAddByVoice() {
//        if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
//            SheetManager.shared.isUpgradeSheetVisible = true
//        } else {
//            AppIntentRouter.shared.navigate(to: .voiceCommandView)
//        }
        AppIntentRouter.shared.navigate(to: .voiceCommandView)
    }
    private func clickOnConnectEmail() {
//        if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
//            SheetManager.shared.isUpgradeSheetVisible = true
//        } else {
//            AppIntentRouter.shared.navigate(to: .connectEmail)
//            ToastManager.shared.showToast(message: "Coming soon in S4",style:ToastStyle.info)
//        }
        AppIntentRouter.shared.navigate(to: .connectEmail)
    }
    private func clickOnUploadScreenshot() {
//        if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
//            SheetManager.shared.isUpgradeSheetVisible = true
//        } else {
//            showUploadPopup = true
//        }
        showUploadPopup = true
    }
    private func clickOnManuvalEntry() {
//        if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
//            SheetManager.shared.isUpgradeSheetVisible = true
//        } else {
//            AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
//        }
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
    }
    private func clickOnUploasBankNotification() {
        Constants.FeatureConfig.performS5Action {
        }
    }
}

#Preview {
    AddSubscriptionsView()
}
