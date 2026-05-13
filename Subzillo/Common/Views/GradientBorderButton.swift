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
                            .font(.appSemiBold(18))
                            .foregroundColor(Color.navyBlueCTA700)
                    }
                } else {
                    Text(LocalizedStringKey(title))
                        .font(.appSemiBold(18))
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
    var backgroundColor : Color = .clear
    var buttonHeight    : CGFloat = 44
    var action          : () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.whiteBlackBGnoPic)
                HStack {
                    Image(buttonImage ?? "")
                        .frame(height: buttonHeight)
                    //                        .resizable()
                    //                        .scaledToFit()
                    //                        .frame(width: 20, height: 20)
                        .padding(.leading, 16)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, minHeight: buttonHeight)
        }
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.continueBtnBorder, lineWidth: 2)
        )
        .cornerRadius(8)
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct GradientBgButton: View {
    var title           : String
    var isSolid         : Bool = false
    var showChevron     : Bool = false
    var action          : () -> Void
    var backgroundColor : Color = .clear
    var buttonHeight    : CGFloat = 56
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Spacer()
                
                Text(LocalizedStringKey(title))
                    .font(.geistBold(18))
                
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
                        LinearGradient(
                            colors: [Color.brandFromDarkA719DD, Color.brandMidDark7C5CFF ,Color.brandToDark4489EB],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
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
            .shadow(
                color: isSolid ? Color.brandMidDark7C5CFF.opacity(0.55) : .clear,
                radius: 10,
                x: 0,
                y: 4
            )
            .contentShape(RoundedRectangle(cornerRadius: buttonHeight / 2))
        }
    }
}
