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
    var textColor   : Color = .neutralDisabled200
    var width       : CGFloat = 160
    var height      : CGFloat = 56
    var cornerRadius: CGFloat = 8
    let action      : () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, minHeight: height)
        }
        .frame(maxWidth: .infinity, minHeight: height)
        .background(background)
        .cornerRadius(cornerRadius)
    }
}
