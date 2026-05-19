//
//  GradientBorderButton.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI
struct GradientBorderButton: View {
    var title           : String
    var isBtn           : Bool = false
    var buttonImage     : String?
    var action          : () -> Void
    var backgroundColor : Color = .clear
    var buttonHeight    : CGFloat = 50
    
    var body: some View {
        Button(action: action) {
            Group {
                if isBtn {
                    HStack {
                        Image(buttonImage ?? "")
                            .frame(width: 20, height: 20)
                        Text(LocalizedStringKey(title))
                            .font(.geistBold(15))
                            .foregroundColor(Color.navyBlueCTA700)
                    }
                } else {
                    Text(LocalizedStringKey(title))
                        .font(.geistBold(15))
                        .foregroundColor(Color.navyBlueCTA700)
                }
            }
            .frame(maxWidth: .infinity, minHeight: buttonHeight)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            )
            .cornerRadius(8)
            .contentShape(RoundedRectangle(cornerRadius: 8)) // Ensures whole button is tappable
        }
    }
}

struct SignInBorderButton: View {
    var title           : String
    var buttonImage     : String?
    var buttonHeight    : CGFloat = 52
    var action          : () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    private var isApple: Bool {
        title.contains("Apple")
    }
    
    private var backgroundColor: Color {
        if isApple {
            return colorScheme == .dark ? .white : .black
        } else {
            return colorScheme == .dark ? Color.surfaceLightFFFFFF.opacity(0.2) : .surfaceLightFFFFFF
        }
    }
    
    private var foregroundColor: Color {
        if isApple {
            return colorScheme == .dark ? .black : .white
        } else {
            return Color.textPrimary0E101AF4F1FB
        }
    }
    
    private var borderColor: Color {
        if isApple {
            return .clear
        } else {
            return Color.cardBorderE2E8F0E2E8F0
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(foregroundColor)
                
                HStack {
                    Image(buttonImage ?? "")
                        .renderingMode(isApple ? .template : .original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(foregroundColor)
                        .padding(.leading, 24)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, minHeight: buttonHeight)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isApple ? .clear : borderColor, lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}

struct GradientBgButton: View {
    var title           : String
    var isSolid         : Bool = false
    var showChevron     : Bool = false
    var action          : () -> Void
    var backgroundColor : Color = .clear
    var buttonHeight    : CGFloat = 56
    @EnvironmentObject var themeManager   : ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Spacer()
                
                Text(LocalizedStringKey(title))
                    .font(.geistBold(15))
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                
                Spacer()
            }
            .foregroundColor(isSolid ? .white : Color.navyBlueCTA700)
            .frame(maxWidth: .infinity, minHeight: buttonHeight)
            .background(
                Group {
                    if isSolid {
                        themeManager.accentGradient
                    } else {
                        backgroundColor
                    }
                }
            )
            .overlay(
                Group {
                    if !isSolid {
                        RoundedRectangle(cornerRadius: buttonHeight / 2)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                    }
                }
            )
            .cornerRadius(buttonHeight / 2)
            .shadow(color: isSolid ? themeManager.accentShadowColor : .clear, radius: 10, x: 0, y: 4)
            //            .shadow(
            //                color: isSolid ? Color.brandMidDark7C5CFF.opacity(0.55) : .clear,
            //                radius: 10,
            //                x: 0,
            //                y: 4
            //            )
            .contentShape(RoundedRectangle(cornerRadius: buttonHeight / 2))
        }
    }
}

