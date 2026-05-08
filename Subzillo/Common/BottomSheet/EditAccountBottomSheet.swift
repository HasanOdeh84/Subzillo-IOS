//
//  EditAccountBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 05/01/26.
//

import SwiftUI

struct EditAccountBottomSheet: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State var title                            : String? = "Edit Full Name"
    var accountType                             : AccountType = .name
    var buttonIcon                              : String? = "update"
    var buttonTitle                             : String? = "Update"
    @State private var selectedCurrency         : Currency?
    @State var selectedCountry                  : Country?
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @State var name                             : String = ""
    @State var email                            : String = ""
    @State var mobile                           : String = ""
    @State var currency                         : String = ""
    @State var currencySymbol                   : String = ""
    @StateObject private var toastManager       = ToastManager()
    @FocusState private var isInputActive       : Bool
    @FocusState private var dummyFocus          : Bool
    @State private var activeField              : FieldType?
    @State private var showVerifyOtpSheet       = false
    @StateObject var profileVM                  = ProfileViewModel()
    @State private var originalName             : String = ""
    @State private var originalEmail            : String = ""
    @State private var originalMobile           : String = ""
    @State private var originalCountryCode      : String = ""
    @State private var originalCurrency         : String = ""
    let action                                  : (String, String, String, String, Int, String, String) -> Void
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .center) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top,24)
            
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(24))
                .foregroundStyle(.neutralMain700)
                .multilineTextAlignment(.center)
                .padding(.top,24)
                .padding(.bottom,36)
            
            switch accountType {
            case .name:
                ReusableTextField2(placeholder: "Enter your full name", text: $name, header: "Full Name", isImage: false)
            case .email:
                ReusableTextField2(placeholder: "name@example.com", text: $email, header: "Email", isImage: false)
            case .mobile:
                PhoneNumberField(phoneNumber        : $mobile,
                                 header             : "Mobile number",
                                 placeholder        : "000 000 000",
                                 selectedCurrency   : $selectedCurrency,
                                 selectedCountry    : $selectedCountry,
                                 isCountry          : true,
                                 fromFamily         : true,
                                 countryCode        : selectedCountry?.dialCode ?? "")
            case .currency:
                PhoneNumberField(phoneNumber        : .constant(""),
                                 header             : "Your payment currency",
                                 placeholder        : (selectedCurrency?.name ?? "").localized,
                                 selectedCurrency   : $selectedCurrency,
                                 selectedCountry    : $selectedCountry,
                                 isCountry          : false)
            }
            
            GradientBorderButton(title          : buttonTitle ?? "",
                                 isBtn          : true,
                                 buttonImage    : buttonIcon ?? "") {
                
                var noChanges = false
                var noChangeErrorMessage = ""
                
                switch accountType {
                case .name:
                    break
                case .email:
                    if !email.trimmed.isEmpty && email.trimmed == originalEmail.trimmed {
                        noChanges = true
                        noChangeErrorMessage = "Email already exists"
                    }
                case .mobile:
                    if !mobile.trimmed.isEmpty && mobile.trimmed == originalMobile.trimmed && (selectedCountry?.dialCode ?? "") == originalCountryCode {
                        noChanges = true
                        noChangeErrorMessage = "Phone number already exists"
                    }
                case .currency:
                    break
                }
                
                if noChanges {
                    toastManager.showToast(message: noChangeErrorMessage.localized, style: .error)
                    return
                }
                
                let input = UpdateProfileRequest(userId         : Constants.getUserId(),
                                                 type           : accountType.rawValue,
                                                 fullName       : name,
                                                 email          : email,
                                                 phoneNumber    : mobile,
                                                 countryCode    : selectedCountry?.dialCode ?? "",
                                                 currency       : selectedCurrency?.code ?? "",
                                                 currencySymbol : selectedCurrency?.symbol ?? "")
                if let errorMessage = ProfileValidations.shared.editAccountDetails(input: input) {
                    toastManager.showToast(message: errorMessage.localized, style: .error)
                } else {
//                    if accountType.rawValue == 1 || accountType.rawValue == 4{
//                        action(name.trimmed, email.trimmed, mobile.trimmed, selectedCurrency?.code ?? "", accountType.rawValue, selectedCountry?.dialCode ?? "", selectedCurrency?.symbol ?? "")
//                        dismiss()
//                    }else{
//                        profileVM.updateProfile(input: input)
//                    }
                    action(name.trimmed, email.trimmed, mobile.trimmed, selectedCurrency?.code ?? "", accountType.rawValue, selectedCountry?.dialCode ?? "", selectedCurrency?.symbol ?? "")
                    dismiss()
                }
            }
                                 .padding(.vertical,36)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        //MARK: OnAppear
        .onAppear{
            setupData()
        }
        .modifier(ToastModifier(toast: toastManager))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(LocalizedStringKey("Done")) {
                    isInputActive = false
                }
            }
        }
//        .sheet(isPresented: $showVerifyOtpSheet) {
//            VerifyOtpBottomSheet(verifyData: LoginSignupVerifyData(verifyType   : accountType.rawValue == 2 ? 2 : 1,
//                                                                   email        : email,
//                                                                   phoneNumber  : mobile,
//                                                                   countryCode  : selectedCountry?.dialCode ?? ""),
//                                 onDelegate:{
//                dismiss()
//                onDelegate?()
//            })
//            .presentationDetents([.height(550)])
//            .presentationDragIndicator(.hidden)
//        }
//        .onChange(of: profileVM.isUpdate) { value in
//            if value{
//                if self.accountType.rawValue == 2 || self.accountType.rawValue == 3{
//                    showVerifyOtpSheet = true
//                }
//            }
//        }
    }
    
    //MARK: - User defined methods
    func setupData(){
        switch accountType {
        case .name:
            title = "Edit Full Name"
            originalName = name
        case .email:
            title = "Edit Email"
            originalEmail = email
        case .mobile:
            title = "Edit Mobile Number"
            if let countries = commonApiVM.countriesResponse {
                let userCode = commonApiVM.userInfoResponse?.countryCode ?? ""
                selectedCountry = countries.first(where: {
                    let dial = $0.dialCode ?? ""
                    return dial == userCode || dial == "+\(userCode)" || "+\(dial)" == userCode
                })
            }
            originalMobile = mobile
            originalCountryCode = selectedCountry?.dialCode ?? ""
        case .currency:
            title = "Edit Currency"
            originalCurrency = currency
        }
        if currency != ""{
            if let currencies = commonApiVM.currencyResponse {
                selectedCurrency = currencies.first(where: { $0.code == currency})
            }
            if selectedCurrency == nil{
                selectedCurrency = Currency(id      : nil,
                                            name    : "",
                                            symbol  : currencySymbol,
                                            code    : currency,
                                            flag    : "")
            }
        }else{
            selectedCurrency = Currency(id      : nil,
                                        name    : Constants.shared.currencyCode,
                                        symbol  : Constants.shared.currencySymbol,
                                        code    : Constants.shared.currencyCode,
                                        flag    : Constants.shared.flag(from: Constants.shared.regionCode))
            if let data = commonApiVM.currencyResponse {
                selectedCurrency = data.first(where: { $0.code == Constants.shared.currencyCode })
            }else{
                commonApiVM.getCurrencies()
            }
        }
    }
}
