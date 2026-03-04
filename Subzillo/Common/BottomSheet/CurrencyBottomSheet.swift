//
//  CurrencyBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct CountriesBottomSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency           : Currency?
    @Binding var selectedCountry            : Country?
    @State var isCountry                    : Bool
    var currencyResponse                    : [Currency]?
    var countryResponse                     : [Country]?
    var header                              : String?
    var placeholder                         : String?
    @State private var searchText           = ""
    @FocusState private var isSearchFocused : Bool
    var action                              : () -> Void = {}
    
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
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top, 24)
            
            Text(LocalizedStringKey(header ?? ""))
                .font(.appRegular(24))
                .foregroundColor(Color.neutralMain700)
                .padding(.vertical,24)
            
            HStack {
                Image("search")
                    .frame(width: 20,height: 20)
                    .foregroundColor(.gray)
                    .padding(.leading,16)
                TextField(LocalizedStringKey(placeholder ?? ""), text: $searchText)
                    .padding(.trailing,10)
                    .foregroundStyle(Color.whiteBlackBGnoPic)
                    .addDoneButton{
                        
                    }
            }
            .frame(height: 52)
            .background(.neutralBg100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue500, lineWidth: 1)
            )
            .padding(.horizontal,24)
            
            if isCountry{
                if filteredCountries.count != 0{
                    VStack(spacing: 0){
                        List(filteredCountries, id: \.self) { country in
                            VStack(spacing: 0) { // no unwanted spacing
                                Button {
                                    selectedCountry = country
                                    dismiss()
                                } label: {
                                    HStack {
                                        WebImage(url: URL(string: country.countryFlag ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 30, height: 30)
                                            .cornerRadius(4)
                                            .clipped()
                                            .padding(.leading,16)
                                        Text(country.dialCode ?? "")
                                            .font(.appRegular(16))
                                            .foregroundColor(.neutralMain700)
                                            .padding(.horizontal, 14)
                                        Text(LocalizedStringKey(country.countryName ?? ""))
                                            .font(.appRegular(16))
                                            .foregroundColor(.neutralMain700)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain) // remove SwiftUI’s default button padding
                                
                                if country != filteredCountries.last {
                                    Rectangle()
                                        .fill(Color.neutralDisabled200)
                                        .frame(height: 1)
                                        .padding(.horizontal, -20)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // remove default list padding
                            .listRowSeparator(.hidden)
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
                }else{
                    Text("No data found")
                        .padding(30)
                        .foregroundStyle(Color.gray)
                        .font(.appRegular(16))
                    Spacer()
                }
            }else{
                if filteredCurrencies.count != 0{
                    VStack(spacing: 0){
                        List(filteredCurrencies, id: \.self) { currency in
                            VStack(spacing: 0) {
                                Button {
                                    isCurrencyUpdateGlobalManual = false
                                    isCurrencyUpdateGlobal = false
                                    selectedCurrency = currency
                                    action()
                                    dismiss()
                                } label: {
                                    HStack {
                                        WebImage(url: URL(string: currency.flag ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 30, height: 30)
                                            .cornerRadius(4)
                                            .clipped()
                                            .padding(.leading,16)
                                        Text(currency.code ?? "")
                                            .font(.appRegular(16))
                                            .foregroundColor(.neutralMain700)
                                            .padding(.horizontal, 14)
                                        Text(LocalizedStringKey(currency.name ?? ""))
                                            .font(.appRegular(16))
                                            .foregroundColor(.neutralMain700)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .contentShape(Rectangle())
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
                    .background(.clear)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .padding(24)
                }else{
                    Text("No data found")
                        .padding(30)
                        .foregroundStyle(Color.gray)
                        .font(.appRegular(16))
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    CountriesBottomSheet(
        selectedCurrency: .constant(nil), selectedCountry: .constant(nil), isCountry: false
    )
}
