//
//  PhoneNumberField.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI

struct PhoneNumberField: View {
    
    //MMARK: - Properties
    @Binding var phoneNumber                : String
    var header                              : String?
    var placeholder                         : String?
    @State private var showCurrencySheet    = false
    @Binding var selectedCurrency           : Currency?
    var currencyResponse                    : [Currency]?
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
            
            HStack(spacing: 0) {
                Button {
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
                
                if placeholder == "United States Dollarr"{
                    TextField(LocalizedStringKey(placeholder ?? ""), text: Binding(
                        get: { selectedCurrency?.name ?? "" },
                        set: { selectedCurrency?.name = $0 }
                    ))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(Color.white)
                    .font(.appRegular(14))
                    .disabled(true)
                }else{
                    TextField(LocalizedStringKey(placeholder ?? ""), text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(Color.white)
                        .font(.appRegular(14))
                        .disabled(false)
                }
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
            CountriesBottomSheet(selectedCurrency: $selectedCurrency,currencyResponse: currencyResponse,header: placeholder == "United States Dollarr" ? "Your payment currency" : "Your Country",placeholder: placeholder == "United States Dollarr" ? "Search currency" : "Search country")
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}
