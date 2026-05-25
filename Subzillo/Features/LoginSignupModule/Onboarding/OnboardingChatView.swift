//
//  OnboardingChatView.swift
//  Subzillo
//
//  Created by Antigravity on 24/05/26.
//

import SwiftUI

struct OnboardingChatView: View {
    
    let isActive: Bool
    @State private var showUserBubble           = true
    @State private var showTypingIndicator1     = false
    @State private var showAgentBubble          = true
    @State private var showTypingIndicator2     = true
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) private var systemScheme
    
    var body: some View {
        VStack(spacing: 16) {
            if showUserBubble {
                HStack {
                    Spacer()
                    Text("Should I cancel anything?")
                        .font(.geistMedium(14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 18,
                                bottomLeadingRadius: 18,
                                bottomTrailingRadius: 4,
                                topTrailingRadius: 18
                            )
                            .fill(
                                LinearGradient(
                                    colors: themeManager.currentAccent.colors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                        .shadow(
                            color: themeManager.accentShadowColor.opacity(0.35),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.85, anchor: .bottomTrailing)
                        .combined(with: .opacity)
                        .combined(with: .offset(y: 10)),
                    removal: .opacity
                ))
            }
            
            if showTypingIndicator1 {
                HStack {
                    TypingIndicatorView(dotColor: themeManager.accentTextColor)
                        .padding(.leading, 18)
                        .padding(.vertical, 12)
                        .background(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 18,
                                bottomLeadingRadius: 4,
                                bottomTrailingRadius: 18,
                                topTrailingRadius: 18
                            )
                            .fill(Color.cardBgFFFFFF1A1030)
                        )
                        .overlay(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 18,
                                bottomLeadingRadius: 4,
                                bottomTrailingRadius: 18,
                                topTrailingRadius: 18
                            )
                            .stroke(Color.cardBorderE2E8F0E2E8F0, lineWidth: 1)
                        )
                    Spacer()
                }
                .transition(.opacity)
            }
            
            if showAgentBubble {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        (Text("You haven't used ")
                            .foregroundColor(Color.textPrimary0E101AF4F1FB)
                            .font(.geistRegular(14))
                         + Text("Adobe CC")
                            .foregroundColor(themeManager.accentTextColor)
                         //                            .bold()
                         + Text(" in 62 days. Canceling saves ")
                            .foregroundColor(Color.textPrimary0E101AF4F1FB)
                            .font(.geistRegular(14))
                         + Text("$54.99/mo.")
                            .foregroundColor(Color("Success_0EA870_5CE4A8")))
                        //                            .bold())
                        .font(.geistMedium(14))
                        .lineSpacing(4)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 4,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18
                        )
                        .fill(Color("calender_F1F2F7_FFFFFF"))
                    )
                    .overlay(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 4,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18
                        )
                        .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
                    )
                    .shadow(
                        color: Color.black.opacity(systemScheme == .dark ? 0.25 : 0.04),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    Spacer()
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.85, anchor: .bottomLeading)
                        .combined(with: .opacity)
                        .combined(with: .offset(y: 10)),
                    removal: .opacity
                ))
            }
            
            if showTypingIndicator2 {
                HStack {
                    TypingIndicatorView(dotColor: themeManager.accentTextColor)
                        .padding(.leading, 12)
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 280, alignment: .bottom)
    }
}

struct TypingIndicatorView: View {
    let dotColor: Color
    @State private var animateDots = false
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(dotColor)
                    .opacity(animateDots ? 1.0 : 0.3)
                    .frame(width: 7, height: 7)
                    .offset(y: animateDots ? -5 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.45)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.12),
                        value: animateDots
                    )
            }
        }
        .onAppear {
            animateDots = true
        }
    }
}
