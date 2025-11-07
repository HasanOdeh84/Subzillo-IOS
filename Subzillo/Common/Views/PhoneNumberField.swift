//
//  PhoneNumberField.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct PhoneNumberField: View {
    
    //MMARK: - Properties
    @Binding var phoneNumber                : String
    var header                              : String?
    var placeholder                         : String?
    @State private var showCurrencySheet    = false
    @Binding var selectedCurrency           : Currency?
    @Binding var selectedCountry            : Country?
    @EnvironmentObject var commonApiVM      : CommonAPIViewModel
    @State var isCountry                    : Bool
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.appNeutralMain700)
            
            HStack(spacing: 0) {
                Button {
                    if isCountry{
                        if let error = commonApiVM.countryError {
                            commonApiVM.getCountries()
                        } else if let data = commonApiVM.countriesResponse {
                            showCurrencySheet = true
                        }
                    }else{
                        if let error = commonApiVM.currencyError {
                            commonApiVM.getCurrencies()
                        } else if let data = commonApiVM.currencyResponse {
                            showCurrencySheet = true
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        WebImage(url: URL(string: isCountry ? selectedCountry?.countryFlag ?? "" : selectedCurrency?.flag ?? ""))
                            .resizable()
                        //                        .indicator(.activity)
                        //                        .transition(.fade(duration: 0.5))
                            .scaledToFit()
                            .frame(width: 24, height: 18)
                            .cornerRadius(5)
                        
                        //                        Text(isCountry ? selectedCountry?.countryFlag ?? "" : selectedCurrency?.flag ?? "")
                        //                            .frame(width: 24, height: 18)
                        Image(systemName: "chevron.down")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primaryText)
                        Text(isCountry ? selectedCountry?.dialCode ?? "" : selectedCurrency?.code ?? "")
                            .font(.appRegular(14))
                            .foregroundColor(.neutral_2_500)
                    }
                    .padding(.horizontal, 10)
                }
                
                Divider()
                    .frame(height: 52)
                    .foregroundColor(.appNeutral100)
                
                if !isCountry{
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
            CountriesBottomSheet(selectedCurrency   : $selectedCurrency,
                                 selectedCountry    : $selectedCountry,
                                 isCountry          : isCountry,
                                 currencyResponse   : commonApiVM.currencyResponse,
                                 countryResponse    : commonApiVM.countriesResponse,
                                 header             : isCountry ? "Your Country" : "Your payment currency",
                                 placeholder        : isCountry ? "Search country" : "Search currency")
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }
}
