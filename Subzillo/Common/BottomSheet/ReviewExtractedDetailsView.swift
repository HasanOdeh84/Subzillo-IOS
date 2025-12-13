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
    @State var selectedBilling                  : ManualDataInfo?
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
    @StateObject var manualEntryVM              = ManualEntryViewModel()
    @State private var activeField              : FieldType?
    
    //MARK: - body
    var body: some View {
        let (confidenceStr, colorValue) = Constants.confidenceInfo(isAssumed: isAssumed, confidence: confidence)
        
        VStack(alignment: .center) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top,24)
                .padding(.horizontal, -5)
            
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(24))
                .foregroundStyle(.neutralMain700)
                .multilineTextAlignment(.center)
                .padding(.top,24)
                .padding(.horizontal, -5)
            
            Text(confidenceStr)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .background(colorValue)
                .cornerRadius(4)
                .padding(.bottom,36)
                .padding(.horizontal, -5)
            
            switch detailType {
            case .service:
                FieldSuggestionView(
                    text        : $serviceName,
                    title       : "Service Name",
                    image       : "gridIcon",
                    placeHolder : "e.g. Netflix, Spotify, Adobe",
                    suggestions : manualEntryVM.servicesList ?? [],
                    displayKey  : { $0.name ?? "" },
                    fieldType   : FieldType.serviceName,
                    activeField : $activeField,
                    action      : {
//                        fetchProviderDataApi()
                    }
                )
//                FieldView(text: $serviceName, title: "Service Name", image: "gridIcon", placeHolder: "e.g. Netflix, Spotify, Adobe")
            case .amount:
//                FieldView(text: $amount, title: "Amount", image: "currencyIcon", placeHolder: "0.00",isNumberPad: true)
                FieldSuggestionView(
                    text        : $amount,
                    title       : "Amount",
                    image       : "currencyIcon",
                    placeHolder : "0.00",
                    currency    : selectedCurrency?.symbol ?? Constants.shared.currencySymbol,
                    isNumberPad : true,
                    suggestions : manualEntryVM.servicesList ?? [],
                    displayKey  : { $0.name ?? "" },
                    fieldType   : FieldType.amount,
                    activeField : $activeField,
                    action      : {
//                        fetchProviderDataApi()
                    }
                )
                .focused($isInputActive)
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
            case .currency:
                PhoneNumberField(phoneNumber        : .constant(""),
                                 header             : "Your payment currency",
                                 placeholder        : selectedCurrency?.name,
                                 selectedCurrency   : $selectedCurrency,
                                 selectedCountry    : .constant(nil),
                                 isCountry          : false,
                                 fromPreview        : true)
            case .category:
                Button(action: selectCategory) {
                    FieldView(text: $category, textValue: selectedCategory?.name ?? "", title: "Category", image: "gridIcon", placeHolder: "Please select", isButton: true, isText: true)
                }
                .sheet(isPresented: $showCategorySheet) {
                    CategoriesBottomSheet(selectedCategory: $selectedCategory, categoryResponse:commonApiVM.categoriesResponse, header: "Select Category", placeholder: "Search Category")
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
            case .planType:
//                FieldView(text: $planType, title: "Plan Type", image: "gridicon2", placeHolder: "e.g. Free, Pro, Premium")
                FieldSuggestionView(
                    text        : $planType,
                    title       : "Plan Type",
                    image       : "gridicon2",
                    placeHolder : "e.g. Free, Pro, Premium",
                    suggestions : manualEntryVM.servicesList ?? [],
                    displayKey  : { $0.name ?? "" },
                    fieldType   : FieldType.planType,
                    activeField : $activeField,
                    action      : {
//                        fetchProviderDataApi()
                    }
                )
            case .billingCycle:
                Button(action: selectBilling) {
                    FieldView(text: $billingCycle, textValue: selectedBilling?.title ?? "", title: "Billing Cycle", image: "billing", placeHolder: "Select billing cycle", isButton: true, isText: true)
                }
                .sheet(isPresented: $showBillingCycleSheet) {
                    BillingCycleBottomSheet(selectedBilling: $selectedBilling, header: "Select Billing Cycle", placeholder: "Search billing cycle")
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
            }
            
            GradientBorderButton(title          : buttonTitle ?? "",
                                 isBtn          : true,
                                 buttonImage    : buttonIcon ?? "") {
                switch detailType {
                case .service:
                    if serviceName.trimmed == ""{
                        toastManager.showToast(message: "Please enter service name",style:ToastStyle.error)
                        return
                    }
                    globalSubscriptionData?.serviceName = serviceName.trimmed
                case .amount:
                    let amountDouble = Double(amount.trimmed) ?? 0.0
                    if amountDouble == 0.0 || amount.trimmed == ""{
                        toastManager.showToast(message: "Amount is required",style:ToastStyle.error)
                        return
                    }
                    globalSubscriptionData?.amount = amountDouble
                case .nextChargeDate:
                    if chargeDate == ""{
                        toastManager.showToast(message: "Please select next charge date",style:ToastStyle.error)
                        return
                    }
                    globalSubscriptionData?.nextPaymentDate = chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                case .currency:
                    if selectedCurrency?.code ?? "" == ""{
                        toastManager.showToast(message: "Currency selection required",style:ToastStyle.error)
                        return
                    }
                    globalSubscriptionData?.currency = selectedCurrency?.code ?? ""
                    globalSubscriptionData?.currencySymbol = selectedCurrency?.symbol ?? ""
                case .category:
                    if category == ""{
                        toastManager.showToast(message: "Please select category",style:ToastStyle.error)
                        return
                    }
                    globalSubscriptionData?.categoryId = category
                    globalSubscriptionData?.categoryName = selectedCategory?.name ?? ""
                case .planType:
                    if planType.trimmed == ""{
                        toastManager.showToast(message: "Please select plan type",style:ToastStyle.error)
                        return
                    }
                    globalSubscriptionData?.subscriptionType = planType.trimmed
                case .billingCycle:
                    if selectedBilling?.title ?? "" == ""{
                        toastManager.showToast(message: "Please select a billing cycle",style:ToastStyle.error)
                        return
                    }
                    globalSubscriptionData?.billingCycle = selectedBilling?.title ?? "".lowercased()
                }
                onDelegate?()
                dismiss()
            }
                                 .padding(.vertical,36)
                                 .padding(.horizontal, -5)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        //MARK: OnAppear
        .onAppear{
            globalSubscriptionData = extractedData
            if detailType == .category{
                commonApiVM.getCategories()
            }else if detailType == .currency{
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
            setupData()
            manualEntryVM.getServiceProvidersList()
        }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
        .modifier(ToastModifier(toast: toastManager))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isInputActive = false
                }
            }
        }
    }
    
    //MARK: - User defined methods
    
    func fetchProviderDataApi(){
        manualEntryVM.fetchProviderData(input: FetchProviderDataRequest(userId          : Constants.getUserId(),
                                                                        serviceName     : serviceName,
                                                                        currencyCode    : selectedCurrency?.code ?? "" == "" ? Constants.shared.regionCode : selectedCurrency?.code ?? ""))
    }
    
    private func selectCategory()
    {
        showCategorySheet = true
    }
    
    private func selectBilling()
    {
        showBillingCycleSheet = true
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
        }
        category    = extractedData?.categoryName ?? ""
        planType    = extractedData?.subscriptionType ?? ""
        if extractedData?.billingCycle ?? "" != "" {
            selectedBilling = billingData.first(where: { $0.title == globalSubscriptionData?.billingCycle ?? ""})
        }
    }
}

#Preview {
    ReviewExtractedDetailsView()
}
