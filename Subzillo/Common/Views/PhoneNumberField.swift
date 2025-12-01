//
//  PhoneNumberField.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct PhoneNumberField: View {
    
    //MARK: - Properties
    @Binding var phoneNumber                : String
    var header                              : String?
    var placeholder                         : String?
    @State private var showCurrencySheet    = false
    @Binding var selectedCurrency           : Currency?
    @Binding var selectedCountry            : Country?
    @EnvironmentObject var commonApiVM      : CommonAPIViewModel
    @State var isCountry                    : Bool
    @State var verifyData                   : LoginSignupVerifyData?
    @State var fromSingup                   = false
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(14))
                .foregroundColor(Color.neutralMain700)
            
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
                        Image("dropDown_blackWhite")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        Text(isCountry ? selectedCountry?.dialCode ?? "" : selectedCurrency?.code ?? "")
                            .font(.appRegular(14))
                            .foregroundColor(.neutral2500)
                    }
                    .padding(.horizontal, 10)
                }
                
                Divider()
                    .frame(height: 52)
                    .foregroundColor(.neutral100)
                
                if !isCountry{
                    TextField(LocalizedStringKey(placeholder ?? ""), text: Binding(
                        get: { selectedCurrency?.name ?? "" },
                        set: { selectedCurrency?.name = $0 }
                    ))
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(.whiteBlackBG)
                    //                    .foregroundColor(.neutral_2_500)
                    .foregroundStyle(Color.whiteBlackBGnoPic)
                    .font(.appRegular(14))
                    .disabled(true)
                }else{
                    TextField(LocalizedStringKey(placeholder ?? ""), text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(.whiteBlackBG)
                        .foregroundStyle(Color.whiteBlackBGnoPic)
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
            .background(.neutralBg100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral2200, lineWidth: 1)
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
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showCurrencySheet = false
        }
    }
    
    //MARK: - User defined methods
    //MARK: - updateCountryAndCurrency
    func updateCountryAndCurrency() {
        if let data = SessionManager.shared.loginData {
            verifyData = data
        }
        selectedCurrency = Currency(id      : nil,
                                    name    : Constants.shared.currencyCode,
                                    symbol  : Constants.shared.currencySymbol,
                                    code    : Constants.shared.currencyCode,
                                    flag    : Constants.shared.flag(from: Constants.shared.regionCode))
        if fromSingup{
            selectedCountry = Country(id: 0, countryName: "", countryCode: verifyData?.countryCode, dialCode: "", countryFlag: Constants.shared.flag(from: verifyData?.countryCode ?? ""))
            if let countries = commonApiVM.countriesResponse {
                selectedCountry = countries.first(where: { $0.dialCode == verifyData?.countryCode })
            }
        }else{
            selectedCountry = Country(id: 0, countryName: "", countryCode: Constants.shared.regionCode, dialCode: "", countryFlag: Constants.shared.flag(from: Constants.shared.regionCode))
            if let countries = commonApiVM.countriesResponse {
                selectedCountry = countries.first(where: { $0.countryCode == Constants.shared.regionCode })
            }
        }
        if let currencies = commonApiVM.currencyResponse {
            selectedCurrency = currencies.first(where: { $0.code == Constants.shared.currencyCode })
        }
    }
}
