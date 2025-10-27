//
//  CurrencyBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//

import SwiftUI

struct CountriesBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency           : Currency?
    @State private var searchText           = ""
    @StateObject private var commonApiVM    = CommonAPIViewModel()
    
//    // Example dynamic data
//    @State private var currencies: [Currency1] = [
//        Currency1(flag: "🇦🇪", code: "AED", name: "United Arab Emirates Dirham"),
//        Currency1(flag: "🇺🇸", code: "USD", name: "United States dollar"),
//        Currency1(flag: "🇮🇳", code: "INR", name: "Indian Rupee"),
//        Currency1(flag: "🇪🇺", code: "EUR", name: "Euro"),
//        Currency1(flag: "🇬🇧", code: "GBP", name: "British Pound"),
//        Currency1(flag: "🇯🇵", code: "JPY", name: "Japanese Yen")
//    ]
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty { return commonApiVM.currencyResponse ?? [] }
        return commonApiVM.currencyResponse?.filter {
            $0.code?.localizedCaseInsensitiveContains(searchText) ?? false ||
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        } ?? []
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Capsule()
                    .fill(Color.grayCapsule)
                    .frame(width: 150, height: 5)
                    .padding(.top, 24)
                
                Text("Your payment currency")
                    .font(.appRegular(24))
                    .foregroundColor(.neutralMain700)
                    .padding(.vertical,24)
                
                HStack {
                    Image("search")
                        .frame(width: 20,height: 20)
                        .foregroundColor(.gray)
                        .padding(.leading,16)
                    TextField("Search currency", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.trailing,10)
                }
                .frame(height: 52)
                .background(Color(.white))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue500, lineWidth: 1)
                )
                .padding(.horizontal,24)
                
                VStack(spacing: 0) {
                    List(filteredCurrencies, id: \.self) { currency in
                        Button {
                            selectedCurrency = currency
                            dismiss()
                        } label: {
                            HStack {
                                Text(currency.symbol ?? "")
                                    .font(.system(size: 30))
                                    .padding(.leading, -12)
                                Text(currency.code ?? "")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutralMain700)
                                Text(currency.name ?? "")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutralMain700)
                                Spacer()
                            }
                            .frame(height: 40)
                        }
                    }
                    .listStyle(.plain)
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neutralDisabled200, lineWidth: 1)
                )
                .padding(24)
            }
            .onAppear {
                if commonApiVM.$currencyResponse == nil{
                    commonApiVM.getCurrencies()
                }
            }
        }
    }
}

#Preview {
    CountriesBottomSheet(
        selectedCurrency: .constant(nil)
    )
}
