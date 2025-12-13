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
            Group {
                HStack {
                    Image(buttonImage ?? "")
                        .frame(height: buttonHeight)
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.whiteBlackBGnoPic)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: buttonHeight)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    Color.continueBtnBorder,
                    lineWidth: 2
                )
        )
        .cornerRadius(8)
        .contentShape(RoundedRectangle(cornerRadius: 8)) // Ensures whole button is tappable
    }
}

