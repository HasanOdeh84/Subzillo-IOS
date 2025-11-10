//
//  GradientViews.swift
//  Subzillo
//
//  Created by Ratna Kavya on 05/11/25.
//

import SwiftUI

struct GradientBorderView: View {
    var title           : String
    var subTitle        : String
    var buttonImage     : String?
    var action          : () -> Void
    var titleColor      : Color
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    Image(buttonImage ?? "")
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 18)
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(LocalizedStringKey(title))
                        .font(.appSemiBold(16))
                        .foregroundColor(titleColor)
                    
                    Text(LocalizedStringKey(subTitle))
                        .font(.appRegular(12))
                        .foregroundColor(Color.neutral500)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    Image("arrow-right-01")
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 18)
            }
            .frame(maxWidth: .infinity, minHeight: 82)
            .background(Color.clear)
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


struct GradienCustomeView: View {
    var title           : String
    var subTitle        : String
    var isBtn           : Bool = false
    var action          : () -> Void

    var body: some View {
        Button(action: action) {
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image("howItWorks")
                    }
                }
                .frame(width: 48, height: 48)
                .background(Color.purple501)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.borderColor, lineWidth: 0)
                )
                .cornerRadius(12)
                .padding(.trailing, 16)
                //.padding(.top, -25)
                
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey(title))
                        .font(.appSemiBold(16))
                        .foregroundColor(.white)
                    Text(LocalizedStringKey(subTitle))
                        .font(.appRegular(14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                if isBtn == true {
                    ZStack(alignment: .topTrailing) {
                        Image("whiteArrowIcon")
                            .frame(width: 10, height: 16)
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.linearGradient2, Color.linearGradient1],
                    startPoint: .leading,
                    endPoint: .topTrailing
                )
            )
            .cornerRadius(12)
        }
    }
}
