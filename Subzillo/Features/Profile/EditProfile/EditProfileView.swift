//
//  EditProfileView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 26/05/26.
//

import SwiftUI
import SDWebImageSwiftUI


struct EditProfileDraft {
    var email            = ""
    var phoneNumber      = ""
    var countryCode      : Country?
    var selectedCurrency : Currency?
    var fullName         = ""
    var subscriptions    : Int? = nil
    var spending         : Int? = nil
    var typeVerify       = 1
}

struct EditProfileView: View {
    
    
    
    // MARK: - Properties
    @StateObject var profileVM          = ProfileViewModel()
    @EnvironmentObject var commonApiVM  : CommonAPIViewModel
    @EnvironmentObject var themeManager : ThemeManager
    @Environment(\.colorScheme) private var systemScheme
    @EnvironmentObject var router       : AppIntentRouter
    
    // Form fields
    @State private var fullName                 = ""
    @State private var email                    = ""
    @State private var phoneNumber              = ""
    @State private var selectedCountry          : Country?
    @State private var selectedCurrency         : Currency?
    @State private var selectedSubscriptions    : Int? = nil
    @State private var selectedSpending         : Int? = nil
    
    enum Field: Hashable {
        case name, email
    }
    @FocusState private var focusedField: Field?
    
    @State private var originalEmail            = ""
    @State private var originalPhoneNumber      = ""
    @State private var originalCountryCode      = ""
    @State private var originalFullName         = ""
    @State private var originalSubscriptions    : Int? = nil
    @State private var originalSpending         : Int? = nil
    @State private var originalCurrencyCode     = ""
    @State private var accountTypeVerify        = 1
    
    // UI state
    @State private var isCountryExpanded    = false
    @State private var isCurrencyExpanded   = false
    @State private var countrySearchText    = ""
    @State private var currencySearchText   = ""
    @State private var showUploadPopup      = false
    @State private var isUploading          = false
    @State private var imageLoadFailed      = false
    
    private let subscriptionOptions         = ["<5", "6-15", "16-30", "30+"]
    private let spendingOptions             = ["$50-$100", "$100-$200", "$200+"]
    
    @State private var didLoad = false
    
    // Computed states
    private var isEmailChanged: Bool {
        return email != originalEmail
    }
    
    private var isPhoneChanged: Bool {
        return phoneNumber != originalPhoneNumber || (selectedCountry?.dialCode ?? "") != originalCountryCode
    }
    
    private var hasChanges: Bool {
        return fullName != originalFullName ||
        isEmailChanged ||
        isPhoneChanged ||
        selectedSubscriptions != originalSubscriptions ||
        selectedSpending != originalSpending ||
        (selectedCurrency?.code ?? "") != originalCurrencyCode
    }
    
    var filteredCountries: [Country] {
        if countrySearchText.isEmpty {
            return commonApiVM.countriesResponse ?? []
        }
        return commonApiVM.countriesResponse?.filter {
            $0.countryCode?.localizedCaseInsensitiveContains(countrySearchText) ?? false ||
            $0.countryName?.localizedCaseInsensitiveContains(countrySearchText) ?? false
        } ?? []
    }
    
    var filteredCurrencies: [Currency] {
        if currencySearchText.isEmpty {
            return commonApiVM.currencyResponse ?? []
        }
        return commonApiVM.currencyResponse?.filter {
            $0.code?.localizedCaseInsensitiveContains(currencySearchText) ?? false ||
            $0.name?.localizedCaseInsensitiveContains(currencySearchText) ?? false
        } ?? []
    }
    
    // MARK: - Body
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        profileImageView
                            .padding(.top, 24)
                        
