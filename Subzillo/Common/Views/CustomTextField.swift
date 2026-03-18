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
        TextField(LocalizedStringKey(placeholder), text: $text)
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
    var isDisabled      : Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header = header {
                Text(LocalizedStringKey(header))
                    .font(.appRegular(14))
                    .foregroundColor(Color.neutralMain700)
            }
            HStack{
                Image("profile")
//                TextField(LocalizedStringKey(placeholder), text: $text)
                TextField("", text: $text, prompt: Text(verbatim: placeholder.localized))
                    .keyboardType(isEmail ? .emailAddress : .default)
                    .padding(6)
                    .autocapitalization(.none)
                    .disabled(isDisabled)
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

struct ReusableTextField2: View {
    
    //MARK: - Properties
    var placeholder     : String
    @Binding var text   : String
    var isEmail         : Bool = false
    var header          : LocalizedStringKey?
    var isDisabled      : Bool = false
    var isImage         = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header = header {
                Text(header)
                    .font(.appRegular(14))
                    .foregroundColor(Color.neutralMain700)
            }
            HStack{
                if isImage{
                    Image("profile")
                }
                //                TextField(placeholder, text: $text)
                TextField("", text: $text, prompt: Text(verbatim: placeholder))
                    .keyboardType(isEmail ? .emailAddress : .default)
                    .padding(6)
                    .autocapitalization(.none)
                    .disabled(isDisabled)
            }
            .padding(16)
            .frame(height: 52)
            .background(.whiteNeutralCardBG)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral2200, lineWidth: 1)
            )
        }
    }
}

struct iCloudReusableTextField: View {
    
    //MARK: - Properties
    var placeholder     : String
    @Binding var text   : String
    var isEmail         : Bool = false
    var header          : LocalizedStringKey?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header = header {
                Text(header)
                    .font(.appRegular(14))
                    .foregroundColor(Color.neutralMain700)
            }
            HStack{
                SecureField(LocalizedStringKey(placeholder), text: $text)
                    .keyboardType(.default)
                    .padding(6)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
//                    .font(.appRegular(14))
//                    .foregroundColor(.neutral2500)
            }
            .padding(16)
            .frame(height: 52)
            .background(.whiteNeutralCardBG)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral2200, lineWidth: 1)
            )
        }
    }
}
