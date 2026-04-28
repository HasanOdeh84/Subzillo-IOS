//
//  WelcomeHomeView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct WelcomeHomeView: View {
    
    @State var showUploadPopup          : Bool = false
    @State private var isUploading      = false
    @EnvironmentObject var commonApiVM  : CommonAPIViewModel
    var currentPlan                     : Int = 0
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 4) {
                    
                    ZStack {
                        Text("Welcome to")
                            .font(.appRegular(24))
                            .foregroundColor(Color.neutralMain700)
                            .multilineTextAlignment(.center)
                            .padding(.top, 70)
                            .padding(.bottom, 34)
                        
//                        HStack {
//                            Spacer()
//                            ZStack(alignment: .topTrailing) {
//                                Button(action: goToNotifications) {
//                                    Image("notification-03")
//                                        .frame(width: 32, height: 32)
//                                }
//                                
//                                if let count = commonApiVM.unreadCountResponse?.unreadCount{
//                                    Text("\(count)")
//                                        .font(.appBold(11))
//                                        .foregroundColor(Color.white)
//                                        .frame(width: 16, height: 16)
//                                        .background(Color.redBadge)
//                                        .cornerRadius(4)
//                                        .offset(x: 0, y: -5)
//                                }
//                            }
//                        }
                        .offset(x: 0, y: 10)
                    }
                    
                    Image("logo_svg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 143,height: 99)
                    
                    Text("Track all your subscriptions in one place")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 12) {
                            Spacer()
                            Button(action: goToSmartAssistant) {
                                HStack(spacing: 5) {
                                    Image("robotic")
                                        .frame(width: 20, height: 20)
                                    Text("Add Subscription by AI Agent")
                                        .font(.appSemiBold(16))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(
                                    LinearGradient(
                                        colors: [Color.linearGradient3, Color.linearGradient4, Color.navyBlueCTA700],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                            }
                            //                            .padding(.horizontal, 16)
                            //                      .padding(.top, 24)
                            
                            VStack(spacing: 8) {
                                
                                HStack(spacing: 8) {
                                    Button(action: goToUploadImage) {
                                        HStack(spacing: 5) {
                                            Image("image-upload")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("Upload Image")
                                                .font(.appSemiBold(16))
                                                .foregroundColor(.neutralMain700)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gradientPurple, lineWidth: 1)
                                        )
                                        .background(Color.whiteNeutralCardBG)
                                        .innerBorder(
                                            cornerRadius: 8,
                                            color: Color.innerShadow.opacity(0.6)
                                        )
                                    }
                                    
                                    Button(action: goToConnectEmail) {
                                        HStack(spacing: 5) {
                                            Image("mail-at-sign-01")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("Connect Email")
                                                .font(.appSemiBold(16))
                                                .foregroundColor(.neutralMain700)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gradientBlue, lineWidth: 1)
                                        )
                                        .background(Color.whiteNeutralCardBG)
                                        .innerBorder(
                                            cornerRadius: 8,
                                            color: Color.innerShadow.opacity(0.6)
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                
                                HStack(spacing: 8) {
                                    Button(action: goToAddByVoice) {
                                        HStack(spacing: 5) {
                                            Image("mic-01-2")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("Add by Voice")
                                                .font(.appSemiBold(16))
                                                .foregroundColor(.neutralMain700)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.secondaryPurple300, lineWidth: 1)
                                        )
                                        .background(Color.whiteNeutralCardBG)
                                        .innerBorder(
                                            cornerRadius: 8,
                                            color: Color.innerShadow.opacity(0.6)
                                        )
                                    }
                                    
                                    Button(action: goToManualEntry) {
                                        HStack(spacing: 5) {
                                            Image("keyboard")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("Manual Entry")
                                                .font(.appSemiBold(16))
                                                .foregroundColor(.neutralMain700)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.secondaryPurple600, lineWidth: 1)
                                        )
                                        .background(Color.whiteNeutralCardBG)
                                        .innerBorder(
                                            cornerRadius: 8,
                                            color: Color.innerShadow.opacity(0.6)
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 16)
                        .padding(.top, 0)
                        .padding(.bottom, 12)
                        .background(
                            Color.whiteNeutralCardBG
                                .cornerRadius(16)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neutral300Border, lineWidth: 1)
                                .cornerRadius(16)
                        )
                        Image("box")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 91,height: 80)
                            .padding(.top, 32)
                        
                        Text("No subscriptions yet")
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutralMain700)
                            .multilineTextAlignment(.center)
                            .padding(.top, 24)
                        
                        Text("Add your first subscription to start tracking your recurring payments")
                            .font(.appRegular(16))
                            .foregroundColor(Color.neutral500)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 8)
                        
                    }
                    .frame(height: 411)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    
//                    Text("You are in the free plan")
//                        .font(.appRegular(18))
//                        .foregroundColor(Color.neutralMain700)
//                        .multilineTextAlignment(.center)
//                        .padding(.top, 32)
                    
                    if commonApiVM.userInfoResponse?.planName ?? "" == "" {
                        Text("You are in the free plan")
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutralMain700)
                            .multilineTextAlignment(.center)
                            .padding(.top, 32)
                    } else {
                        Text("You are in the \(commonApiVM.userInfoResponse?.planName ?? "free") plan")
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutralMain700)
                            .multilineTextAlignment(.center)
                            .padding(.top, 32)
                    }
                    
                    if let limit = commonApiVM.userInfoResponse?.planSubscriptionLimit{
                        Text("Added \(commonApiVM.userInfoResponse?.usedSubscriptionCount ?? 0)/\(commonApiVM.userInfoResponse?.planSubscriptionLimit ?? 3) Active Subscriptions")
                            .font(.appRegular(14))
                            .foregroundColor(Color.neutralMain700)
                            .multilineTextAlignment(.leading)
                    }else{
                        Text("Added \(commonApiVM.userInfoResponse?.usedSubscriptionCount ?? 0)/Unlimited Active Subscriptions")
                            .font(.appRegular(14))
                            .foregroundColor(Color.neutralMain700)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Button(action: upgradePlan) {
                        Text("Upgrade Today")
                            .font(.appSemiBold(18))
                            .foregroundColor(Color.secondaryPurple700)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondaryPurple400, lineWidth: 1)
                    )
                    .cornerRadius(8)
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 10) {
                            Image("idea-01")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Pro tip")
                                .font(.appRegular(16))
                                .foregroundColor(.blueMain700)
                        }
                        .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)
                        .padding(.leading, 17)
                        
                        Text("Start with your most expensive subscriptions first. Connect your email to automatically find more.")
                            .font(.appRegular(14))
                            .foregroundColor(.neutralMain700)
                            .padding(.leading, 50)
                            .padding(.trailing,17)
                    }
                    .frame(height: 115)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .background(Color.whiteNeutralCardBG)
                    .cornerRadius(12)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 86)
        .background(Color.neutralBg100)
        .navigationBarBackButtonHidden(true)
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
        Constants.FeatureConfig.performS4Action {
            AppIntentRouter.shared.navigate(to: .notifications)
        }
    }
    private func upgradePlan() {
        Constants.FeatureConfig.performS4Action {
            if Constants.FeatureConfig.featurePhase == .all{
                if currentPlan == 3 {
                    AppIntentRouter.shared.navigate(to: .pricingPlans(selectedTab: .second))
                }else{
                    AppIntentRouter.shared.navigate(to: .pricingPlans())
                }
            }else{
                ToastManager.shared.showToast(message: "Coming soon in S4", style: .info)
            }
        }
    }
    private func goToSmartAssistant() {
        Constants.FeatureConfig.performS5Action {
            AppIntentRouter.shared.navigate(to: .smartAssistantAI)
        }
    }
    private func goToUploadImage() {
        showUploadPopup = true
    }
    private func goToConnectEmail() {
//        Constants.FeatureConfig.performS4Action {
//            AppIntentRouter.shared.navigate(to: .connectEmail)
//        }
        AppIntentRouter.shared.navigate(to: .connectEmail)
    }
    private func goToAddByVoice() {
        AppIntentRouter.shared.navigate(to: .voiceCommandView)
    }
    private func goToManualEntry() {
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
    }
}

#Preview {
    WelcomeHomeView()
}
