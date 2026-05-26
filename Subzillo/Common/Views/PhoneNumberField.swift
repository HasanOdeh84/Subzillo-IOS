//
//  PhoneNumberField.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI
import SDWebImageSwiftUI
import Combine
import libPhoneNumber

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
    @State var verifyData                   : LoginSignupVerifyData? = nil
    @State var fromSingup                   = false
    @State var fromPreview                  = false
    @State var fromSocailLogin              = false
    @State var fromFamily                   = false
    @State var countryCode                  = ""
    @State var flag                         = ""
    @State private var previousCountry: Country?
    var showTick: Bool = false
    @Environment(\.colorScheme) private var systemScheme
    @EnvironmentObject var themeManager     : ThemeManager
    
    // Inline selection states
    @State private var isExpanded = false
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return commonApiVM.countriesResponse ?? []
        }
        return commonApiVM.countriesResponse?.filter {
            $0.countryCode?.localizedCaseInsensitiveContains(searchText) ?? false ||
            $0.countryName?.localizedCaseInsensitiveContains(searchText) ?? false
        } ?? []
    }
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return commonApiVM.currencyResponse ?? []
        }
        return commonApiVM.currencyResponse?.filter {
            $0.code?.localizedCaseInsensitiveContains(searchText) ?? false ||
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        } ?? []
    }
    
    @StateObject private var formatterService = PhoneNumberFormatterService(regionCode: Constants.shared.regionCode)
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if header != ""{
                Text(LocalizedStringKey(header ?? ""))
                    .font(.appRegular(14))
                    .foregroundColor(Color.textDim60637AA8A4C0)
            }
            
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if isCountry{
                                if selectedCountry?.countryFlag ?? "" == ""{
                                    Text(flag)
                                        .frame(width: 24, height: 24)
                                }else{
                                    AsyncImage(url: URL(string: flag)) { phase in
                                        switch phase {
                                        case .empty:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.5))
                                                .frame(width: 24, height: 24)
                                                .shimmer(true)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 24, height: 24)
                                        case .failure:
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.5))
                                                .frame(width: 24, height: 24)
                                                .shimmer(true)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }else
                            {
                                AsyncImage(url: URL(string: selectedCurrency?.flag ?? "")) { phase in
                                    switch phase {
                                    case .empty:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 24, height: 24)
                                            .shimmer(true)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                    case .failure:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 24, height: 24)
                                            .shimmer(true)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            Image("dropDown_blackWhite")
                                .frame(width: 20, height: 20)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            
                            if isCountry{
                                Text(countryCode)
                                    .font(.appRegular(14))
                                    .foregroundStyle(Color.textPrimary0E101AF4F1FB)
                            }else{
                                Text(selectedCurrency?.code ?? "")
                                    .font(.appRegular(14))
                                    .foregroundStyle(Color.textPrimary0E101AF4F1FB)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Divider()
                        .frame(height: 52)
                        .foregroundColor(.cardBorderE2E8F0E2E8F0)
                    
                    if !isCountry{
                        TextField(LocalizedStringKey(placeholder ?? ""), text: Binding(
                            get: { selectedCurrency?.name ?? "" },
                            set: { newValue in
                                if var currency = selectedCurrency {
                                    currency.name = newValue
                                    selectedCurrency = currency
                                }
                            }
                        ))
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .foregroundStyle(Color.textPrimary0E101AF4F1FB)
                        .font(.geistMedium(14))
                        .disabled(true)
                    }else{
                        PhoneNumberTextField(
                            digits          : $phoneNumber,
                            formatterService: formatterService
                        )
                        .padding(.leading, 16)
                        .padding(.trailing, showTick ? 4 : 16)
                        .frame(height: 52)
                        .foregroundStyle(Color.textPrimary0E101AF4F1FB)
                        .font(.geistMedium(14))
                        .disabled(false)
                        
                        if showTick {
                            Image("tick_green")
                                .frame(width: 13, height: 20)
                                .padding(.trailing, 16)
                        }
                    }
                }
                .frame(height: 56)
                .background(Color.cardBgLoginFFFFFFFFFFFF)
                .cornerRadius(14)
                .overlay(selectionFieldBorderView)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 14)
