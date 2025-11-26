//
//  CustomTextfield.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/09/25.
//

import SwiftUI

//MARK: - CustomTextField
struct CustomTextField: View {
    
    //MARK: - Properties
    var placeholder     : String
    @Binding var text   : String
    var keyboardType    : UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .keyboardType(keyboardType)
    }
}

//MARK: - ReusableTextField
struct ReusableTextField: View {
    
    //MARK: - Properties
    var placeholder     : String
    @Binding var text   : String
    var isEmail         : Bool = false
    var header          : String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(14))
                .foregroundColor(Color.neutralMain700)
            HStack{
                Image("profile")
                TextField(placeholder, text: $text)
                    .keyboardType(isEmail ? .emailAddress : .default)
                    .padding(6)
                    .autocapitalization(.none)
            }
            .padding(16)
            .frame(height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.neutral300Border, lineWidth: 1)
            )
            .background(Color.whiteNeutralCardBG)
            .cornerRadius(12)
        }
    }
}
