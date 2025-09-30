//
//  CustomButton.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 25/09/25.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    var background: Color = .gray
    var textColor: Color = .black
    var width: CGFloat = 160
    var height: CGFloat = 50
    var cornerRadius: CGFloat = 10
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: width, height: height)
                .background(background)
                .foregroundColor(textColor)
                .cornerRadius(cornerRadius)
        }
//        VStack {
//            Spacer()
//            Button(action: action) {
//                Text(title)
//                    .frame(width: width, height: height)
//                    .background(background)
//                    .foregroundColor(textColor)
//                    .cornerRadius(cornerRadius)
//            }
//            Spacer()
//        }
    }
}

#Preview {
//    CustomButton()
}
