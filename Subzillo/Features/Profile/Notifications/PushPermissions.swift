//
//  PushPermissions.swift
//  Subzillo
//
//  Created by Ratna Kavya on 23/05/26.
//

import SwiftUI

struct PushPermissions: View {
    
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            // MARK: Top Skip
            
            HStack {
                Spacer()
                
                Button {
                    skipAction()
                } label: {
                    Text("Not now")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.textPrimary0E101AF4F1FB.opacity(0.6))
                    
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // MARK: Main Content
            
            VStack(spacing: 22) {
                
                // MARK: Bell
                
                ZStack(alignment: .topTrailing) {
                    
                    ZStack {
                        
                        themeManager.accentGradient
                        
                        Image("pushNoti")
                            .frame(width: 40, height: 40)
                    }
                    .frame(width: 84, height: 84)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )
                    .shadow(
                        color: themeManager.selectedAccent.senColor.opacity(0.55),
                        radius: 25,
                        y: 18
                    )
                    .rotationEffect(.degrees(isAnimating ? 6 : -6))
                    .animation(
                        .easeInOut(duration: 0.22)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true
                    }
                    
                    ZStack {
                        Circle()
                            .fill(Color.dangerE43C5CFF5A7A)
                        
                        Circle()
                            .stroke(
                                themeManager.white_black,
                                lineWidth: 3
                            )
                        
                        Text("3")
                            .font(.geistBold(11))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 24, height: 24)
                    .offset(x: 4, y: -4)
                }
                .padding(.top, 8)
                
                // MARK: Title
                
                VStack(spacing: 8) {
                    
                    Text("Never miss a renewal")
                        .font(.geistBold(24))
                        .foregroundStyle(.textPrimary0E101AF4F1FB)
                        .multilineTextAlignment(.center)
                    
                    Text("Subzi pings you 3 days before a sub renews, when prices change, and when we spot savings.")
                        .font(.geistRegular(13))
                        .foregroundStyle(
                            .textPrimary0E101AF4F1FB.opacity(0.6)
                        )
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .frame(maxWidth: 300)
                
                // MARK: Notification Cards
                
                VStack(spacing: 8) {
                    
                    NotificationCard(
                        iconBackground: "#000000",
                        title: "Netflix renews tomorrow",
                        subtitle: "$22.99 · Tap to skip or pause",
                        time: "3d",
                        icon: "limit1"
                    )
                    
                    NotificationCard(
                        iconBackground: "#000000",
                        title: "Weekly spending report",
                        subtitle: "Every Monday morning",
                        time: "12h",
                        icon: "chart1"
                    )
                    .opacity(0.92)
                    
                }
                
                // MARK: Privacy
                
                HStack(spacing: 10) {
                    
                    Image("lockIcon")
                        .frame(width: 15, height: 15)
                    
                    HStack(spacing: 10) {
                        Text("You control which alerts. Change anytime in ")
                            .font(.geistRegular(11))
                            .foregroundStyle(
                                .textPrimary0E101AF4F1FB.opacity(0.6)
                            )
                        
                        Button {
                            gotoSettings()
                        } label: {
                            Text("Settings")
                                .font(.geistSemiBold(11))
                                .foregroundStyle(.textPrimary0E101AF4F1FB)
                        }
                    }
                    
                    .lineSpacing(3)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.white_white4)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            .textPrimary0E101AF4F1FB.opacity(0.08),
                            lineWidth: 1
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            Spacer()
            // MARK: Bottom Buttons
            
            VStack(spacing: 10) {
                
                Button {
                    
                } label: {
                    Text("Turn on notifications")
                        .font(.geistSemiBold(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            themeManager.accentGradient
                        )
                        .clipShape(Capsule())
                        .shadow(
                            color: themeManager.selectedAccent.senColor.opacity(0.55),
                            radius: 10,
                            y: 4
                        )
                }
                
                Button {
                    skipAction()
                } label: {
                    Text("Maybe later")
                        .font(.geistMedium(13))
                        .foregroundStyle(
                            .textPrimary0E101AF4F1FB.opacity(0.6)
                        )
                        .frame(height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 66)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
        .applyAppBackground()
    }
    func skipAction()
    {
        
    }
    func gotoSettings()
    {
        AppIntentRouter.shared.navigate(to: .settings)
    }
}
struct NotificationCard: View {
    
    let iconBackground: String
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    @EnvironmentObject var themeManager         : ThemeManager
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color(hex: iconBackground))
                
                Image(icon)
                    .frame(width: 22, height: 22)
            }
            .frame(width: 34, height: 34)
            
            VStack(alignment: .leading, spacing: 2) {
                
                HStack(alignment: .firstTextBaseline) {
                    
                    Text(title)
                        .font(.geistSemiBold(12))
                        .foregroundStyle(.textPrimary0E101AF4F1FB)
                        .lineLimit(1)
                    
                    Spacer(minLength: 8)
                    
                    Text(time)
                        .font(.jetBrainsRegular(10))
                        .foregroundStyle(
                            .textPrimary0E101AF4F1FB.opacity(0.36)
                        )
                }
                
                Text(subtitle)
                    .font(.geistRegular(11))
                    .foregroundStyle(
                        .textPrimary0E101AF4F1FB.opacity(0.6)
                    )
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(themeManager.white_white4)
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    .textPrimary0E101AF4F1FB.opacity(0.08),
                    lineWidth: 1
                )
        }
        .shadow(
            color: .textPrimary0E101AF4F1FB.opacity(0.06),
            radius: 7,
            y: 4
        )
    }
}
