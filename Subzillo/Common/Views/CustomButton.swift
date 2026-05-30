//
//  CustomButton.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 25/09/25.
//

import SwiftUI

struct CustomButton: View {

    let title       : String
    var background  : Color = .navyBlueCTA700
    var shadow      : Color = .navyBlueCTA700
    var textColor   : Color = .white
    var width       : CGFloat = 160
    var height      : CGFloat = 56
    var cornerRadius: CGFloat = 8
    var buttonImage : String = ""
    var isShare     : Bool = false
    var isHidden    : Bool = false
    var isBgGradient: Bool = false
    var action      : () -> Void = {}
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Group {
                if buttonImage != "" {
                    HStack(spacing: 8) {
                        Image(buttonImage)
                            .frame(width: 20, height: 20)

                        Text(LocalizedStringKey(title))
                            .multilineTextAlignment(.center)
                            .foregroundColor(textColor)
                            .font(.appSemiBold(18))
                    }
                } else {
                    Text(LocalizedStringKey(title))
                        .multilineTextAlignment(.center)
                        .foregroundColor(textColor)
                        .font(.appSemiBold(18))
                }
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .background {
                /*
                 if isShare {
                    LinearGradient(
                        colors: [
                            Color.linearGradient3,
                            Color.linearGradient4,
                            Color.blueMain700
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                else if isHidden == true
                {
                    background
                }
                else {
                    themeManager.accentGradient
                }
                 */
                if isBgGradient{
                    themeManager.accentGradient
                }else{
                    background
                }
            }
            .cornerRadius(height/2)
            .contentShape(RoundedRectangle(cornerRadius: height / 2))
            .shadow(color: isBgGradient ? themeManager.accentShadowColor : shadow, radius: 15, x: 0, y: 10)
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}

struct CustomBorderButton: View {
    let title       : String
    var background  : Color = .neutralBg100
    var borderColor : Color = .neutralBg100
    var textColor   : Color = .textPrimary0E101AF4F1FB
    var font        : Font = .geistBold(15)
    var height      : CGFloat = 48
    var cornerRadius: CGFloat = 8
    var showIcon    : Bool = false
    var icon        : String = ""
    var iconOnLeft  : Bool = false
    var isBgGradient: Bool = false
    var action      : () -> Void = {}
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 8) {
                Spacer()
                
                if showIcon && iconOnLeft {
                    Image(icon)
                        .frame(width: 16, height: 16)
                }
                
                Text(LocalizedStringKey(title))
                    .multilineTextAlignment(.center)
                    .foregroundColor(textColor)
                    .font(font)
                
                if showIcon && !iconOnLeft {
                    Image(icon)
                        .frame(width: 16, height: 16)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                isBgGradient ? themeManager.accentGradient : LinearGradient(colors: [background], startPoint: .leading, endPoint: .trailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(height / 2)
            .contentShape(RoundedRectangle(cornerRadius: height / 2))
        }
        .buttonStyle(InteractiveButtonStyle())
    }
}

struct underlineText: View{
    var text        : String
    var image       : String
    let action      : () -> Void
    
    var body: some View{
        HStack{
            Image(image)
            Button(action: action){
                Text(LocalizedStringKey(text))
                    .font(.appRegular(16))
                    .foregroundColor(.navyBlueCTA700)
                    .underline()
            }
        }
    }
}
