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
    @Environment(\.colorScheme) var systemScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if header != "" {
                Text(LocalizedStringKey(header ?? ""))
                    .font(.geistMedium(12))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
            }
            HStack{
                Image("email_login")
                    .frame(width: 16, height: 16)
                //                    .foregroundColor(systemScheme == .light ? .textPrimaryLight0E101A.opacity(0.6) : .surfaceLightFFFFFF)
                //                TextField(LocalizedStringKey(placeholder), text: $text)
                TextField("", text: $text, prompt: Text(verbatim: placeholder.localized))
                    .keyboardType(isEmail ? .emailAddress : .default)
                    .font(.geistMedium(15))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                    .padding(6)
                    .autocapitalization(.none)
                    .disabled(isDisabled)
            }
            .padding(16)
            .frame(height: 56)
//            .background(systemScheme == .light ? Color.surfaceLightFFFFFF : Color.surfaceLightFFFFFF.opacity(0.04))
            .background(Color.cardBgLoginFFFFFFFFFFFF)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.cardBorderE2E8F0E2E8F0, lineWidth: 1)
            )
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
    var isiCloud        = false
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header = header {
                Text(header)
                    .font(.jetBrainsMedium(11))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                    .padding(.bottom, 5)
            }
            HStack{
                if isImage{
                    Image("person_new")
                        .frame(width: 18, height: 18)
                }
                if isiCloud
                {
                    Image("email_login")
                        .frame(width: 18, height: 18)
                }
                //                TextField(placeholder, text: $text)
                TextField("", text: $text, prompt: Text(verbatim: placeholder))
                    .keyboardType(isEmail ? .emailAddress : .default)
                    .padding(6)
                    .autocapitalization(.none)
                    .disabled(isDisabled)
                    .font(.geistRegular(15))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
            }
            .padding(16)
            .frame(height: 52)
            .background(themeManager.white_white4)
            .overlay {
                
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color.textPrimary0E101AF4F1FB
                            .opacity(0.08),
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
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
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header = header {
                Text(header)
                    .font(.jetBrainsMedium(11))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                    .padding(.bottom, 5)
            }
            HStack{
                Image("email_login")
                    .frame(width: 18, height: 18)
                SecureField(LocalizedStringKey(placeholder), text: $text)
                    .keyboardType(.default)
                    .padding(6)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .font(.geistRegular(15))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                //                    .font(.appRegular(14))
                //                    .foregroundColor(.neutral2500)
            }
            .padding(16)
            .frame(height: 52)
            .background(themeManager.white_white4)
            .overlay {
                
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color.textPrimary0E101AF4F1FB
                            .opacity(0.08),
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
        }
    }
}
