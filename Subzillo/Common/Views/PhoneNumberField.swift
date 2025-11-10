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
                        if commonApiVM.countryError != nil {
                            commonApiVM.getCountries()
                        } else if commonApiVM.countriesResponse != nil {
                            showCurrencySheet = true
                        }
                    }else{
                        if commonApiVM.currencyError != nil {
                            commonApiVM.getCurrencies()
                        } else if commonApiVM.currencyResponse != nil {
                            showCurrencySheet = true
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        WebImage(url: URL(string: isCountry ? selectedCountry?.countryFlag ?? "" : selectedCurrency?.flag ?? ""))
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .scaledToFit()
                        //                            .frame(width: 24, height: 18)
                            .frame(width: 24, height: 24)
                            .cornerRadius(5)
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
                    //                    .foregroundColor(.neutral_2_500)
                    .foregroundColor(.black)
                    .font(.appRegular(14))
                    .disabled(true)
                }else{
                    TextField(LocalizedStringKey(placeholder ?? ""), text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(.appNeutral900)
                        .foregroundColor(.black)
                        .font(.appRegular(14))
                        .disabled(false)
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
            .onAppear(perform: updateCountryAndCurrency)
            .onChange(of: commonApiVM.countriesResponse) { _ in updateCountryAndCurrency() }
            .onChange(of: commonApiVM.currencyResponse) { _ in updateCountryAndCurrency() }
        }
        .sheet(isPresented: $showCurrencySheet) {
            CountriesBottomSheet(selectedCurrency   : $selectedCurrency,
                                 selectedCountry    : $selectedCountry,
                                 isCountry          : isCountry,
                                 currencyResponse   : commonApiVM.currencyResponse,
                                 countryResponse    : commonApiVM.countriesResponse,
                                 header             : isCountry ? "Select your Country" : "Your payment currency",
                                 placeholder        : isCountry ? "Search country" : "Search currency")
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }
    
    //MARK: - User defined methods
    //MARK: - updateCountryAndCurrency
    func updateCountryAndCurrency() {
        if let countries = commonApiVM.countriesResponse {
            selectedCountry = countries.first(where: { $0.countryCode == Constants.shared.regionCode })
        }
        if let currencies = commonApiVM.currencyResponse {
            selectedCurrency = currencies.first(where: { $0.code == Constants.shared.currencyCode })
        }
    }
}
