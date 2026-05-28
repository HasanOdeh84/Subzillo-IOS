//
//  OnboardingSuccess.swift
//  Subzillo
//
//  Created by Ratna Kavya on 18/05/26.
//

import SwiftUI

struct OnboardingSuccess: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            LottieView(name: "onboarding_celebration", loopMode: .loop, isAspectFit: false)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            ScrollView(showsIndicators: false){
                VStack(spacing: 0) {
                    
                    // MARK: - Top Content
                    VStack(spacing: 0) {
                        
                        // MARK: - Success Animation
                        ZStack {
                            
                            // Rings
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .stroke(
                                        themeManager.textPrimaryLight6_white6.opacity(0.50),
                                        lineWidth: 0.8
                                    )
                                    .scaleEffect(1)
                                    .opacity(0.8)
                                    .frame(width: 150, height: 150)
                                    .modifier(
                                        SuccessRingAnimation(delay: Double(index) * 0.4)
                                    )
                            }
                            
                            // Center Circle
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.green58D3B5,
                                                Color.blue4898DF
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 96, height: 96)
                                    .shadow(
                                        color: Color.green58D3B5
                                            .opacity(0.50),
                                        radius: 30,
                                        x: 0,
                                        y: 20
                                    )
                                
//                                Image("checkmark1")
//                                    .frame(width: 52, height: 52)
                            }
                            LottieView(name: "onboarding_tick", loopMode: .playOnce)
                                .frame(width: 50, height: 50)
                                .background(Color.clear)
                        }
                        .padding(.top, 24)
                        
                        // MARK: - Title
                        VStack(spacing: 8) {
                            HStack(spacing: 0) {
                                titleView(title: "You're all set, \(Constants.getUserDefaultsValue(for: Constants.username))", styledPart: "\(Constants.getUserDefaultsValue(for: Constants.username))")
//                                Text("You're all set, ")
//                                    .font(.geistSemiBold(26))
//                                    .foregroundColor(
//                                        Color("TextPrimary_ 0E101A_F4F1FB")
//                                    )
//                                
//                                Text(" \(Constants.getUserDefaultsValue(for: Constants.username))")
//                                    .font(.geistSemiBold(26))
//                                    .italic()
//                                    .overlay(
//                                        themeManager.accentGradient
//                                            .mask(
//                                                Text("\(Constants.getUserDefaultsValue(for: Constants.username)).")
//                                                    .font(.geistSemiBold(26))
//                                            )
//                                    )
//                                    .foregroundColor(.clear)
                                
                            }
                            .multilineTextAlignment(.center)
                            
                            Text("Your account is ready. Here's what Subzi has for you.")
                                .font(.geistRegular(14))
                                .foregroundColor(
                                    Color.textPrimary0E101AF4F1FB.opacity(0.6)
                                )
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                        }
                        .padding(.top, 22)
                        .frame(maxWidth: 320)
                    }
                    
                    // MARK: - Stats Grid
                    VStack(spacing: 10) {
                        
                        HStack(spacing: 10) {
                            
                            statCard(
                                title: "SUBS FOUND",
                                value: "7",
                                subtitle: "Ready to review",
                                icon: "email_purple1",
                                isGradient: false
                            )
                            
                            statCard(
                                title: "TRACKED",
                                value: "$142/mo",
                                subtitle: "Monthly spend",
                                icon: "chart1",
                                isGradient: true
                            )
                        }
                        
                        wideCard()
                    }
                    .padding(.top, 28)
                    
                    // MARK: - Up Next
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("UP NEXT")
                            .font(.jetBrainsMedium(10))
                            .foregroundColor(
                                Color.textPrimary0E101AF4F1FB.opacity(0.6)
                            )
                            .tracking(1.4)
                        
                        VStack(spacing: 8) {
                            
                            nextItem(
                                number: "1",
                                title: "Review your 7 subs",
                                subtitle: "Confirm what Subzi found"
                            )
                            
                            nextItem(
                                number: "2",
                                title: "Meet Subzi AI",
                                subtitle: "Ask anything about your spending"
                            )
                        }
                    }
                    .padding(16)
                    .background(themeManager.white_white4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                themeManager.black_white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: themeManager.black_white.opacity(0.04),
                        radius: 16,
                        x: 0,
                        y: 4
                    )
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // MARK: - Button
                    
                    GradientBgButton(
                        title       : "Take me home",
                        isSolid     : true,
                        showChevron : true
                    ) {
                        AppIntentRouter.shared.navigate(to: .home)
                    }
                    .padding(.top, 20)
                    
    //                Button {
    //                    AppIntentRouter.shared.navigate(to: .home)
    //                } label: {
    //                    HStack(spacing: 8) {
    //                        
    //                        Text("Take me home")
    //                            .font(.geistSemiBold(16))
    //                        
    //                        Image(systemName: "chevron.right")
    //                            .font(.system(size: 14, weight: .bold))
    //                    }
    //                    .foregroundColor(Color("Surface_FFFFFF_0A0612"))
    //                    .frame(maxWidth: .infinity)
    //                    .frame(height: 54)
    //                    .background(
    //                        themeManager.accentGradient
    //                    )
    //                    .clipShape(Capsule())
    //                    .shadow(
    //                        color: themeManager.selectedAccent.primaryColor.opacity(0.45),
    //                        radius: 22,
    //                        x: 0,
    //                        y: 4
    //                    )
    //                }
    //                .padding(.top, 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .applyAppBackground()
    }
    
    // MARK: - Small Card
    @ViewBuilder
    private func statCard(
        title: String,
        value: String,
        subtitle: String,
        icon: String,
        isGradient: Bool
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 6) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isGradient
                        ? AnyShapeStyle(themeManager.accentGradient)
                        : AnyShapeStyle(themeManager.black_white.opacity(0.04))
                    )
                
                Image(icon)
                    .frame(width: 16, height: 16)
            }
            .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(title)
                    .font(.jetBrainsMedium(10))
                    .foregroundColor(
                        Color.textPrimary0E101AF4F1FB.opacity(0.6)
                    )
                    .tracking(1.2)
                
                Text(value)
                    .font(.geistBold(22))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                
                Text(subtitle)
                    .font(.geistRegular(11))
                    .foregroundColor(
                        Color.textPrimary0E101AF4F1FB.opacity(0.6)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background {
            if isGradient {
                themeManager.accentGradient.opacity(0.133)
            } else {
                themeManager.white_white4
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isGradient
                    ? themeManager.selectedAccent.primaryColor.opacity(0.2)
                    : themeManager.black_white.opacity(0.08),
                    lineWidth: 1
                )
        )
        .cornerRadius(16)
        .shadow(
            color: themeManager.black_white.opacity(0.04),
            radius: 16,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Wide Card
    @ViewBuilder
    private func wideCard() -> some View {
        
        HStack(spacing: 12) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 11)
                    .fill(themeManager.black_white.opacity(0.04))
                
                Image("sparkles1")
                    .frame(width: 18, height: 18)
            }
            .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("POTENTIAL SAVINGS")
                    .font(.jetBrainsMedium(10))
                    .foregroundColor(
                        Color.textPrimary0E101AF4F1FB.opacity(0.6)
                    )
                    .tracking(1.2)
                
                Text("$47/mo")
                    .font(.geistBold(20))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                
                Text("Based on plans we think you can downgrade or pause")
                    .font(.geistRegular(11))
                    .foregroundColor(
                        Color.textPrimary0E101AF4F1FB.opacity(0.6)
                    )
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(themeManager.white_white4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    themeManager.black_white.opacity(0.08),
                    lineWidth: 1
                )
        )
        .cornerRadius(16)
        .shadow(
            color: themeManager.black_white.opacity(0.04),
            radius: 16,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Next Item
    @ViewBuilder
    private func nextItem(
        number: String,
        title: String,
        subtitle: String
    ) -> some View {
        
        HStack(spacing: 10) {
            
            ZStack {
                
                Circle()
                    .fill(themeManager.accentGradient)
                
                Text(number)
                    .font(.geistBold(11))
                    .foregroundColor(Color.white)
            }
            .frame(width: 22, height: 22)
            
            VStack(alignment: .leading, spacing: 1) {
                
                Text(title)
                    .font(.geistSemiBold(13))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                
                Text(subtitle)
                    .font(.geistRegular(11))
                    .foregroundColor(
                        Color.textPrimary0E101AF4F1FB.opacity(0.6)
                    )
            }
            
            Spacer()
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
                .font(.geistSemiBold(24))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                .multilineTextAlignment(.center)
        }
    }
    
    private func buildLine(line: String, styledPart: String, isMask: Bool) -> Text {
        let parts = line.components(separatedBy: styledPart)
        var result = Text("")
        for (index, part) in parts.enumerated() {
            result = result + Text(part)
                .font(.geistSemiBold(24))
                .foregroundColor(isMask ? .clear : Color("TextPrimary_ 0E101A_F4F1FB"))
            
            if index < parts.count - 1 {
                result = result + Text(styledPart)
                    .font(.jetBrainsSemiBoldItalic(24))
                    .italic()
                    .foregroundColor(isMask ? .black : .clear)
            }
        }
        return result
    }
}

// MARK: - Ring Animation
struct SuccessRingAnimation: ViewModifier {
    
    let delay: Double
    
    @State private var animate = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(animate ? 1.35 : 0.7)
            .opacity(animate ? 0 : 0.8)
            .animation(
                .easeOut(duration: 2.4)
                .repeatForever(autoreverses: false)
                .delay(delay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}
