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
    var currencyResponse                    : [Currency]?
    var header                              : String?
    var placeholder                         : String?
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return currencyResponse ?? []
        }
        return currencyResponse?.filter {
            $0.code?.localizedCaseInsensitiveContains(searchText) ?? false ||
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        } ?? []
    }
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top, 24)
            
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(24))
                .foregroundColor(.appNeutralMain700)
                .padding(.vertical,24)
            
            HStack {
                Image("search")
                    .frame(width: 20,height: 20)
                    .foregroundColor(.gray)
                    .padding(.leading,16)
                TextField(LocalizedStringKey(placeholder ?? ""), text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.trailing,10)
                    .foregroundColor(.primaryText)
            }
            .frame(height: 52)
            .background(.appBackground)
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
                                .foregroundColor(.appNeutralMain700)
                            Text(currency.name ?? "")
                                .font(.appRegular(16))
                                .foregroundColor(.appNeutralMain700)
                            Spacer()
                        }
                        .frame(height: 40)
                    }
                }
                .listStyle(.plain)
            }
            .background(.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral300Border, lineWidth: 1)
            )
            .padding(24)
        }
        .onAppear {
        }
    }
}

#Preview {
    CountriesBottomSheet(
        selectedCurrency: .constant(nil)
    )
}
