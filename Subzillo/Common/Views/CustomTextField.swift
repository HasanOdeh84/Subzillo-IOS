//
//  CustomTextfield.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .keyboardType(keyboardType)
    }
}

struct ReusableTextField: View {
    var placeholder     : String
    @Binding var text   : String
    var isEmail         : Bool = false
    var header          : String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.appNeutralMain700)
            HStack{
                Image("profile")
                TextField(placeholder, text: $text)
                    .keyboardType(isEmail ? .emailAddress : .default)
                    .padding(6)
                    .autocapitalization(.none)
            }
            .padding(16)
            .frame(height: 52)
            .background(.appBlackWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral_2_200, lineWidth: 1)
            )
        }
    }
}
