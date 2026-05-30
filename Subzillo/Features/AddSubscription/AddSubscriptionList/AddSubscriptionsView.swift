//
//  AddSubscriptionsView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct AddSubscriptionsView: View {
    
    //MARK: Properties
    @State var showUploadPopup                  : Bool = false
    @State private var isUploading              = false
    @StateObject private var sharedImageManager = SharedImageManager.shared
    @StateObject private var uploadImageVM      = UploadImageViewModel()
    @StateObject var commonVM                   = CommonAPIViewModel()
    @EnvironmentObject var themeManager         : ThemeManager
    
    //MARK: Body
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            //MARK: Header
           /* HeaderView(title        : "Add subscription",
                       subTitle     : "Choose how you'd like to add your subscription",
                       titleFont    : 24) {
                goToNotifications()
            }
                       .padding(.top, 50)
                       .frame(alignment: .leading)*/
            
            /*ScrollView(showsIndicators: false) {
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
                
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)*/
            
            Text("Add subscription")
                .font(.geistSemiBold(16))
                .foregroundColor(
                    Color("TextPrimary_ 0E101A_F4F1FB")
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
            
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                        
                    Text("How should we")
                        .font(.geistSemiBold(28))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                        
                    Text("add it?")
                        .font(.jetBrainsSemiBoldItalic(28))
                        .italic()
                        .foregroundStyle(
                            themeManager.accentGradient
                        )
                    
                    
                    Text("Pick your favorite way — you can mix them.")
                        .font(.geistRegular(14))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                
                VStack(spacing: 10) {
                    
                    NormalOptionView(
                        title: "Smart Assistant",
                        subTitle: "Chat with Subzi to add anything",
                        buttonImage: "sparkles",
                        titleColor: .white,
                        isHighlighted: true,
                        action: clickOnSmartAssistant
                    )
                    
                    NormalOptionView(
                        title: "Add by Voice",
                        subTitle: "Say it, we handle the rest",
                        buttonImage: "AddVoiceIcon",
                        titleColor: themeManager.selectedAccent.senColor,
                        action: clickOnAddByVoice
                    )
                    
                    NormalOptionView(
                        title: "Connect Email",
                        subTitle: "Scan Gmail/Outlook receipts",
                        buttonImage: "connectEmailIcon",
                        titleColor: themeManager.selectedAccent.senColor,
                        action: clickOnConnectEmail
                    )
                    
                    NormalOptionView(
                        title: "Upload Screenshot",
                        subTitle: "Photo of a bank notification",
                        buttonImage: "uploadScreenshotIcon",
                        titleColor: themeManager.selectedAccent.senColor,
                        action: clickOnUploadScreenshot
                    )
                    
                    NormalOptionView(
                        title: "Manual Entry",
                        subTitle: "Type the details yourself",
                        buttonImage: "ManuvalEntryIcon",
                        titleColor: themeManager.selectedAccent.senColor,
                        action: clickOnManuvalEntry
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.horizontal, 4)
                .padding(.bottom, 120)
            }
        }
        .padding(20)
        .applyAppBackground()
        
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
            .presentationDetents([.height(540)])
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
            AppIntentRouter.shared.navigate(to: .AgentChatView())
        }
    }
    private func clickOnAddByVoice() {
        Constants.FeatureConfig.performS4Action {
            if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
                //SheetManager.shared.isUpgradeSheetVisible = true
                AppIntentRouter.shared.navigate(to: .exceedLimit)
            } else {
                AppIntentRouter.shared.navigate(to: .voiceCommandView)
            }
        }
    }
    private func clickOnConnectEmail() {
        
        Constants.FeatureConfig.performS4Action {
            if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
               // SheetManager.shared.isUpgradeSheetVisible = true
                AppIntentRouter.shared.navigate(to: .exceedLimit)
            } else {
                AppIntentRouter.shared.navigate(to: .connectEmail)
            }
        }
    }
    private func clickOnUploadScreenshot() {
       Constants.FeatureConfig.performS4Action {
            if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
                //SheetManager.shared.isUpgradeSheetVisible = true
                AppIntentRouter.shared.navigate(to: .exceedLimit)
            } else {
                //showUploadPopup = true
                AppIntentRouter.shared.navigate(to: .uploadView)
            }
        }
    }
    private func clickOnManuvalEntry() {
        Constants.FeatureConfig.performS4Action {
            if commonVM.userInfoResponse?.remainingSubscriptionLimit == 0 {
                //SheetManager.shared.isUpgradeSheetVisible = true
                AppIntentRouter.shared.navigate(to: .exceedLimit)
            } else {
                AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
            }
        }
    }
    private func clickOnUploasBankNotification() {
        Constants.FeatureConfig.performS5Action {
        }
    }
}

#Preview {
    AddSubscriptionsView()
}
