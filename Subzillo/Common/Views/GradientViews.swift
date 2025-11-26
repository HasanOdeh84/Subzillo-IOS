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
    var nextBtnImage    : String = "arrow-right-01"
    var action          : () -> Void
    var titleColor      : Color
    var minHeight       = 82
    var titleFont       = 16
    var subTitleFont    = 12
    
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
                        .font(.appSemiBold(CGFloat(titleFont)))
                        .foregroundColor(titleColor)
                    
                    Text(LocalizedStringKey(subTitle))
                        .font(.appRegular(CGFloat(subTitleFont)))
                        .foregroundColor(Color.neutral500)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    Image(nextBtnImage)
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 18)
            }
            .frame(maxWidth: .infinity, minHeight: CGFloat(minHeight))
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
    var imageName       : String = "howItWorks"
    
    var body: some View {
        //Button(action: action) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(imageName)
                    }
                }
                .frame(width: 48, height: 48)
                .background(Color.lightPurple)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.border, lineWidth: 0)
                )
                .cornerRadius(12)
                .padding(.trailing, 16)
                
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
   // }
}
