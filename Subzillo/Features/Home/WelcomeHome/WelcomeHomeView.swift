//
//  WelcomeHomeView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct WelcomeHomeView: View {
    
    //MARK: - Properties
    @State var showUploadPopup          : Bool = false
    @State private var isUploading      = false
    @EnvironmentObject var commonApiVM  : CommonAPIViewModel
    var currentPlan                     : Int = 0
    @State var fullName                 = ""
    @State private var animateGlow      = false
    @EnvironmentObject var themeManager : ThemeManager
    
    //MARK: - Body
    var body: some View {
        ZStack {
            //            DynamicBackgroundView()
            
            VStack(alignment: .leading,spacing: 0) {
                HeaderViewWithProfile(title: "Welcome, \(fullName)", username: fullName, action: {
                    goToNotifications()
                }, actionProfile: {
                    goToProfile()
                })
                .padding(.top, 60)
                .padding(.bottom, 10)
                .frame(alignment: .leading)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 4) {
                        
                        ZStack {
                            // Background
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            themeManager.accentTextColor.opacity(0.16),
                                            Color("Surface_FFFFFF_0A0612")
                                        ]),
                                        center: .top,
                                        startRadius: 10,
                                        endRadius: 350
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(
                                            Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.14),
                                            lineWidth: 1
                                        )
                                )
                            
                            VStack(spacing: 0) {
                                
                                // Icon Section
                                ZStack {
                                    
                                    // Glow
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: Gradient(colors: [
                                                    themeManager.accentTextColor
                                                        .opacity(0.55),
                                                    .clear
                                                ]),
                                                center: .center,
                                                startRadius: 10,
                                                endRadius: 50
                                            )
                                        )
                                        .frame(width: 92, height: 92)
                                        .blur(radius: 14)
                                        .scaleEffect(animateGlow ? 1.05 : 0.92)
                                        .opacity(animateGlow ? 1 : 0.75)
                                        .animation(
                                            .easeInOut(duration: 4)
                                            .repeatForever(autoreverses: true),
                                            value: animateGlow
                                        )
                                    
                                    // Gradient Icon Box
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            themeManager.accentGradient
                                        )
                                        .frame(width: 64, height: 64)
                                        .shadow(
                                            color: themeManager.accentTextColor
                                                .opacity(0.55),
                                            radius: 15,
                                            y: 8
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color("BGPrimary_ F7F7F9_0A0612").opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    Image("sparkles")
                                        .frame(width: 26, height: 26)
                                }
                                .padding(.bottom, 20)
                                
                                // Small Title
                                Text("LET'S GET STARTED")
                                    .font(.jetBrainsSemiBold(11))
                                    .tracking(2)
                                    .foregroundColor(
                                        themeManager.accentTextColor
                                    )
                                    .padding(.bottom, 10)
                                
                                // Main Title
                                titleView(title: "Your dashboard is ready.", styledPart: "ready")
                                    .padding(.bottom, 8)
                                
                                // Description
                                Text("How would you like to add your subscriptions?")
                                    .font(.geistRegular(13))
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                            .opacity(0.6)
                                    )
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                                    .frame(maxWidth: 240)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 28)
                        }
                        .padding(.top, 8)
                        .onAppear {
                            animateGlow = true
                        }
                        
                        VStack(spacing: 10) {
                            
                            // MARK: - Scan Email Button
                            
                            Button {
                                self.goToConnectEmail()
                            } label: {
                                
                                HStack(spacing: 14) {
                                    
                                    // Icon
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.18))
                                        
                                        Image("EmailBox")
                                            .frame(width: 40, height: 40)
                                    }
                                    .frame(width: 40, height: 40)
                                    
                                    // Text
                                    VStack(alignment: .leading, spacing: 2) {
                                        
                                        Text("Scan my email")
                                            .font(.geistSemiBold(14))
                                            .foregroundColor(.white)
                                        
                                        Text("AI finds all your subs in ~30s")
                                            .font(.geistRegular(12))
                                            .foregroundColor(.white.opacity(0.75))
                                    }
                                    
                                    Spacer(minLength: 0)
                                    
                                    // FASTEST Tag
                                    Text("FASTEST")
                                        .font(.geistMedium(9))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Capsule())
                                    
                                    // Arrow
                                    Image("rightArrow")
                                        .frame(width: 16, height: 16)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 15)
                                .background(
                                    themeManager.accentGradient
                                )
                                .cornerRadius(18)
                                .shadow(
                                    color: themeManager.accentShadowColor,
                                    radius: 3,//12
                                    x: 0,
                                    y: 4//8
                                )
