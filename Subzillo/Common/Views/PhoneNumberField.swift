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
    @EnvironmentObject var commonApiVM      : CommonAPIViewModel
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.appNeutralMain700)
            
            HStack(spacing: 0) {
                Button {
                    if let error = commonApiVM.error {
                        commonApiVM.getCurrencies()
                    } else if let data = commonApiVM.currencyResponse {
                        showCurrencySheet = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedCurrency?.symbol ?? "")
                            .frame(width: 24, height: 18)
                        Image(systemName: "chevron.down")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primaryText)
                        Text(selectedCurrency?.code ?? "")
                            .font(.appRegular(14))
                            .foregroundColor(.neutral_2_500)
                    }
                    .padding(.horizontal, 10)
                }
                
                Divider()
                    .frame(height: 52)
                    .foregroundColor(.appNeutral100)
                
                if placeholder == "United States Dollarr"{
                    TextField(LocalizedStringKey(placeholder ?? ""), text: Binding(
                        get: { selectedCurrency?.name ?? "" },
                        set: { selectedCurrency?.name = $0 }
                    ))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(.appNeutral900)
                    .foregroundColor(.neutral_2_500)
                    .font(.appRegular(14))
                    .disabled(true)
                    .doneOnSubmit()
                }else{
                    TextField(LocalizedStringKey(placeholder ?? ""), text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(.appNeutral900)
                        .foregroundColor(.neutral_2_500)
                        .font(.appRegular(14))
                        .disabled(false)
                        .doneOnSubmit()
                        .onChange(of: phoneNumber) { newValue in
                            // Allow only digits (0–9)
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                phoneNumber = filtered
                            }
                        }
                }
            }
            .frame(height: 52)
            .background(.appNeutralBg100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral_2_200, lineWidth: 1)
            )
        }
        .sheet(isPresented: $showCurrencySheet) {
            CountriesBottomSheet(selectedCurrency: $selectedCurrency,currencyResponse: commonApiVM.currencyResponse,header: placeholder == "United States Dollarr" ? "Your payment currency" : "Your Country",placeholder: placeholder == "United States Dollarr" ? "Search currency" : "Search country")
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}