                        VStack(spacing: 16) {
                            // Full Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("FULL NAME")
                                    .font(.jetBrainsBold(11))
                                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                    .tracking(1.2)
                                
                                TextField("", text: $fullName, prompt: Text("Enter your full name").foregroundColor(themeManager.textPrimaryLight6_dark62))
                                    .focused($focusedField, equals: .name)
                                    .font(.geistMedium(14))
                                    .foregroundColor(.textPrimary0E101AF4F1FB)
                                    .padding(.horizontal, 16)
                                    .frame(height: 50)
                                    .background(themeManager.white_white4)
                                    .cornerRadius(14)
                                    .overlay(
                                        selectionBorder(isFocused: focusedField == .name)
                                    )
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("EMAIL")
                                        .font(.jetBrainsBold(11))
                                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                        .tracking(1.2)
                                    Spacer()
                                    if isEmailChanged {
                                        Button(action: {
                                            verifyEmail()
                                        }) {
                                            Text("VERIFY")
                                                .font(.jetBrainsBold(12))
                                                .foregroundStyle(themeManager.accentGradient)
                                                .tracking(1.2)
                                        }
                                    } else if !email.isEmpty {
                                        Text("Verified")
                                            .font(.jetBrainsBold(10))
                                            .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                            .tracking(1.2)
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    TextField("", text: $email, prompt: Text(verbatim: "name@example.com").foregroundColor(themeManager.textPrimaryLight6_dark62))
                                        .focused($focusedField, equals: .email)
                                        .font(.geistMedium(14))
                                        .foregroundColor(.textPrimary0E101AF4F1FB)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                    
                                    if !isEmailChanged && !email.isEmpty {
                                        Image("tick_green")
                                            .frame(width: 13, height: 20)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .background(themeManager.white_white4)
                                .cornerRadius(14)
                                .overlay(
                                    selectionBorder(isFocused: focusedField == .email)
                                )
                            }
                            
                            // Phone Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("PHONE")
                                        .font(.jetBrainsBold(11))
                                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                        .tracking(1.2)
                                    Spacer()
                                    if isPhoneChanged {
                                        Button(action: {
                                            verifyPhone()
                                        }) {
                                            Text("VERIFY")
                                                .font(.jetBrainsBold(12))
                                                .foregroundStyle(themeManager.accentGradient)
                                                .tracking(1.2)
                                        }
                                    } else if !phoneNumber.isEmpty {
                                        Text("Verified")
                                            .font(.jetBrainsBold(10))
                                            .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                            .tracking(1.2)
                                    }
                                }
                                
                                PhoneNumberField(phoneNumber: $phoneNumber,
                                                 header: "",
                                                 placeholder: "00 000 0000",
                                                 selectedCurrency: $selectedCurrency,
                                                 selectedCountry: $selectedCountry,
                                                 isCountry: true,
                                                 fromSingup: true,
                                                 fromSocailLogin: false,
                                                 showTick: !isPhoneChanged && !phoneNumber.isEmpty)
                                .addDoneButton{}
                            }
                            
                            // Subscriptions
                            VStack(alignment: .leading, spacing: 14) {
                                Text("HOW MANY SUBS?")
                                    .font(.jetBrainsBold(11))
                                    .tracking(1.2)
                                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                    .padding(.horizontal, 4)
                                
                                WrapButtonsView(options: subscriptionOptions,
                                                selectedIndex: $selectedSubscriptions)
                            }
                            
                            // Spendings
                            VStack(alignment: .leading, spacing: 14) {
                                Text("HOW MUCH YOU SPEND ON SUBSCRIPTION MONTHLY?")
                                    .font(.jetBrainsBold(11))
                                    .tracking(1.2)
                                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                    .padding(.horizontal, 4)
                                
                                WrapButtonsView(options: spendingOptions,
                                                selectedIndex: $selectedSpending)
                            }
                            
