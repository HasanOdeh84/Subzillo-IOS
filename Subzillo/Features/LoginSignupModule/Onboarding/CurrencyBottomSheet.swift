//
//  CurrencyBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct CountriesBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency           : Currency?
    @Binding var selectedCountry            : Country?
    @State var isCountry                    : Bool
    var currencyResponse                    : [Currency]?
    var countryResponse                     : [Country]?
    var header                              : String?
    var placeholder                         : String?
    @State private var searchText           = ""
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return currencyResponse ?? []
        }
        return currencyResponse?.filter {
            $0.code?.localizedCaseInsensitiveContains(searchText) ?? false ||
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        } ?? []
    }
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return countryResponse ?? []
        }
        return countryResponse?.filter {
            $0.countryCode?.localizedCaseInsensitiveContains(searchText) ?? false ||
            $0.countryName?.localizedCaseInsensitiveContains(searchText) ?? false
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
                if isCountry{
                    List(filteredCountries, id: \.self) { country in
                        VStack(spacing: 0){
                            Button {
                                selectedCountry = country
                                dismiss()
                            } label: {
                                    HStack {
                                        WebImage(url: URL(string: country.countryFlag ?? ""))
                                            .resizable()
                                        //                                    .scaledToFit()
                                            .scaledToFill()
                                            .frame(width: 30, height: 30)
                                            .cornerRadius(4)
                                            .clipped()
                                        Text(country.countryCode ?? "")
                                            .font(.appRegular(16))
                                            .foregroundColor(.appNeutralMain700)
                                            .padding(.horizontal, 14)
                                        Text(country.countryName ?? "")
                                            .font(.appRegular(16))
                                            .foregroundColor(.appNeutralMain700)
                                        Spacer()
                                    }
                                    .frame(height: 40)
                            }
                            .buttonStyle(.plain)
                            
                            if country != filteredCountries.last {
                                Rectangle()
                                    .fill(Color.neutralDisabled200)
                                    .frame(height: 1)
                                    .padding(.horizontal, -20)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }else{
                    List(filteredCurrencies, id: \.self) { currency in
                        VStack(spacing: 0){
                            Button {
                                selectedCurrency = currency
                                dismiss()
                            } label: {
                                HStack {
//                                    Text(currency.flag ?? "")
//                                        .font(.system(size: 30))
//                                        .padding(.leading, -12)
                                    WebImage(url: URL(string: currency.flag ?? ""))
                                        .resizable()
                                    //                                    .scaledToFit()
                                        .scaledToFill()
                                        .frame(width: 30, height: 30)
                                        .cornerRadius(4)
                                        .clipped()
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
                            .buttonStyle(.plain)
                            
                            if currency != filteredCurrencies.last {
                                Rectangle()
                                    .fill(Color.neutralDisabled200)
                                    .frame(height: 1)
                                    .padding(.horizontal, -20)
                            }
                            
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
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
        selectedCurrency: .constant(nil), selectedCountry: .constant(nil), isCountry: false
    )
}
