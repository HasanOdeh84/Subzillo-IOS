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
