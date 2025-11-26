//
//  WelcomeHomeView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct WelcomeHomeView: View {
    
    @State var showUploadPopup                 : Bool = false
    
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
                        
                        HStack {
                            Spacer()
                            ZStack(alignment: .topTrailing) {
                                Button(action: goToNotifications) {
                                    Image("notification-03")
                                        .frame(width: 32, height: 32)
                                }
                                
//                                Text("3")
//                                    .font(.appBold(11))
//                                    .foregroundColor(Color.white)
//                                    .frame(width: 16, height: 16)
//                                    .background(Color.redBadge)
//                                    .cornerRadius(4)
//                                    .offset(x: 0, y: -5)
                            }
                        }
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
                    
                    Text("You are in the free plan")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutralMain700)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                    
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
                    
                    VStack(spacing: 0) {
                        Image("box")
                            .resizable()
                            .scaledToFit()
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
                        
                        Button(action: goToAddSubscriptions) {
                            HStack(spacing: 5) {
                                Image("robotic")
                                    .frame(width: 20, height: 20)
                                Text("Add Subscription by AI Agent")
                                    .font(.appSemiBold(14))
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
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        
                        VStack(spacing: 8) {
                            
                            HStack(spacing: 8) {
                                Button(action: goToUploadImage) {
                                    HStack(spacing: 5) {
                                        Image("image-upload")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Upload Image")
                                            .font(.appSemiBold(14))
                                            .foregroundColor(.neutralMain700)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gradientPurple, lineWidth: 2)
                                    )
                                    .background(Color.whiteNeutralCardBG)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: goToConnectEmail) {
                                    HStack(spacing: 5) {
                                        Image("mail-at-sign-01")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Connect Email")
                                            .font(.appSemiBold(14))
                                            .foregroundColor(.neutralMain700)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gradientBlue, lineWidth: 2)
                                    )
                                    .background(Color.whiteNeutralCardBG)
                                    .cornerRadius(8)
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
                                            .font(.appSemiBold(14))
                                            .foregroundColor(.neutralMain700)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.secondaryPurple300, lineWidth: 2)
                                    )
                                    .background(Color.whiteNeutralCardBG)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: goToManualEntry) {
                                    HStack(spacing: 5) {
                                        Image("keyboard")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Manual Entry")
                                            .font(.appSemiBold(14))
                                            .foregroundColor(.neutralMain700)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.secondaryPurple600, lineWidth: 2)
                                    )
                                    .background(Color.whiteNeutralCardBG)
                                    .cornerRadius(8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                    .frame(height: 411)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .background(Color.whiteNeutralCardBG)
                    .cornerRadius(16)
                    .padding(.top, 24)
                    
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
            UploadImageSheet()
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(630)])
        }
    }
    
    //MARK: - Button actions
    private func goToNotifications() {
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
    }
    private func upgradePlan() {
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
    }
    private func goToAddSubscriptions() {
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
    }
    private func goToUploadImage() {
        //ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
        showUploadPopup = true
    }
    private func goToConnectEmail() {
        ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
    }
    private func goToAddByVoice() {
       // ToastManager.shared.showToast(message: "Coming soon",style:ToastStyle.info)
        AppIntentRouter.shared.navigate(to: .voiceCommandView)
    }
    private func goToManualEntry() {
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
    }
}

#Preview {
    WelcomeHomeView()
}
