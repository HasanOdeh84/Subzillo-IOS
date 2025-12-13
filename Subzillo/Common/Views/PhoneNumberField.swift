//
//  PhoneNumberField.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/10/25.
//

import SwiftUI
import SDWebImageSwiftUI
import PhoneNumberKit
import Combine

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
    @State var fromPreview                  = false
    @State var fromSocailLogin              = false
    @State var countryCode                  = ""
    @State var flag                         = ""
    
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
                        if selectedCountry?.countryFlag ?? "" == "" || selectedCurrency?.flag ?? "" == ""{
                            Text(flag)
                                .frame(width: 24, height: 24)
                        }else{
                            WebImage(url: URL(string: isCountry ? flag : selectedCurrency?.flag ?? ""))
                                .resizable()
                                .indicator(.activity)
                                .transition(.fade(duration: 0.5))
                                .scaledToFit()
                            //                            .frame(width: 24, height: 18)
                                .frame(width: 24, height: 24)
                                .cornerRadius(5)
                        }
                        Image("dropDown_blackWhite")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        Text(isCountry ? countryCode : selectedCurrency?.code ?? "")
                            .font(.appRegular(14))
                            .foregroundColor(.neutral2500)
                    }
                    .padding(.horizontal, 20)
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
                    //                    TextField(LocalizedStringKey(placeholder ?? ""), text: $phoneNumber)
                    //                        .keyboardType(.numberPad)
                    //                        .padding(.horizontal, 16)
                    //                        .frame(height: 52)
                    //                        .background(.whiteBlackBG)
                    //                        .foregroundStyle(Color.whiteBlackBGnoPic)
                    //                        .font(.appRegular(14))
                    //                        .disabled(false)
                    //                        .onChange(of: phoneNumber) { newValue in
                    //                            // Allow only digits (0–9)
                    //                            let filtered = newValue.filter { $0.isNumber }
                    //                            if filtered != newValue {
                    //                                phoneNumber = filtered
                    //                            }
                    //                        }
                    PhoneNumberTextFieldView(phoneNumber: $phoneNumber,
                                             region     : selectedCountry?.countryCode ?? "")
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(.whiteBlackBG)
                    .foregroundStyle(Color.whiteBlackBGnoPic)
                    .font(.appRegular(14))
                    .disabled(false)
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
        if !fromPreview{
            selectedCurrency = Currency(id      : nil,
                                        name    : Constants.shared.currencyCode,
                                        symbol  : Constants.shared.currencySymbol,
                                        code    : Constants.shared.currencyCode,
                                        flag    : Constants.shared.flag(from: Constants.shared.regionCode))
            
            if let currencies = commonApiVM.currencyResponse {
                selectedCurrency = currencies.first(where: { $0.code == Constants.shared.currencyCode })
            }
        }
        if fromSingup && !fromSocailLogin{
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
        /* selectedCountry = Country(id: 0, countryName: "", countryCode: "US", dialCode: "", countryFlag: Constants.shared.flag(from: "US"))
         if let countries = commonApiVM.countriesResponse {
         selectedCountry = countries.first(where: { $0.countryCode == "US" })
         }
         phoneNumber = "2015550123"*/
        countryCode         = selectedCountry?.dialCode ?? ""
        flag                = selectedCountry?.countryFlag ?? ""
        if isCountry{
            if selectedCountry?.countryFlag ?? "" == "" && selectedCountry?.dialCode ?? "" == ""{
                countryCode = Constants.shared.regionCode
                flag        = Constants.shared.flag(from: Constants.shared.regionCode)
            }
        }
    }
}

//MARK: - PhoneNumberTextFieldView
struct PhoneNumberTextFieldView: UIViewRepresentable {
    
    @Binding var phoneNumber    : String
    var region                  : String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PhoneNumberTextField {
        let textField = RegionPhoneTextField()//PhoneNumberTextField()
        textField.withExamplePlaceholder = false
        textField.withPrefix = false
        textField.withFlag = false
        textField.selectedRegion = region
        textField.font = UIFont(name: "Roboto-Regular", size: 14)
        
        // Done button only
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.doneTapped)
        )
        
        toolbar.items = [spacer, doneButton]
        textField.inputAccessoryView = toolbar
        
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange(_:)),
            for: .editingChanged
        )
        return textField
    }
    
    func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
        // Keep text updated from SwiftUI (avoid replacing during typing)
        //        print(region)
        let regionPhoneTF = uiView as! RegionPhoneTextField
        
        // 1. Update region dynamically
        if regionPhoneTF.selectedRegion != region {
            regionPhoneTF.selectedRegion = region    // <-- triggers placeholder update
            context.coordinator.updateRegion(region)
        }
        if uiView.text != phoneNumber {
            let formatter = PartialFormatter(defaultRegion: region)
            uiView.text = formatter.formatPartial(phoneNumber)
        }
    }
    
    class Coordinator: NSObject {
        var parent              : PhoneNumberTextFieldView
        private var formatter   : PartialFormatter
        let phoneNumberUtility  = PhoneNumberUtility()
        
        init(_ parent: PhoneNumberTextFieldView) {
            self.parent = parent
            self.formatter = PartialFormatter(
                defaultRegion: parent.region,
                withPrefix: false
            )
        }
        
        @objc func textDidChange(_ textField: UITextField) {
            guard let text = textField.text else { return }
            let digits = text.filter { $0.isNumber }
            let maxDigits = textField.placeholder!.filter { $0.isNumber }.count
            var trimmedText = digits
            if digits.count > maxDigits {
                trimmedText = String(digits.prefix(maxDigits))
            }
            // Format text according to the selected region
            let formatted = formatter.formatPartial(trimmedText)
            // Update the UITextField text directly
            if textField.text != formatted {
                textField.text = formatted
            }
            // Update binding
            //            parent.phoneNumber = formatted
            do {
                let phoneNumber = try phoneNumberUtility.parse(textField.text ?? "")
                //                textField.text = phoneNumberUtility.format(phoneNumber, toType: .national)
                parent.phoneNumber = String(phoneNumber.nationalNumber)
            }
            catch {
                print("Generic parser error")
            }
        }
        
        // Optional: update region dynamically
        func updateRegion(_ region: String) {
            formatter = PartialFormatter(
                defaultRegion: region,
                withPrefix: false
            )
        }
        
        @objc func doneTapped() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

//MARK: - RegionPhoneTextField
class RegionPhoneTextField: PhoneNumberTextField {
    
    private let phoneUtil = PhoneNumberUtility()
    
    var selectedRegion: String = "IN" {
        didSet {
            updatePlaceholder()
        }
    }
    
    override var defaultRegion: String {
        get {
            return selectedRegion
        }
        set {} // exists for backward compatibility
    }
    
    override func updatePlaceholder() {
        if let example = phoneUtil.metadata(for: selectedRegion)?.mobile?.exampleNumber {
            let formatter = PartialFormatter(defaultRegion: selectedRegion)
            // self.placeholder = formatter.formatPartial(example)
            var placeholder = ""
            for char in formatter.formatPartial(example) {
                placeholder += char.isNumber ? "0" : String(char)
            }
            self.placeholder = placeholder
            
        } else {
            self.placeholder = "Enter phone number"
        }
    }
}