//                        .stroke(isExpanded ? themeManager.accentGradient : LinearGradient(colors: [Color.cardBorderE2E8F0E2E8F0], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
//                )
                
                if isExpanded {
                    if isCountry {
                        InlineSelectionView(
                            title: "",
                            items: filteredCountries,
                            selectedItem: $selectedCountry,
                            isExpanded: $isExpanded,
                            searchText: $searchText,
                            placeholder: "Search Country...",
                            labelProvider: { $0.countryName ?? "" },
                            flagProvider: { $0.countryFlag ?? "" },
                            detailProvider: nil,
                            secondaryDetailProvider: { $0.dialCode ?? "" },
                            showSelectionField: false
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        InlineSelectionView(
                            title: "",
                            items: filteredCurrencies,
                            selectedItem: $selectedCurrency,
                            isExpanded: $isExpanded,
                            searchText: $searchText,
                            placeholder: "Search Currency...",
                            labelProvider: { $0.name ?? "" },
                            flagProvider: { $0.flag ?? "" },
                            detailProvider: { $0.code ?? "" },
                            secondaryDetailProvider: { $0.symbol ?? "" },
                            showSelectionField: false
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .onAppear(perform:
                        self.updateCountryAndCurrency
            )
            .onChange(of: commonApiVM.countriesResponse) { _ in
                updateCountryAndCurrency()
            }
            .onChange(of: commonApiVM.currencyResponse) { _ in
                updateCountryAndCurrency()
            }
            .onChange(of: selectedCountry) { _ in countryChange() }
        }
//        .sheet(isPresented: $showCurrencySheet) {
//            CountriesBottomSheet(selectedCurrency   : $selectedCurrency,
//                                 selectedCountry    : $selectedCountry,
//                                 isCountry          : isCountry,
//                                 currencyResponse   : commonApiVM.currencyResponse,
//                                 countryResponse    : commonApiVM.countriesResponse,
//                                 header             : isCountry ? "Select your Country" : "Your payment currency",
//                                 placeholder        : isCountry ? "Search" : "Search")
//            .presentationDetents([.large])
//            .presentationDragIndicator(.hidden)
//        }
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
        if selectedCurrency == nil{
            if let currencies = commonApiVM.currencyResponse {
                selectedCurrency = currencies.first(where: { $0.code == Constants.shared.currencyCode })
            }
        }
        if fromSingup && !fromSocailLogin{
            if let countries = commonApiVM.countriesResponse {
                selectedCountry = countries.first(where: { $0.dialCode == verifyData?.countryCode })
            }
        }else{
            if fromFamily{
                if selectedCountry == nil{
                    if let countries = commonApiVM.countriesResponse {
                        selectedCountry = countries.first(where: { $0.countryCode == Constants.shared.regionCode })
                    }
                }else{
                    if let countries = commonApiVM.countriesResponse, !countryCode.isEmpty {
                        selectedCountry = countries.first(where: { $0.dialCode == countryCode })
                    }
                }
            }
            if selectedCountry == nil{
                if let countries = commonApiVM.countriesResponse {
                    selectedCountry = countries.first(where: { $0.countryCode == Constants.shared.regionCode })
                }
            }
        }
        countryCode         = selectedCountry?.dialCode ?? ""
        flag                = selectedCountry?.countryFlag ?? ""
        if isCountry{
            if selectedCountry?.countryFlag ?? "" == "" && selectedCountry?.dialCode ?? "" == ""{
                countryCode = "+\(NBPhoneNumberUtil.sharedInstance().getCountryCode(forRegion: Constants.shared.regionCode))"
                flag        = Constants.shared.flag(from: Constants.shared.regionCode)
            }
        }
        previousCountry = selectedCountry
        formatterService.updateRegion(selectedCountry?.countryCode ?? "")
    }
    
    func countryChange(){
        countryCode         = selectedCountry?.dialCode ?? ""
        flag                = selectedCountry?.countryFlag ?? ""
        if isCountry{
            if selectedCountry?.countryFlag ?? "" == "" && selectedCountry?.dialCode ?? "" == ""{
                countryCode = "+\(NBPhoneNumberUtil.sharedInstance().getCountryCode(forRegion: Constants.shared.regionCode))"
                flag        = Constants.shared.flag(from: Constants.shared.regionCode)
            }
        }
        if !fromSingup{
            if !fromFamily{
                if let prev = previousCountry, prev.dialCode != selectedCountry?.dialCode {
                    phoneNumber = ""
                }
            }
        }
        if fromFamily{
            if let prev = previousCountry, prev.dialCode != selectedCountry?.dialCode {
                phoneNumber = ""
            }
            previousCountry = selectedCountry
        }
        formatterService.updateRegion(selectedCountry?.countryCode ?? "")
    }
    
    @ViewBuilder
    private var selectionFieldBorderView: some View {
        if isExpanded{
            themeManager.selectionFieldBorder
        }else{
            RoundedRectangle(cornerRadius: 14)
                .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
        }
    }
}
