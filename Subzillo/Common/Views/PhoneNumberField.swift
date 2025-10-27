//
//  PhoneNumberField.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI

struct Country: Identifiable {
    let id = UUID()
    let code: String
    let flag: String
}

struct PhoneNumberField: View {
    var selectedCountry                     : Country?
    @State private var phoneNumber          : String = ""
    var header                              : String?
    var placeholder                         : String?
    @State private var showCurrencySheet    = false
    @State private var selectedCurrency     : Currency? = Currency(id: "7603cf97-e39c-48b8-86ec-629429072761", name: "United States Dollarr", symbol: "$", code: "USD")
    
    let countries = [
        Country(code: "+971", flag: "🇦🇪"),
        Country(code: "+91", flag: "🇮🇳"),
        Country(code: "+1", flag: "🇺🇸")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
            
            HStack(spacing: 0) {
                Button {
                    //                    ForEach(countries) { country in
                    //                        Button {
                    //                            selectedCountry = country
                    //                        } label: {
                    //                            Text("\(country.flag) \(country.code)")
                    //                        }
                    //                    }
                    showCurrencySheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedCurrency?.symbol ?? "")
                            .frame(width: 24, height: 18)
                        Image(systemName: "chevron.down")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        Text(selectedCurrency?.code ?? "")
                            .font(.appRegular(14))
                            .foregroundColor(.neutral500)
                    }
                    .padding(.horizontal, 10)
                }
                
                Divider()
                    .frame(height: 52)
                    .foregroundColor(.neutral100)
                
                TextField(LocalizedStringKey(placeholder ?? ""), text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(Color.white)
                    .font(.appRegular(14))
                
//                Text(selectedCurrency?.name ?? "")
//                    .padding(.horizontal, 16)
//                    .frame(height: 52)
//                    .background(Color.white)
//                    .font(.appRegular(14))
            }
            .frame(height: 52)
            .background(Color.neutralBg100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral200, lineWidth: 1)
            )
        }
        .sheet(isPresented: $showCurrencySheet) {
            CountriesBottomSheet(selectedCurrency: $selectedCurrency)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

//#Preview {
//    PhoneNumberField()
//}