//                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            
                            
                            // MARK: - Apple
                            
                            SubscriptionRowButton(
                                icon: "apple_withoutPadding",
                                title: "Import Apple subscriptions",
                                subtitle: "Pull from your App Store account", action: goToAddEntry
                            )
                            
                            
                            // MARK: - Google
                            
                            //                            SubscriptionRowButton(
                            //                                icon: "",
                            //                                title: "Import Google subscriptions",
                            //                                subtitle: "Pull from your Google Play account", action: goToAddEntry
                            //                            )
                            
                            
                            // MARK: - Manual
                            
                            SubscriptionRowButton(
                                icon: "AddIcon",
                                title: "Add manually",
                                subtitle: "Type it or say it · takes 15s", action: goToManualEntry
                            )
                        }
                        .padding(.top, 16)
                        
                        VStack {
                            
                            Button {
                                AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
                            } label: {
                                
                                Text("I'll do it later →")
                                    .font(
                                        .jetBrainsRegular(12)
                                    )
                                    .foregroundColor(
                                        themeManager.black_white
                                            .opacity(0.6)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                        .padding(.bottom, 50)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 86)
                .padding(.top, 22)
            }
        }
        .applyAppBackground()
        .navigationBarBackButtonHidden(true)
        .onAppear{
            if let fullName = commonApiVM.userInfoResponse?.fullName{
                self.fullName = fullName
            }
        }
        .onChange(of: commonApiVM.userInfoResponse){ _ in getUserDetailsResponse() }
    }
    
    private func getUserDetailsResponse() {
        if let fullName = commonApiVM.userInfoResponse?.fullName{
            self.fullName = fullName
        }
    }
    
    @ViewBuilder
    private func titleView(title: String, styledPart: String) -> some View {
        if !styledPart.isEmpty && title.contains(styledPart) {
            buildLine(line: title, styledPart: styledPart, isMask: false)
                .multilineTextAlignment(.center)
                .overlay(
                    themeManager.gradient(style: .vertical)
                        .mask(
                            buildLine(line: title, styledPart: styledPart, isMask: true)
                                .multilineTextAlignment(.center)
                        )
                )
                .foregroundColor(.clear)
        } else {
            Text(title)
                .font(.geistSemiBold(26))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                .multilineTextAlignment(.center)
        }
    }
    
    private func buildLine(line: String, styledPart: String, isMask: Bool) -> Text {
        let parts = line.components(separatedBy: styledPart)
        var result = Text("")
        for (index, part) in parts.enumerated() {
            result = result + Text(part)
                .font(.geistSemiBold(26))
                .foregroundColor(isMask ? .clear : Color("TextPrimary_ 0E101A_F4F1FB"))
            
            if index < parts.count - 1 {
                    result = result + Text(styledPart)
                        .font(.jetBrainsSemiBoldItalic(26))
                        .italic()
                        .foregroundColor(isMask ? .black : .clear)
            }
        }
        return result
    }
    
    //MARK: - Button actions
    private func goToNotifications() {
        Constants.FeatureConfig.performS4Action {
            AppIntentRouter.shared.navigate(to: .notifications)
        }
    }
    private func goToConnectEmail() {
        AppIntentRouter.shared.navigate(to: .connectEmail)
    }
    private func goToManualEntry() {
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
    }
    private func goToAddEntry() {
        Constants.shared.OpenSubscriptionsInAppStore()
    }
    private func goToProfile() {
        AppIntentRouter.shared.navigate(to: .profileTab)
    }
}

// MARK: - Reusable Row

struct SubscriptionRowButton: View {
    
    let icon            : String
    let title           : String
    let subtitle        : String
    var action          : () -> Void
    @EnvironmentObject var themeManager : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        Button (action: action) {
            
            HStack(spacing: 14) {
                
                // Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.white_white4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                    if icon != "" {
                        Image(icon)
                            .frame(width: 16, height: 16)
                    }
                }
                .frame(width: 40, height: 40)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(title)
                        .font(.geistSemiBold(14))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    
                    Text(subtitle)
                        .font(.geistRegular(12))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                }
                
                Spacer(minLength: 0)
                
                // Arrow
                if colorScheme == .dark
                {
                    Image("rightArrow")
                        .frame(width: 16, height: 16)
                }
                else{
                    Image("rightArrow1")
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(themeManager.white_white4)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.08),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

#Preview {
    WelcomeHomeView()
}