                            // Currency
                            InlineSelectionView(
                                title                   : "YOUR CURRENCY",
                                font                    : .jetBrainsBold(11),
                                items                   : filteredCurrencies,
                                selectedItem            : $selectedCurrency,
                                isExpanded              : $isCurrencyExpanded,
                                searchText              : $currencySearchText,
                                placeholder             : "Search Currency...",
                                labelProvider           : { $0.name ?? "" },
                                flagProvider            : { $0.flag ?? "" },
                                detailProvider          : { $0.code ?? "" },
                                secondaryDetailProvider : { $0.symbol ?? "" }
                            )
                            .id("currencySelection")
                            .onChange(of: isCurrencyExpanded) { expanded in
                                if expanded {
                                    withAnimation { isCountryExpanded = false }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            proxy.scrollTo("currencySelection", anchor: .bottom)
                                        }
                                    }
                                }
                            }
                            
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .keyboardAdaptive()
            .applyAppBackground()
            .onAppear {
                
                //                if !profileVM.hasLoadedInitialData {
                getUserDetailsApi()
                //                    loadProfileData()
                profileVM.hasLoadedInitialData = true
                if commonApiVM.currencyResponse == nil {
                    commonApiVM.getCurrencies()
                }
                if commonApiVM.countriesResponse == nil {
                    commonApiVM.getCountries()
                }
                //                }
            }
            .onChange(of: commonApiVM.userInfoResponse) { _ in
                loadProfileData()
            }
            .onChange(of: profileVM.isUpdate) { value in
                if value {
                    if accountTypeVerify == 2 || accountTypeVerify == 3 {
                        
                        commonApiVM.editProfileDraft = EditProfileDraft(
                            email: email,
                            phoneNumber: phoneNumber,
                            countryCode: selectedCountry,
                            selectedCurrency: selectedCurrency,
                            fullName: fullName,
                            subscriptions: selectedSubscriptions,
                            spending: selectedSpending,
                            typeVerify: accountTypeVerify
                        )
                        
                        router.navigate(to: .verifyOtp(fromLogin: false, isEditProfile: true, editEmail: email, editPhone: phoneNumber, editCountryCode: selectedCountry?.dialCode ?? "", editVerifyType: accountTypeVerify == 2 ? 2 : 1))
                    } else {
                        router.pop()
                    }
                    commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
                    profileVM.isUpdate = false
                }
            }
            .sheet(isPresented: $showUploadPopup) {
                UploadImageSheet(isUploading: $isUploading, fromProfile: true, onDelegate: {
                    commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
                })
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(430)])
                .interactiveDismissDisabled(isUploading)
            }
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            CircleBackButton(action: {
                router.pop()
            })
            
            Spacer()
            
            Text("Edit profile")
                .font(.geistSemiBold(16))
                .foregroundColor(.textPrimary0E101AF4F1FB)
            
            Spacer()
            
            Button(action: {
                if hasChanges {
                    saveProfile()
                }
            }) {
                Text("Save")
                    .font(.geistBold(12))
                    .foregroundColor(hasChanges ? .white : themeManager.textPrimaryLight6_dark62)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if hasChanges {
                                AnyView(themeManager.accentGradient)
                            } else {
                                AnyView(Color("calender_F1F2F7_FFFFFF"))
                            }
                        }
                    )
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var profileImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.accentGradient)
                .frame(height: 140)
            
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let profileUrl = commonApiVM.userInfoResponse?.profileImage, !profileUrl.isEmpty, !imageLoadFailed {
                        WebImage(url: URL(string: profileUrl))
                            .onFailure { _ in imageLoadFailed = true }
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Color.clear
                            Text(getInitials(name: fullName))
                                .font(.geistBold(36))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                
                Button(action: {
                    showUploadPopup = true
                }) {
                    Image("camera_new")
                        .resizable()
                    //                        .renderingMode(.template)
                    //                        .foregroundColor(.gray)
                        .frame(width: 12, height: 12)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(systemScheme == .light ? Color("BGPrimary_Light_F7F7F9") : Color("Surface_Dark_0A0612"), lineWidth: 3))
                }
                .offset(x: 3, y: 3)
            }
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func selectionBorder(isFocused: Bool) -> some View {
        if isFocused {
            themeManager.selectionFieldBorder
        } else {
            RoundedRectangle(cornerRadius: 14)
                .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1.5)
        }
    }
    
    // MARK: - Methods
    func getUserDetailsApi(){
        commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
    }
    
    private func loadProfileData() {
        guard let info = commonApiVM.userInfoResponse else { return }
        fullName = info.fullName ?? ""
        email = info.email ?? ""
        phoneNumber = info.phoneNumber ?? ""
        
        originalEmail = email
        originalPhoneNumber = phoneNumber
        originalCountryCode = info.countryCode ?? ""
        originalFullName = fullName
        
        if let subs = info.noofSubscriptions {
            selectedSubscriptions = subs
        }
        originalSubscriptions = selectedSubscriptions
        
        if let spend = info.averageMonthlySpend {
            selectedSpending = spend
        }
        originalSpending = selectedSpending
        
        if let currencyCode = info.preferredCurrency {
            selectedCurrency = commonApiVM.currencyResponse?.first(where: { $0.code == currencyCode })
        }
        originalCurrencyCode = selectedCurrency?.code ?? ""
        
        if let countryCode = info.countryCode {
            selectedCountry = commonApiVM.countriesResponse?.first(where: { $0.dialCode == countryCode || $0.countryCode == countryCode })
        }
        
        if let draft = commonApiVM.editProfileDraft {

            email = draft.email
            phoneNumber = draft.phoneNumber
            fullName = draft.fullName

            selectedSubscriptions = draft.subscriptions
            selectedSpending = draft.spending
            
            accountTypeVerify = draft.typeVerify
        }
    }
    
    private func saveProfile() {
        accountTypeVerify = 1
        // Build the request for type 1
        let type = 1
        let currencyCode = selectedCurrency?.code ?? Constants.shared.currencyCode
        let currencySymbol = selectedCurrency?.symbol ?? "$"
        let dialCode = selectedCountry?.dialCode ?? ""
        
        let input = UpdateProfileRequest(userId             : Constants.getUserId(),
                                         type               : type,
                                         fullName           : fullName,
                                         email              : email,
                                         phoneNumber        : phoneNumber,
                                         countryCode        : dialCode,
                                         currency           : currencyCode,
                                         currencySymbol     : currencySymbol,
                                         noofSubscriptions  : selectedSubscriptions ?? 1,
                                         averageMonthlySpend: selectedSpending ?? 1)
        
        profileVM.updateProfile(input: input)
    }
    
    private func verifyEmail() {
        if email.trimmed.isEmpty {
            ToastManager.shared.showToast(message: "Email is required".localized, style: .error)
        }else if !Validations().isValidEmail(email.trimmed){
            ToastManager.shared.showToast(message: "Enter valid email".localized, style: .error)
        }else{
            accountTypeVerify = 2
            let input = UpdateProfileRequest(userId             : Constants.getUserId(),
                                             type               : 2,
                                             fullName           : fullName,
                                             email              : email,
                                             phoneNumber        : phoneNumber,
                                             countryCode        : selectedCountry?.dialCode ?? "",
                                             currency           : selectedCurrency?.code ?? "",
                                             currencySymbol     : selectedCurrency?.symbol ?? "",
                                             noofSubscriptions  : selectedSubscriptions ?? 1,
                                             averageMonthlySpend: selectedSpending ?? 1)
            profileVM.updateProfile(input: input)
        }
    }
    
    private func verifyPhone() {
        if phoneNumber.isEmpty{
            ToastManager.shared.showToast(message: "Phone number is required".localized, style: .error)
        }else if !Validations().isValidMobile(phoneNumber){
            ToastManager.shared.showToast(message: "Invalid mobile number".localized, style: .error)// must be between 6 to 15 digits"
        }else{
            accountTypeVerify = 3
            let input = UpdateProfileRequest(userId             : Constants.getUserId(),
                                             type               : 3,
                                             fullName           : fullName,
                                             email              : email,
                                             phoneNumber        : phoneNumber,
                                             countryCode        : selectedCountry?.dialCode ?? "",
                                             currency           : selectedCurrency?.code ?? "",
                                             currencySymbol     : selectedCurrency?.symbol ?? "",
                                             noofSubscriptions  : selectedSubscriptions ?? 1,
                                             averageMonthlySpend: selectedSpending ?? 1)
            profileVM.updateProfile(input: input)
        }
    }
    
    private func getInitials(name: String) -> String {
        let words = name.split(separator: " ").filter { !$0.isEmpty }
        if words.count == 1 {
            return String(words[0].prefix(1)).uppercased()
        } else if words.count >= 2 {
            return (String(words[0].prefix(1)) + String(words[1].prefix(1))).uppercased()
        }
        return ""
    }
}
