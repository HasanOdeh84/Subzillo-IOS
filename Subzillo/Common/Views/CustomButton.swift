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
    var textColor   : Color = .neutralDisabled200White
    var width       : CGFloat = 160
    var height      : CGFloat = 56
    var cornerRadius: CGFloat = 8
    var buttonImage : String = ""
    var action      : () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            if buttonImage != "" {
                HStack {
                    Image(buttonImage)
                        .frame(width: 20, height: 20)
                    Text(LocalizedStringKey(title))
                        .multilineTextAlignment(.center)
                        .foregroundColor(textColor)
                        .font(.appSemiBold(18))
                }
                .frame(maxWidth: .infinity, minHeight: height)
            } else {
                Text(LocalizedStringKey(title))
                    .multilineTextAlignment(.center)
                    .foregroundColor(textColor)
                    .font(.appSemiBold(18))
                    .frame(maxWidth: .infinity, minHeight: height)
            }
        }
        .frame(maxWidth: .infinity, minHeight: height)
        .background(background)
        .cornerRadius(cornerRadius)
    }
}

struct CustomBorderButton: View {
    let title       : String
    var background  : Color = .neutralBg100
    var textColor   : Color = .disCardRed
    var height      : CGFloat = 56
    var cornerRadius: CGFloat = 8
    var action      : () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                action()
            }) {
                Text(LocalizedStringKey(title))
                    .multilineTextAlignment(.center)
                    .foregroundColor(textColor)
                    .font(.appSemiBold(18))
                    .frame(maxWidth: .infinity, minHeight: height)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.neutral300Border, lineWidth: 2)
        )
        .frame(maxWidth: .infinity, minHeight: height)
        .background(background)
        .cornerRadius(cornerRadius)
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
                Text(text)
                    .font(.appRegular(16))
                    .foregroundColor(.navyBlueCTA700)
                    .underline()
            }
        }
    }
}
