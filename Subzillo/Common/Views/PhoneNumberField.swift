//
//  PhoneNumberField.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI

struct Country: Identifiable {
    let id = UUID()
    let code    : String
    let flag    : String
}

struct PhoneNumberField: View {
    @State private var selectedCountry  = Country(code: "+971", flag: "🇦🇪")
    @State private var phoneNumber      = ""
    
    let countries = [
        Country(code: "+971", flag: "🇦🇪"),
        Country(code: "+91", flag: "🇮🇳"),
        Country(code: "+1", flag: "🇺🇸")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter your phone number")
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
            
            HStack(spacing: 0) {
                Menu {
                    ForEach(countries) { country in
                        Button {
                            selectedCountry = country
                        } label: {
                            Text("\(country.flag) \(country.code)")
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedCountry.flag)
                            .frame(width: 24, height: 18)
                        Image(systemName: "chevron.down")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        Text(selectedCountry.code)
                            .font(.appRegular(14))
                            .foregroundColor(.neutral500)
                    }
                    .padding(.horizontal, 10)
                }
                
                Divider()
                    .frame(height: 52)
                    .foregroundColor(.neutral100)
                
                TextField("000 000 000", text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(Color.white)
                    .font(.appRegular(14))
            }
            .frame(height: 52)
            .background(Color.neutralBg100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral200, lineWidth: 1)
            )
        }
    }
}

#Preview {
    PhoneNumberField()
}
