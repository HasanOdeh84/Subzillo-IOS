//
//  GradientBorderButton.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI

//struct GradientBorderButton: View {
//    var title           : String
//    var isSocialBtn     : Bool = false
//    var action          : () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            if isSocialBtn{
//                HStack{
//                    Image("google")
//                        .frame(width: 20,height: 20)
//                    Text(title)
//                        .font(.appSemiBold(18))
//                        .foregroundColor(Color.navyBlueCTA700)
//                }
//            }else{
//                Text(title)
//                    .font(.appSemiBold(18))
//                    .foregroundColor(Color.navyBlueCTA700)
//            }
//        }
//        .background(Color.white)
//        .frame(maxWidth: .infinity, minHeight: 50)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(
//                    LinearGradient(
//                        gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    ),
//                    lineWidth: 2
//                )
//        )
//        .cornerRadius(8)
//    }
//}

struct GradientBorderButton: View {
    var title           : String
    var isSocialBtn     : Bool = false
    var action          : () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if isSocialBtn {
                    HStack {
                        Image("google")
                            .frame(width: 20, height: 20)
                        Text(title)
                            .font(.appSemiBold(18))
                            .foregroundColor(Color.navyBlueCTA700)
                    }
                } else {
                    Text(title)
                        .font(.appSemiBold(18))
                        .foregroundColor(Color.navyBlueCTA700)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.white)
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
