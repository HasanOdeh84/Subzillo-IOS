//
//  reviewExtractedDetailsView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 02/12/25.
//

import SwiftUI

struct ReviewExtractedDetailsView: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    var title                                   : String? = "Review Extracted Details"
    var detailType                              : ReviewExtractedType = .currency
    var buttonIcon                              : String? = "update"
    var buttonTitle                             : String? = "Update"
    var confidence                              : Double = 0.0
    var isAssumed                               : Bool = false
    var extractedData                           : SubscriptionData?
    @State private var selectedCurrency         : Currency?
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @State private var serviceName              : String = ""
    @State private var category                 : String = ""
    @State var selectedCategory                 : Category?
    @State private var showCategorySheet        = false
    @State private var amount                   : String = ""
    @State private var planType                 : String = ""
    @State private var isDatePickerPresented    = false
    @State private var tempDate                 = Date()
    @State private var chargeDate               : String = ""
    @StateObject private var toastManager       = ToastManager()
    @State private var billingCycle             : String = ""
    @State var selectedBilling                  : String?
    @State private var showBillingCycleSheet    = false
    @State private var billingData              = [
        ManualDataInfo(id: "1", title: "Daily", subtitle: "Every 24 hours"),
        ManualDataInfo(id: "2", title: "Weekly", subtitle: "Every 7 Days"),
        ManualDataInfo(id: "3", title: "Monthly", subtitle: "Every 30 Days"),
        ManualDataInfo(id: "4", title: "Quarterly", subtitle: "Every 90 Days"),
        ManualDataInfo(id: "5", title: "Biannually", subtitle: "Every 180 Days"),
        ManualDataInfo(id: "6", title: "Yearly", subtitle: "Every 360 Days")
    ]
    @FocusState private var isInputActive       : Bool
    @FocusState private var dummyFocus          : Bool
    @State private var activeField              : FieldType?
    
    @State var isAmountUpdate                   = false
    @State var isPlanTypeUpdate                 = false
    @State var isPlanTypeError                  : Bool = false
    @State var isAmountError                    : Bool = false
    
    @State var servicesList                     : [GetServiceProvidersListData]?
    @State var providerPlansList                : [ProviderSubscriptionPlan]?
    @State private var showPlanTypeSheet        = false
    @State var selectedPlanType                 : String?
    @State private var sheetHeight              : CGFloat = 300
    
    //MARK: - body
    var body: some View {
        let (confidenceStr, colorValue, fillRatio) =
        Constants.confidenceInfo(isAssumed: isAssumed, confidence: confidence)
        
        Capsule()
            .fill(Color.grayCapsule)
            .frame(width: 150, height: 5)
            .padding(.top,24)
            .padding(.horizontal, -5)
        
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                
                Text(LocalizedStringKey(title ?? ""))
                    .font(.appRegular(24))
                    .foregroundStyle(.neutralMain700)
                    .multilineTextAlignment(.center)
                    .padding(.top,24)
                    .padding(.horizontal, -5)
                
                //            Text(confidenceStr)
                //                .frame(maxWidth: .infinity)
                //                .frame(height: 28)
                //                .font(.appRegular(14))
                //                .foregroundColor(.neutralMain700)
                //                .multilineTextAlignment(.center)
                //                .padding(.horizontal, 16)
                //                .background(colorValue)
                //                .cornerRadius(4)
                ConfidenceBarView(
                    text        : confidenceStr,
                    color       : colorValue,
                    fillRatio   : fillRatio
                )
                .padding(.bottom,36)
                .padding(.horizontal, -5)
                
                switch detailType {
                    //MARK: - service
                case .service:
                    FieldSuggestionView(
                        text        : $serviceName,
                        title       : "Service Name",
                        image       : "gridIcon",
                        placeHolder : "e.g. Netflix, Spotify, Adobe",
                        suggestions : servicesList ?? [],
                        displayKey  : { $0.name ?? "" },
                        isFocused   : $dummyFocus,
                        fieldType   : FieldType.serviceName,
                        activeField : $activeField,
                        action      : {
                        }
                    )
                    //MARK: - amount
                case .amount:
                    FieldSuggestionView(
                        text        : $amount,
                        title       : "Amount",
                        image       : "currencyIcon",
                        placeHolder : "0.00",
                        currency    : selectedCurrency?.symbol ?? extractedData?.currencySymbol ?? "",//(extractedData?.currency ?? "" == "") ? (selectedCurrency?.symbol ?? Constants.shared.currencySymbol) : (selectedCurrency?.symbol ?? extractedData?.currencySymbol ?? ""),//Constants.shared.currencySymbol,
                        isNumberPad : true,
                        suggestions : filteredPricePlans(),
                        displayKey  : { plan in
                            String(format: "%.2f", plan.price ?? 0)
                        },
                        isFocused   : $isInputActive,
                        fieldType   : FieldType.amount,
                        activeField : $activeField,
                        action      : {
                            errorHint(isAmount: true)
                            isAmountUpdate = true
                        }
                        //                    ,
                        //                    onSelect    : { plan in
                        //                        selectedCurrency = Currency(id      : nil,
                        //                                                    name    : "",
                        //                                                    symbol  : plan.currencySymbol,
                        //                                                    code    : plan.currencyCode,
                        //                                                    flag    : "")
                        //                    }
                    )
                    //                .focused($isInputActive)
                    
                    if isAmountError{
                        HStack(spacing: 6){
                            Image("info")
                                .frame(width: 24, height: 24)
                            Text("This amount is not available for this service")
                                .font(.appRegular(14))
                                .foregroundColor(Color.systemInfoBlue)
                            Spacer()
                        }
                        .padding(.leading, 5)
                        .padding(.top, -5)
                    }
                    //MARK: - nextChargeDate
                case .nextChargeDate:
                    Button(action: dateSelection) {
                        FieldView(text: $chargeDate, textValue: "", title: "Next Charge Date", image: "Calendar1", placeHolder: "dd/mm/yyyy", isButton: false, isText: true, isDate:true)
                    }
                    .background(
                        DatePickerPopup(isPresented: $isDatePickerPresented, selectedDate: $tempDate) { date in
                            let formatter = DateFormatter()
                            formatter.dateFormat = "dd/MM/yyyy"//"yyyy-MM-dd"
                            self.chargeDate = formatter.string(from: date)
                            print(chargeDate)
                        }
                    )
                    //MARK: - currency
                case .currency:
                    PhoneNumberField(phoneNumber        : .constant(""),
                                     header             : "Your payment currency",
                                     placeholder        : selectedCurrency?.name,
                                     selectedCurrency   : $selectedCurrency,
                                     selectedCountry    : .constant(nil),
                                     isCountry          : false,
                                     fromPreview        : true)
                    //MARK: - category
                case .category:
                    Button(action: selectCategory) {
                        FieldView(text: $category, textValue: selectedCategory?.name ?? "", title: "Category", image: "gridIcon", placeHolder: "Please select", isButton: true, isText: true)
                    }
                    .sheet(isPresented: $showCategorySheet) {
                        CategoriesBottomSheet(selectedCategory: $selectedCategory, categoryResponse:commonApiVM.categoriesResponse, header: "Select Category", placeholder: "Search Category")
                            .presentationDetents([.large])
                            .presentationDragIndicator(.hidden)
                    }
                    //MARK: - planType
                case .planType:
                    //                FieldSuggestionView(
                    //                    text        : $planType,
                    //                    title       : "Plan Type",
                    //                    image       : "gridicon2",
                    //                    placeHolder : "e.g. Free, Pro, Premium",
                    //                    suggestions : providerPlansList ?? [],
                    //                    displayKey  : { $0.planName ?? "" },
                    //                    isFocused   : $dummyFocus,
                    //                    fieldType   : FieldType.planType,
                    //                    activeField : $activeField,
                    //                    action      : {
                    //                        errorHint(isAmount: false)
                    //                        isPlanTypeUpdate = true
                    //                    }
                    //                )
                    //                if isPlanTypeError{
                    //                    HStack(spacing: 6){
                    //                        Image("info")
                    //                            .frame(width: 24, height: 24)
                    //                        Text("This plan is not available for this service")
                    //                            .font(.appRegular(14))
                    //                            .foregroundColor(Color.systemInfoBlue)
                    //                        Spacer()
                    //                    }
                    //                    .padding(.leading, 5)
                    //                    .padding(.top, -5)
                    //                }
                    
                    Button(action: selectPlanType) {
                        FieldView(text: $planType, textValue: selectedPlanType ?? "", title: "Plan Type", image: "gridicon2", placeHolder: "Please select", isButton: true, isText: true)
                    }
                    .sheet(isPresented: $showPlanTypeSheet) {
                        PlanTypeBottomSheet(selectedPlanType    : $selectedPlanType,
                                            planTypeResponse    : filteredPlanTypes(),
                                            header              : "Select Plan Type",
                                            placeholder         : "Search Plan Type",
                                            action              : {
                            planType = selectedPlanType ?? ""
                            //                        autoFillDetails(isAmount: false)
                            errorHint(isAmount: false)
                            isPlanTypeUpdate = true
                        })
                        .overlay {
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: InnerHeightPreferenceKey.self,
                                        value: geo.size.height
                                    )
                            }
                        }
                        .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                            if height > 150 {
                                sheetHeight = height
                            }
                        }
                        .presentationDetents([.height(sheetHeight)])
                        .presentationDragIndicator(.hidden)
                    }
                    //MARK: - billingCycle
                case .billingCycle:
                    Button(action: selectBilling) {
                        FieldView(text: $billingCycle, textValue: selectedBilling ?? "", title: "Billing Cycle", image: "billing", placeHolder: "Select billing cycle", isButton: true, isText: true)
                    }
                    .sheet(isPresented: $showBillingCycleSheet) {
                        BillingCycleBottomSheet(selectedBilling         : $selectedBilling,
                                                billingCyclesResponse   : filteredBillingCycles(),
                                                header                  : "Select Billing Cycle",
                                                placeholder             : "Search billing cycle",
                                                onSelect: { billing in
                        })
                        .overlay {
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: InnerHeightPreferenceKey.self,
                                        value: geo.size.height
                                    )
                            }
                        }
                        .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                            if height > 150 {
                                sheetHeight = height
                            }
                        }
                        .presentationDetents([.height(sheetHeight)])
                        .presentationDragIndicator(.hidden)
                    }
                }
                
                //MARK: - Update button
                GradientBorderButton(title          : buttonTitle ?? "",
                                     isBtn          : true,
                                     buttonImage    : buttonIcon ?? "") {
                    switch detailType {
                    case .service:
                        if serviceName.trimmed == ""{
                            toastManager.showToast(message: "Please enter service name".localized, style: .error)
                            return
                        }
                        globalSubscriptionData?.serviceName     = serviceName.trimmed
                    case .amount:
                        let amountDouble = Double(amount.trimmed) ?? 0.0
                        //                    if amountDouble == 0.0 || amount.trimmed == ""{
                        if amount.trimmed == ""{
                            toastManager.showToast(message: "Amount is required".localized, style: .error)
                            return
                        }
                        globalSubscriptionData?.amount = amountDouble
                        if isAmountUpdate{
                            autoFillDetails(isAmount: true)
                        }
                        
                        //need to change the currency if that provider is from other country
                        globalSubscriptionData?.currency = selectedCurrency?.code ?? ""
                        globalSubscriptionData?.currencySymbol = selectedCurrency?.symbol ?? ""
                    case .nextChargeDate:
                        if chargeDate == ""{
                            toastManager.showToast(message: "Please select next charge date".localized, style: .error)
                            return
                        }
                        globalSubscriptionData?.nextPaymentDate = chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                    case .currency:
                        if selectedCurrency?.code ?? "" == ""{
                            toastManager.showToast(message: "Currency selection required".localized, style: .error)
                            return
                        }
                        globalSubscriptionData?.currency = selectedCurrency?.code ?? ""
                        globalSubscriptionData?.currencySymbol = selectedCurrency?.symbol ?? ""
                    case .category:
                        if category == ""{
                            toastManager.showToast(message: "Please select category".localized, style: .error)
                            return
                        }
                        globalSubscriptionData?.categoryId = selectedCategory?.id ?? ""
                        globalSubscriptionData?.categoryName = selectedCategory?.name ?? ""
                    case .planType:
                        if selectedPlanType?.trimmed == ""{
                            toastManager.showToast(message: "Please select plan type".localized, style: .error)
                            return
                        }
                        globalSubscriptionData?.subscriptionType = selectedPlanType?.trimmed
                        if isPlanTypeUpdate{
                            autoFillDetails(isAmount: false)
                        }
                        //need to change the currency if that provider is from other country
                        globalSubscriptionData?.currency = selectedCurrency?.code ?? ""
                        globalSubscriptionData?.currencySymbol = selectedCurrency?.symbol ?? ""
                    case .billingCycle:
                        if selectedBilling ?? "" == ""{
                            toastManager.showToast(message: "Please select a billing cycle".localized, style: .error)
                            return
                        }
                        globalSubscriptionData?.billingCycle = selectedBilling ?? ""//.lowercased()
                        chargeDate = Constants.shared.getNextDateByFrequency(
                            frequency: selectedBilling ?? ""
                        )
                        if globalSubscriptionData?.nextPaymentDate == "" || globalSubscriptionData?.nextPaymentDate == nil{
                            globalSubscriptionData?.nextPaymentDate = chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                        }
                        
                        //amount should be changed based on the billing cycle
                        if globalSubscriptionData?.amount == nil{
                            amountUpdate()
                        }
                        //need to change the currency if that provider is from other country
                        globalSubscriptionData?.currency = selectedCurrency?.code ?? ""
                        globalSubscriptionData?.currencySymbol = selectedCurrency?.symbol ?? ""
                    }
                    onDelegate?()
                    dismiss()
                }
                                     .padding(.vertical,36)
                                     .padding(.horizontal, -5)
                
            }
            .padding(.horizontal, 24)
        }
        //MARK: OnAppear
        .onAppear{
            globalSubscriptionData = extractedData
            if detailType == .category{
                commonApiVM.getCategories()
            }
            setupData()
        }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
        .modifier(ToastModifier(toast: toastManager))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(LocalizedStringKey("Done")) {
                    isInputActive = false
                    if detailType == .amount{
                        errorHint(isAmount: true)
                        isAmountUpdate = true
                    }
                }
            }
        }
    }
    
    //MARK: - User defined methods
    //    func filteredPricePlans() -> [ProviderSubscriptionPlan] {
    //        guard let plans = providerPlansList else{//manualEntryVM.providerData?.providerSubscriptionPlansList else {
    //            return []
    //        }
    //        return Array(
    //            Dictionary(
    //                grouping: plans.compactMap { plan in
    //                    guard plan.price != nil else { return nil }
    //                    return plan
    //                },
    //                by: { $0.price! }
    //            )
    //            .values
    //                .compactMap { $0.first }
    //        )
    //    }
    
    func filteredPricePlans() -> [ProviderSubscriptionPlan] {
        guard let plans = providerPlansList else{//manualEntryVM.providerData?.providerSubscriptionPlansList else {
            return []
        }
        
        let filteredPlans: [ProviderSubscriptionPlan]
        if let selected = selectedPlanType, !selected.isEmpty {
            filteredPlans = plans.filter { ($0.planName ?? "").caseInsensitiveCompare(selected) == .orderedSame }
        } else {
            filteredPlans = plans
        }
        
        return Array(
            Dictionary(
                grouping: filteredPlans.compactMap { plan in
                    guard plan.price != nil else { return nil }
                    return plan
                },
                by: { $0.price! }
            )
            .values
                .compactMap { $0.first }
        )
    }
    
    func filteredPlanTypes() -> [String] {
        guard
            let plans = providerPlansList,
            !plans.isEmpty
        else {
            // Fallback when API returns no plans
            return ["Free", "Basic"]
        }
        
        let planNames = plans.compactMap { $0.planName }
        
        // If plan names are missing or empty, still return fallback
        guard !planNames.isEmpty else {
            return ["Free", "Basic"]
        }
        
        return Array(Set(planNames))
    }
    
    //    func filteredBillingCycles() -> [String] {
    //        guard
    //            let billingCycles = providerPlansList,
    //            !billingCycles.isEmpty
    //        else {
    //            // Fallback when API returns no plans
    //            return ["Monthly", "Yearly"]
    //        }
    //
    //        let billingCycleNames = billingCycles.compactMap { $0.billingCycle }
    //
    //        // If plan names are missing or empty, still return fallback
    //        guard !billingCycleNames.isEmpty else {
    //            return ["Monthly", "Yearly"]
    //        }
    //
    //        return Array(Set(billingCycleNames))
    //    }
    
    func filteredBillingCycles() -> [String] {
        guard
            let billingCycles = providerPlansList,
            !billingCycles.isEmpty
        else {
            // Fallback when API returns no plans
            return ["Monthly", "Yearly"]
        }
        
        let filteredPlans: [ProviderSubscriptionPlan]
        if let selected = selectedPlanType, !selected.isEmpty {
            filteredPlans = billingCycles.filter { ($0.planName ?? "").caseInsensitiveCompare(selected) == .orderedSame }
        } else {
            filteredPlans = billingCycles
        }
        
        let billingCycleNames = filteredPlans.compactMap { $0.billingCycle }
        
        // If plan names are missing or empty, still return fallback
        guard !billingCycleNames.isEmpty else {
            return ["Monthly", "Yearly"]
        }
        
        return Array(Set(billingCycleNames))
    }
    
    func amountUpdate(){
        guard
            let selectedBilling = selectedBilling?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !selectedBilling.isEmpty,
            let plans = providerPlansList
        else {
            return
        }
        
        if let matchedPlan = plans.first(where: {
            ($0.billingCycle ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare(selectedBilling) == .orderedSame
        }) {
            globalSubscriptionData?.amount = matchedPlan.price ?? 0.0
            if globalSubscriptionData?.currency == ""{
                updateCurrency(currencyCode     : matchedPlan.currencyCode ?? Constants.shared.regionCode,
                               currencySymbol   : matchedPlan.currencySymbol ?? Constants.shared.currencySymbol)
            }
        }
    }
    
    private func selectPlanType()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showPlanTypeSheet = true
        }
    }
    
    private func selectCategory()
    {
        showCategorySheet = true
    }
    
    private func selectBilling()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showBillingCycleSheet = true
        }
    }
    
    private func dateSelection() {
        withAnimation(.easeInOut) {
            isDatePickerPresented = true
        }
    }
    
    private func updateCatInfo() {
        if globalSubscriptionData?.categoryId ?? "" != "" {
            if let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first(where: { $0.id == globalSubscriptionData?.categoryId ?? ""})
            }
        }
        if category != ""
        {
            if let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first(where: { $0.name?.lowercased() == category.lowercased()})
            }
        }
    }
    
    func setupData(){
        serviceName = extractedData?.serviceName ?? ""
        amount      = "\(extractedData?.amount ?? 0.0)"
        chargeDate  = (extractedData?.nextPaymentDate ?? "").formattedDate(to: "dd/MM/yyyy")
        if extractedData?.currency ?? "" != ""{
            if let currencies = commonApiVM.currencyResponse {
                selectedCurrency = currencies.first(where: { $0.code == extractedData?.currency ?? ""})
            }
            if selectedCurrency == nil{
                selectedCurrency = Currency(id      : nil,
                                            name    : "",
                                            symbol  : extractedData?.currencySymbol ?? "",
                                            code    : extractedData?.currency ?? "",
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
        category    = extractedData?.categoryName ?? ""
        planType            = extractedData?.subscriptionType ?? ""
        selectedPlanType    = extractedData?.subscriptionType ?? ""
        if extractedData?.billingCycle ?? "" != "" {
            selectedBilling = globalSubscriptionData?.billingCycle ?? ""//billingData.first(where: { $0.title == globalSubscriptionData?.billingCycle ?? ""})
        }
    }
    
    func updateCurrency(currencyCode:String, currencySymbol:String){
        selectedCurrency = Currency(id      : nil,
                                    name    : Constants.shared.currencyCode,
                                    symbol  : Constants.shared.currencySymbol,
                                    code    : Constants.shared.currencyCode,
                                    flag    : Constants.shared.flag(from: Constants.shared.regionCode))
        if let currencies = commonApiVM.currencyResponse {
            selectedCurrency = currencies.first(where: { $0.code == currencyCode })
            if selectedCurrency == nil{
                selectedCurrency = Currency(id      : nil,
                                            name    : "",
                                            symbol  : currencySymbol,
                                            code    : currencyCode,
                                            flag    : "")
            }
        }else{
            commonApiVM.getCurrencies()
        }
        isCurrencyUpdateGlobal = true
    }
    
    private func autoFillDetails(isAmount:Bool = false){
        if isAmount{
            guard
                let enteredAmount = Double(amount),
                let plans = providerPlansList
            else {
                isAmountError = false
                return
            }
            if let matchedPlan = plans.first(where: {
                guard let price = $0.price else { return false }
                return abs(price - enteredAmount) < 0.01
            }) {
                if globalSubscriptionData?.subscriptionType == "" || globalSubscriptionData?.subscriptionType == nil{
                    globalSubscriptionData?.subscriptionType = matchedPlan.planName ?? ""
                    globalSubscriptionData?.billingCycle = matchedPlan.billingCycle ?? ""//.lowercased()
                    chargeDate = Constants.shared.getNextDateByFrequency(
                        frequency: matchedPlan.billingCycle ?? ""
                    )
                    if globalSubscriptionData?.nextPaymentDate == "" || globalSubscriptionData?.nextPaymentDate == nil{
                        globalSubscriptionData?.nextPaymentDate = chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                    }
                }
                if globalSubscriptionData?.currency == ""{
                    updateCurrency(currencyCode     : matchedPlan.currencyCode ?? Constants.shared.regionCode,
                                   currencySymbol   : matchedPlan.currencySymbol ?? Constants.shared.currencySymbol)
                }
                isAmountError = false
            } else {
                if providerPlansList?.count != 0{
                    isAmountError = true
                }
            }
        }else{
            guard
                let selectedPlanType = selectedPlanType,
                !selectedPlanType.isEmpty,
                let plans = providerPlansList
            else {
                isPlanTypeError = false
                
                //For first-time users, the available plan types are Free Plan and Basic Plan. When the user selects either one, the billing cycle should be displayed as Monthly by default.
                if selectedPlanType == "Free" || selectedPlanType == "Basic"{
                    selectedBilling = "Monthly"
                    globalSubscriptionData?.billingCycle = "Monthly"
                }
                if selectedPlanType == "Free"{
                    globalSubscriptionData?.amount = 0.0
                }
                
                return
            }
            if let matchedPlan = plans.first(where: {
                ($0.planName ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .caseInsensitiveCompare(
                        selectedPlanType.trimmingCharacters(in: .whitespacesAndNewlines)
                    ) == .orderedSame
            }) {
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                //
                //                }
                if globalSubscriptionData?.amount == nil{
                    globalSubscriptionData?.amount = matchedPlan.price
                }
                if globalSubscriptionData?.billingCycle == "" || globalSubscriptionData?.billingCycle == nil{
                    globalSubscriptionData?.billingCycle = matchedPlan.billingCycle ?? ""//.lowercased()
                }
                chargeDate = Constants.shared.getNextDateByFrequency(
                    frequency: matchedPlan.billingCycle ?? ""
                )
                if globalSubscriptionData?.nextPaymentDate == "" || globalSubscriptionData?.nextPaymentDate == nil{
                    globalSubscriptionData?.nextPaymentDate = chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                }
                if globalSubscriptionData?.currency == ""{
                    updateCurrency(currencyCode     : matchedPlan.currencyCode ?? Constants.shared.regionCode,
                                   currencySymbol   : matchedPlan.currencySymbol ?? Constants.shared.currencySymbol)
                }
                isPlanTypeError = false
            } else {
                if selectedPlanType == "Free" || selectedPlanType == "Basic"{
                    selectedBilling = "Monthly"
                    globalSubscriptionData?.billingCycle = "Monthly"
                }
                if selectedPlanType == "Free"{
                    globalSubscriptionData?.amount = 0.0
                }
                if !(providerPlansList?.isEmpty ?? true) {
                    isPlanTypeError = true
                }
            }
        }
    }
    
    private func errorHint(isAmount: Bool = false) {
        if isAmount {
            guard
                let enteredAmount = Double(amount),
                let plans = providerPlansList,
                !plans.isEmpty
            else {
                isAmountError = false
                return
            }
            
            let isMatched = plans.contains { plan in
                guard let price = plan.price else { return false }
                return abs(price - enteredAmount) < 0.01
            }
            
            isAmountError = !isMatched
        } else {
            guard
                //                !selectedPlanType?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                //                let plans = providerPlansList,
                //                !plans.isEmpty
                let selectedPlanType = selectedPlanType?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                !selectedPlanType.isEmpty,
                let plans = providerPlansList,
                !plans.isEmpty
            else {
                isPlanTypeError = false
                return
            }
            
            let isMatched = plans.contains { plan in
                (plan.planName ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .caseInsensitiveCompare(
                        selectedPlanType.trimmingCharacters(in: .whitespacesAndNewlines)
                    ) == .orderedSame
            }
            
            isPlanTypeError = !isMatched
        }
    }
}

#Preview {
    ReviewExtractedDetailsView()
}
