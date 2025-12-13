//
//  ManualEntryView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/11/25.
//

import SwiftUI
import UIKit

struct ManualEntryView: View {
    
    //MARK: - Properties
    @State var isFromEdit                       = false
    @State var isFromListEdit                   = false
    @State private var showActionSheet          = false
    @State private var showImagePicker          = false
    @State private var selectedImage            : UIImage? = nil
    @State private var pickerSource             : UIImagePickerController.SourceType = .photoLibrary
    @State private var showCurrencySheet        = false
    @State var selectedCurrency                 : Currency?
    @State var selectedCountry                  : Country?
    @State private var showCategorySheet        = false
    @State var selectedCategory                 : Category?
    @State private var isCards                  = false
    @State var showPaymentMethodSheet           = false
    @State var selectedPayment                  : PaymentMethod?
    @State var canAddMembers                    = false
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @StateObject var addSubscriptionVM          = ManualEntryViewModel()
    
    @State private var serviceName              : String = ""
    @State private var amount                   : String = ""
    @State private var currency                 : String = ""
    @State private var planType                 : String = ""
    @State private var chargeDate               : String = ""
    @State private var category                 : String = ""
    @State private var paymentMethod            : String = ""
    @State private var notes                    : String = ""
    @State private var isDatePickerPresented    = false
    @State private var tempDate                 = Date()
    @State private var cardIndex                : Int = -1
    @State private var relationIndex            : Int = 0
    @State private var reminderInedex           : Int = -1
    @State private var isMoreEnable             : Bool = false
    @State var subscriptionId                   = ""
    @State var fromSiri                         = false
    @Environment(\.dismiss) private var dismiss
    
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
    @State private var billingIndex             : Int = -1
    @State private var cardsData : [ManualDataInfo] = []
    @State private var relationsData = [
        ManualDataInfo(id: Constants.getUserId(), title: "Me")
    ]
    
    @State private var remindersData = [
        ManualDataInfo(id: "1", title: "3 days before renewal", value: "-3d"),
        ManualDataInfo(id: "2", title: "1 day before renewal", value: "-1d"),
        ManualDataInfo(id: "3", title: "On renewal day", value:"0d")
    ]
    
    @State var isPlanTypeError      : Bool = false
    @State var isAmountError        : Bool = false
    @State private var activeField  : FieldType?
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: - Title
                    Text(isFromEdit == true ? "Edit Details" : "Manual Entry")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    // MARK: - SubTitle
                    Text(isFromEdit == true ? "Update your details" : "Add your subscription details manually.")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Required Information")
                        .font(.appRegular(18))
                        .foregroundColor(.underlineGray)
                        .lineLimit(1)
                        .layoutPriority(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 28)
                    
                    //MARK: - Service field
                    
                    FieldSuggestionView(
                        text        : $serviceName,
                        title       : "Service Name",
                        image       : "gridIcon",
                        placeHolder : "e.g. Netflix, Spotify, Adobe",
                        suggestions : addSubscriptionVM.servicesList ?? [],
                        displayKey  : { $0.name ?? "" },
                        fieldType   : FieldType.serviceName,
                        activeField : $activeField,
                        action      : {fetchProviderDataApi()}
                    )
                    
                    Button(action: selectCategory) {
                        FieldView(text: $category, textValue: selectedCategory?.name ?? "", title: "Category", image: "gridIcon", placeHolder: "Please select", isButton: true, isText: true)
                    }
                    .sheet(isPresented: $showCategorySheet) {
                        CategoriesBottomSheet(selectedCategory: $selectedCategory, categoryResponse:commonApiVM.categoriesResponse, header: "Select Category", placeholder: "Search Category")
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.hidden)
                    }
                    
                    HStack(spacing: 24) {
                        //MARK: - Amount field
                        VStack{
                            FieldSuggestionView(
                                text        : $amount,
                                title       : "Amount",
                                image       : "currencyIcon",
                                placeHolder : "0.00",
                                currency    : selectedCurrency?.symbol ?? Constants.shared.currencySymbol,
                                isNumberPad : true,
                                suggestions : filteredPricePlans(),
                                displayKey  : { plan in
                                    String(format: "%.2f", plan.price ?? 0)
                                },
                                fieldType   : FieldType.amount,
                                activeField : $activeField,
                                action      : {
                                    autoFillDetails(isAmount: true)
                                }
                            )
                            .addDoneButton{
                                handleDone()
                            }
                            
                            //                            FieldSuggestionView(
                            //                                text        : $amount,
                            //                                title       : "Amount",
                            //                                image       : "currencyIcon",
                            //                                placeHolder : "0.00",
                            //                                currency    : selectedCurrency?.symbol ?? Constants.shared.currencySymbol,
                            //                                isNumberPad : true,
                            //                                suggestions : filteredPricePlans(),//addSubscriptionVM.providerData?.providerSubscriptionPlansList ?? [],
                            //                                fieldType   : FieldType.amount,
                            ////                                fieldType   : .amount,
                            //                                activeField : $activeField,
                            //                                displayKey  : { plan in
                            //                                    String(format: "%.2f", plan.price ?? 0)
                            //                                },
                            //                                action      : {
                            ////                                    guard
                            ////                                        let enteredAmount = Double(amount),
                            ////                                        let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList
                            ////                                    else {
                            ////                                        isAmountError = false
                            ////                                        return
                            ////                                    }
                            ////
                            ////                                    if let matchedPlan = plans.first(where: {
                            ////                                        guard let price = $0.price else { return false }
                            ////                                        return abs(price - enteredAmount) < 0.01
                            ////                                    }) {
                            ////                                        if planType == ""{
                            ////                                            planType = matchedPlan.planName ?? ""
                            ////                                        }
                            ////                                        if billingCycle == ""{
                            ////                                            selectedBilling = billingData.first(where: { $0.title == matchedPlan.billingCycle ?? ""})
                            ////                                        }
                            ////                                        isAmountError = false
                            ////                                    } else {
                            ////                                        if addSubscriptionVM.providerData?.providerSubscriptionPlansList?.count != 0{
                            ////                                            isAmountError = true
                            ////                                        }
                            ////                                    }
                            ////                                    autoFillDetails(isAmount: true)
                            //                                }
                            //                            )
                            //                            .addDoneButton{
                            //                                handleDone()
                            //                            }
                            Spacer()
                        }
                        
                        VStack{
                            Button(action: currencySelection) {
                                FieldView(text: $currency, textValue: selectedCurrency?.code ?? "", title: "Currency", image: "globeIcon", placeHolder: Constants.shared.currencyCode, isButton: true, isText: true)
                                    .frame(width: 140, alignment: .trailing)
                            }
                            .sheet(isPresented: $showCurrencySheet) {
                                CountriesBottomSheet(selectedCurrency   : $selectedCurrency,
                                                     selectedCountry    : $selectedCountry,
                                                     isCountry          : false,
                                                     currencyResponse   : commonApiVM.currencyResponse,
                                                     countryResponse    : commonApiVM.countriesResponse,
                                                     header             : "Currency",
                                                     placeholder        : "Search currency")
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.hidden)
                            }
                            Spacer()
                        }
                        .onChange(of: selectedCurrency) { newCurrency in
                            guard let currency = newCurrency else { return }
                            if serviceName != ""{
                                fetchProviderDataApi()
                            }
                        }
                    }
                    
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
                        .padding(.top, -25)
                    }
                    
                    //MARK: - PlanType field
                    FieldSuggestionView(
                        text        : $planType,
                        title       : "Plan Type",
                        image       : "gridicon2",
                        placeHolder : "e.g. Free, Pro, Premium",
                        suggestions : addSubscriptionVM.providerData?.providerSubscriptionPlansList ?? [],
                        displayKey  : { $0.planName ?? "" },
                        fieldType   : FieldType.planType,
                        activeField : $activeField,
                        action      : {
                            autoFillDetails(isAmount: false)
                        }
                    )
                    
                    //                    FieldSuggestionView(
                    //                        text        : $planType,
                    //                        title       : "Plan Type",
                    //                        image       : "gridicon2",
                    //                        placeHolder : "e.g. Free, Pro, Premium",
                    //                        suggestions : addSubscriptionVM.providerData?.providerSubscriptionPlansList ?? [],
                    //                        fieldType   : FieldType.planType,
                    //                        activeField : $activeField,
                    //                        displayKey  : { $0.planName ?? "" },
                    //                        action      : {
                    //                            guard
                    //                                !planType.isEmpty,
                    //                                let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList
                    //                            else {
                    //                                isPlanTypeError = false
                    //                                return
                    //                            }
                    
                    //                            if let matchedPlan = plans.first(where: {
                    //                                ($0.planName ?? "").contains(planType)
                    //                            }) {
                    //                                if amount == ""{
                    //                                    amount = String(format: "%.2f", matchedPlan.price ?? 0)
                    //                                }
                    //                                if billingCycle == ""{
                    //                                    selectedBilling = billingData.first(where: { $0.title == matchedPlan.billingCycle ?? ""})
                    //                                }
                    //                                isPlanTypeError = false
                    //                            } else {
                    //                                if addSubscriptionVM.providerData?.providerSubscriptionPlansList?.count != 0{
                    //                                    isPlanTypeError = true
                    //                                }
                    //                            }
                    
                    //                            if let matchedPlan = plans.first(where: {
                    //                                ($0.planName ?? "")
                    //                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    //                                    .caseInsensitiveCompare(
                    //                                        planType.trimmingCharacters(in: .whitespacesAndNewlines)
                    //                                    ) == .orderedSame
                    //                            }) {
                    //                                if amount.isEmpty {
                    //                                    amount = String(format: "%.2f", matchedPlan.price ?? 0)
                    //                                }
                    //
                    //                                if billingCycle.isEmpty {
                    //                                    selectedBilling = billingData.first {
                    //                                        $0.title == (matchedPlan.billingCycle ?? "")
                    //                                    }
                    //                                }
                    //
                    //                                isPlanTypeError = false
                    //                            } else {
                    //                                if !(addSubscriptionVM.providerData?.providerSubscriptionPlansList?.isEmpty ?? true) {
                    //                                    isPlanTypeError = true
                    //                                }
                    //                            }
                    //                            autoFillDetails(isAmount: true)
                    //                        }
                    //                    )
                    if isPlanTypeError{
                        HStack(spacing: 6){
                            Image("info")
                                .frame(width: 24, height: 24)
                            Text("This plan is not available for this service")
                                .font(.appRegular(14))
                                .foregroundColor(Color.systemInfoBlue)
                            Spacer()
                        }
                        .padding(.leading, 5)
                        .padding(.top, -18)
                    }
                    
                    //                    ListView(type: .billing, title: "Billing Cycle", addMore: false, data: $billingData, selectedIndex: $billingIndex)
                    //                        .frame(height: Double(30 + (52 * billingData.count)))
                    Button(action: selectBilling) {
                        FieldView(text: $billingCycle, textValue: selectedBilling?.title ?? "", title: "Billing Cycle", image: "billing", placeHolder: "Select billing cycle", isButton: true, isText: true)
                    }
                    .sheet(isPresented: $showBillingCycleSheet) {
                        BillingCycleBottomSheet(selectedBilling: $selectedBilling, header: "Select Billing Cycle", placeholder: "Search billing cycle")
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.hidden)
                    }
                    //                    .onChange(of: selectedBilling) { billing in
                    //                        guard billing != nil else { return }
                    //                        chargeDate = Constants.shared.getNextDateByFrequency(frequency: billing.title ?? "")
                    //                    }
                    .onChange(of: selectedBilling) { billing in
                        guard
                            let billing,
                            let title = billing.title
                        else { return }
                        
                        chargeDate = Constants.shared.getNextDateByFrequency(
                            frequency: title
                        )
                    }
                    
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
                    
                    Button(action: optionalDetailsAction) {
                        HStack(spacing: 8) {
                            Text("Optional Details")
                                .font(.appRegular(18))
                                .foregroundColor(.whiteBlackBGnoPic)
                                .lineLimit(1)
                                .layoutPriority(1)
                            DashedHorizontalDivider(dash: [3,3])
                            HStack {
                                Image("downArrow")
                                    .rotationEffect(.degrees(isMoreEnable ? 180 : 0))
                                    .animation(.easeInOut(duration: 0.25), value: isMoreEnable)
                            }
                            .frame(width: 12, height: 7, alignment: .trailing)
                        }
                        .frame(height: 28)
                    }
                    
                    if isMoreEnable == true {
                        
                        Button(action: selectpaymentMethod) {
                            FieldView(text: $paymentMethod, textValue: paymentMethod, title: "Payment Method", image: "Calendar2", placeHolder: "Select payment method", isButton: true, isText: true)
                        }
                        .sheet(isPresented: $showPaymentMethodSheet) {
                            PaymentMethodsSheet(selectedPaymentMethod: $selectedPayment, paymentMethodResponse:commonApiVM.paymentMethodResponse, header: "Select Payment Method", placeholder: "Search Payment Method")
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.hidden)
                        }
                        .onChange(of: selectedPayment) { newValue in
                            guard let newValue = newValue else { return }
                            //                            if newValue.name!.lowercased().contains("card") {
                            //                                isCards = true
                            //                            } else {
                            //                                isCards = false
                            //                            }
                            isCards = newValue.status ?? false
                            paymentMethod = newValue.name!
                        }
                        if isCards == true {
                            ListView(type: .cards, title: "Which card is linked to this subscription?", addMore: true, data: $cardsData, selectedIndex: $cardIndex,onDismiss: {
                                addSubscriptionVM.listUserCards(input: ListUserCardsRequest(userId: Constants.getUserId()))
                            } )
                            .frame(height: Double(75 + (52 * cardsData.count)))
                        }
                        
                        ListView(type: .relations, title: "Who will benefit from this subscription?", addMore: canAddMembers, data: $relationsData, selectedIndex: $relationIndex)
                            .frame(height: canAddMembers == true ? Double(75 + (52 * relationsData.count)) : Double(30 + (52 * relationsData.count)))
                        
                        ListView(type: .reminders, title: "Renewal Reminders", addMore: false, data: $remindersData, selectedIndex: $reminderInedex)
                            .frame(height: Double(30 + (52 * remindersData.count)))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.appRegular(14))
                                .foregroundColor(Color.neutralMain700)
                            VStack{
                                
                                if notes.isEmpty {
                                    Text("Add any additional notes about this subscription...")
                                        .background(Color.clear)
                                        .font(.appRegular(14))
                                        .foregroundColor(.neutral500)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                TextEditor(text: $notes)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .keyboardType(.default)
                                    .autocapitalization(.none)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .font(.appRegular(14))
                                    .foregroundColor(Color.neutralMain700)
                                    .padding(.horizontal, -5)
                                    .padding(.top, -8)
                                    .offset(x: 0, y: notes.isEmpty ? -25 : 0)
                                
                                Spacer(minLength: 0)
                            }
                            .padding(16)
                            .frame(height: 110)
                            //                            .overlay(
                            //                                RoundedRectangle(cornerRadius: 12)
                            //                                    .stroke(Color.neutral2200, lineWidth: 1)
                            //                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.neutral300Border, lineWidth: 1)
                            )
                            .background(Color.whiteNeutralCardBG)
                            .cornerRadius(12)
                        }
                        .padding(5)
                        
                        /*VStack(spacing: 4) {
                         Text("Receipt or Screenshot")
                         .font(.appRegular(14))
                         .foregroundColor(Color.neutralMain700)
                         .frame(maxWidth:.infinity, alignment: .leading)
                         VStack(spacing: 0){
                         Button(action: uploadImage) {
                         if let image = selectedImage {
                         Image(uiImage: image)
                         .resizable()
                         .scaledToFill()
                         .clipShape(RoundedRectangle(cornerRadius: 12))
                         }
                         else {
                         VStack(spacing: 8){
                         Image("uploadImage")
                         Text("Upload receipt or screenshot")
                         .font(.appRegular(14))
                         .foregroundColor(.neutral400)
                         
                         Text("Choose file")
                         .font(.appRegular(16))
                         .foregroundColor(.blueMain700)
                         }
                         .padding(16)
                         }
                         }
                         .confirmationDialog("Select Image", isPresented: $showActionSheet, titleVisibility: .visible) {
                         Button("Camera") {
                         pickerSource = .camera
                         showImagePicker = true
                         }
                         Button("Photo Library") {
                         pickerSource = .photoLibrary
                         showImagePicker = true
                         }
                         Button("Cancel", role: .cancel) { }
                         }
                         .sheet(isPresented: $showImagePicker) {
                         if pickerSource == .camera {
                         ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                         .edgesIgnoringSafeArea(.all)
                         .ignoresSafeArea()
                         } else {
                         ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                         }
                         }
                         }
                         .frame(maxWidth:.infinity)
                         .frame(height: 110)
                         .background(.white)
                         .cornerRadius(12)
                         .overlay(
                         RoundedRectangle(cornerRadius: 12)
                         .stroke(Color.neutral2200, lineWidth: 1)
                         )
                         }
                         */
                    }
                    CustomButton(title: isFromEdit == true ? "Save changes" : "Save Subscription", action: saveAction)
                        .padding(.horizontal, 0)
                        .padding(.bottom, 20)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 24)
        }
        .navigationBarBackButtonHidden()
        .padding(.top, 10)
        .background(.neutralBg100)
        .onAppear{
            addSubscriptionVM.getServiceProvidersList()
            updateSubDetailsTOView()
            //            commonApiVM.getCurrencies()
            commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
            commonApiVM.getCategories()
            commonApiVM.getPaymentMethods()
            addSubscriptionVM.listUserCards(input: ListUserCardsRequest(userId: Constants.getUserId()))
            addSubscriptionVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
            updateCountryAndCurrency()
        }
        .onChange(of: addSubscriptionVM.providerData) { _ in updateProviderData() }
        .onChange(of: commonApiVM.paymentMethodResponse) { _ in updatePaymentInfo() }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
        .onChange(of: commonApiVM.userInfoResponse) { _ in updateUserInfo() }
        .onChange(of: addSubscriptionVM.listFamilyMembersResponse) { _ in updateRelationInfo() }
        .onChange(of: addSubscriptionVM.listUserCardsResponse) { _ in updateCardsInfo() }
        .onChange(of: commonApiVM.currencyResponse) { _ in updateCountryAndCurrency() }
        .onChange(of: addSubscriptionVM.isManualEntrySuccess) { _ in
            self.addSubApiResponseHandling(isAdd:true)
        }
        .onChange(of: addSubscriptionVM.isEditEntrySuccess) { _ in
            self.addSubApiResponseHandling(isAdd:false)
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showCategorySheet = false
            showCurrencySheet = false
            showPaymentMethodSheet = false
        }
        .onTapGesture {
        }
    }
    
    //MARK: - User defined methods
    
    func fetchProviderDataApi(){
        addSubscriptionVM.fetchProviderData(input: FetchProviderDataRequest(userId          : Constants.getUserId(),
                                                                            serviceName     : serviceName,
                                                                            currencyCode    : selectedCurrency?.code ?? "" == "" ? Constants.shared.regionCode : selectedCurrency?.code ?? ""))
    }
    
    func filteredPricePlans() -> [ProviderSubscriptionPlan] {
        guard let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList else {
            return []
        }
        return Array(
            Dictionary(
                grouping: plans.compactMap { plan in
                    guard plan.price != nil else { return nil }
                    return plan
                },
                by: { $0.price! }
            )
            .values
                .compactMap { $0.first }
        )
    }
    
    private func updateProviderData() {
        if addSubscriptionVM.providerData?.categoryName ?? "" != "" && addSubscriptionVM.providerData?.categoryId ?? "" != ""{
            if let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first(where: { $0.id?.lowercased() == addSubscriptionVM.providerData?.categoryId ?? ""})
            }
        }
    }
    
    private func autoFillDetails(isAmount:Bool = false){
        if isAmount{
            guard
                let enteredAmount = Double(amount),
                let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList
            else {
                isAmountError = false
                return
            }
            
            if let matchedPlan = plans.first(where: {
                guard let price = $0.price else { return false }
                return abs(price - enteredAmount) < 0.01
            }) {
                if planType == ""{
                    planType = matchedPlan.planName ?? ""
                }
                if billingCycle == ""{
                    selectedBilling = billingData.first(where: { $0.title == matchedPlan.billingCycle ?? ""})
                }
                isAmountError = false
            } else {
                if addSubscriptionVM.providerData?.providerSubscriptionPlansList?.count != 0{
                    isAmountError = true
                }
            }
        }else{
            guard
                !planType.isEmpty,
                let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList
            else {
                isPlanTypeError = false
                return
            }
            if let matchedPlan = plans.first(where: {
                ($0.planName ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .caseInsensitiveCompare(
                        planType.trimmingCharacters(in: .whitespacesAndNewlines)
                    ) == .orderedSame
            }) {
                if amount.isEmpty {
                    amount = String(format: "%.2f", matchedPlan.price ?? 0)
                }
                
                if billingCycle.isEmpty {
                    selectedBilling = billingData.first {
                        $0.title == (matchedPlan.billingCycle ?? "")
                    }
                }
                
                isPlanTypeError = false
            } else {
                if !(addSubscriptionVM.providerData?.providerSubscriptionPlansList?.isEmpty ?? true) {
                    isPlanTypeError = true
                }
            }
        }
    }
    
    private func addSubApiResponseHandling(isAdd:Bool) {
        if addSubscriptionVM.isManualEntrySuccess == true && isAdd == true || addSubscriptionVM.isEditEntrySuccess == true && isAdd == false{
            if addSubscriptionVM.addSubscriptionResponse != nil {
                
                let duplicates =  addSubscriptionVM.addSubscriptionResponse!.duplicates ?? []
                if duplicates.count > 0
                {
                    var updatedDuplicates: [DuplicateDataInfo] = []
                    
                    for (index, item) in duplicates.enumerated() {
                        
                        var newSubs = item.newSubscription ?? []
                        for i in 0..<newSubs.count {
                            let currentID = newSubs[i].id ?? ""
                            if currentID.isEmpty {
                                newSubs[i].id = "\(i + 1)"
                            }
                        }
                        
                        let oldSubs = item.oldSubscription
                        let name: String? = newSubs.first?.serviceName ?? ""
                        
                        let info = DuplicateDataInfo(
                            id: String(index + 1),
                            serviceName: name,
                            newSubscriptions: newSubs,
                            existingSubscriptions: oldSubs
                        )
                        updatedDuplicates.append(info)
                    }
                    isFromAdd = isAdd
                    AppIntentRouter.shared.navigate(to: .duplicateSubscriptionsView(duplicateSubsList: updatedDuplicates))
                }
                else{
                    //                if isAdd == true {
                    //                    AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
                    //                }
                    //                else{
                    //                    AppIntentRouter.shared.navigate(to: .subscriptionsListView)
                    //                }
                    if isFromListEdit{
                        dismiss()
                    }else{
                        AppIntentRouter.shared.navigate(to: .subscriptionsListView)
                    }
                }
            }
            else{
                //            if isAdd == true {
                //                AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
                //            }
                //            else{
                //                AppIntentRouter.shared.navigate(to: .subscriptionsListView)
                //            }
                if isFromListEdit{
                    dismiss()
                }else{
                    AppIntentRouter.shared.navigate(to: .subscriptionsListView)
                }
            }
        }
    }
    
    private func updatePaymentInfo() {
        if isFromEdit == true
        {
            if globalSubscriptionData?.paymentMethodId ?? "" != "" {
                if let paymentMethod1 = commonApiVM.paymentMethodResponse {
                    selectedPayment = paymentMethod1.first(where: { $0.id == globalSubscriptionData?.paymentMethodId ?? ""})
                    //                    if (selectedPayment?.name ?? "").lowercased().contains("card") {
                    //                        isCards = true
                    //                    } else {
                    //                        isCards = false
                    //                    }
                    isCards = selectedPayment?.status ?? false
                    paymentMethod = selectedPayment?.name ?? ""
                }
            }
        }
    }
    
    private func updateCatInfo() {
        if isFromEdit == true
        {
            if globalSubscriptionData?.categoryId ?? "" != "" {
                if let categories = commonApiVM.categoriesResponse {
                    selectedCategory = categories.first(where: { $0.id == globalSubscriptionData?.categoryId ?? ""})
                }
            }
        }
        if category != ""
        {
            if let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first(where: { $0.name?.lowercased() == category.lowercased()})
            }
        }
    }
    
    func updateUserInfo()
    {
        //print(commonApiVM.userInfoResponse)
        if commonApiVM.userInfoResponse?.tierName?.lowercased() == "family plan"
        {
            let familyMembersLimit = commonApiVM.userInfoResponse?.familyMembersLimit ?? 0
            if familyMembersLimit > relationsData.count - 1
            {
                canAddMembers = true
            }
        }
        updateCountryAndCurrency()
    }
    
    func updateRelationInfo()
    {
        relationsData.removeAll()
        if let familyCards = addSubscriptionVM.listFamilyMembersResponse {
            for family in familyCards {
                relationsData.append(
                    ManualDataInfo(
                        id      : family.id ?? "",
                        title   : family.nickName
                    )
                )
            }
            updateUserInfo()
        }
    }
    
    func updateCardsInfo()
    {
        cardsData.removeAll()
        if let cards = addSubscriptionVM.listUserCardsResponse {
            for card in cards {
                cardsData.append(
                    ManualDataInfo(
                        id      : card.id ?? "",
                        title   : card.nickName,
                        subtitle: card.cardNumber
                    )
                )
            }
        }
        if isFromEdit == true
        {
            let id = globalSubscriptionData?.paymentMethodDataId ?? ""
            if let index = cardsData.firstIndex(where: {
                $0.id == id
            }) {
                cardIndex = index
            }
        }
    }
    
    func updateCountryAndCurrency() {
        if !fromSiri{
            //            selectedCurrency = Currency(id      : nil,
            //                                        name    : Constants.shared.currencyCode,
            //                                        symbol  : Constants.shared.currencySymbol,
            //                                        code    : Constants.shared.currencyCode,
            //                                        flag    : Constants.shared.flag(from: Constants.shared.regionCode))
            //            if let currencies = commonApiVM.currencyResponse {
            //                selectedCurrency = currencies.first(where: { $0.code == Constants.shared.currencyCode })
            //            }else{
            //                commonApiVM.getCurrencies()
            //            }
            selectedCurrency = Currency(id      : nil,
                                        name    : Constants.shared.currencyCode,
                                        symbol  : Constants.shared.currencySymbol,
                                        code    : Constants.shared.currencyCode,
                                        flag    : Constants.shared.flag(from: Constants.shared.regionCode))
            if let currencies = commonApiVM.currencyResponse {
                selectedCurrency = currencies.first(where: { $0.code == commonApiVM.userInfoResponse?.preferredCurrency })
            }else{
                commonApiVM.getCurrencies()
            }
        }else{
            fromSiri = false
        }
        if isFromEdit == true
        {
            if globalSubscriptionData?.currency ?? "" != "" {
                if let currencies = commonApiVM.currencyResponse {
                    selectedCurrency = currencies.first(where: { $0.code == globalSubscriptionData?.currency ?? ""})
                }
            }
        }
    }
    
    private func updateSubDetailsTOView() {
        if siriData != nil
        {
            fromSiri = true
            print(siriData)
            serviceName = siriData["serviceName"] as? String ?? ""
            amount = "\(siriData["price"] as? Double ?? 0.00)"
            planType = siriData["planName"] as? String ?? ""
            currency = siriData["currencyCode"] as? String ?? ""
            category = siriData["category"] as? String ?? ""
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self.chargeDate = formatter.string(from: siriData["nextChargeDate"] as? Date ?? Date())
            var billing = siriData["billingCycle"] as? String ?? ""
            if billing.lowercased() == "annual" {
                billing = "yearly"
            }
            selectedBilling = billingData.first(where: { $0.title == billing})
            //            if let index = billingData.firstIndex(where: {
            //                $0.title!.lowercased() == billing.lowercased()
            //            }) {
            //                billingIndex = index
            //            }
            selectedCurrency = Currency(id: 0, name: "", symbol: siriData["currencySymbol"] as? String ?? "", code: currency, flag: "")
            siriData = nil
        }
        if isFromEdit == true
        {
            let renewalReminder = globalSubscriptionData?.renewalReminder ?? []
            for i in remindersData.indices {
                remindersData[i].isSelected = renewalReminder.contains(remindersData[i].value ?? "")
            }
            notes = globalSubscriptionData?.notes ?? ""
            serviceName = globalSubscriptionData?.serviceName ?? ""
            amount = "\(globalSubscriptionData?.amount ?? 0.00)"
            currency = globalSubscriptionData?.currency ?? ""
            planType = globalSubscriptionData?.subscriptionType ?? ""
            chargeDate = (globalSubscriptionData?.nextPaymentDate ?? "").formattedDate(to: "dd/MM/yyyy")
            let billing = globalSubscriptionData?.billingCycle ?? ""
            //            if let index = billingData.firstIndex(where: {
            //                $0.title!.lowercased() == billing.lowercased()
            //            }) {
            //                billingIndex = index
            //            }
            selectedBilling = billingData.first(where: { $0.title == billing})
        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    private func infoButtonAction() {
    }
    
    private func currencySelection() {
        if commonApiVM.currencyError != nil {
            commonApiVM.getCurrencies()
        } else if commonApiVM.currencyResponse != nil {
            showCurrencySheet = true
        }
    }
    
    private func selectCategory()
    {
        showCategorySheet = true
    }
    
    private func selectBilling()
    {
        showBillingCycleSheet = true
    }
    
    private func selectpaymentMethod()
    {
        showPaymentMethodSheet = true
    }
    
    private func dateSelection() {
        withAnimation(.easeInOut) {
            isDatePickerPresented = true
        }
    }
    
    private func optionalDetailsAction() {
        isMoreEnable.toggle()
    }
    
    private func uploadImage() {
        showActionSheet = true
    }
    
    private func saveAction() {
        var billingCycle            = ""
        //        if billingIndex != -1{
        //            billingCycle            = billingData[billingIndex].title ?? ""
        //        }
        billingCycle = selectedBilling?.title ?? "".lowercased()
        let paymentMethod           = selectedPayment?.id ?? ""
        var paymentMethodDataId     = ""
        var paymentMethodDataName   = ""
        if cardIndex != -1 && isCards == true {
            paymentMethodDataId     = cardsData[cardIndex].id
            paymentMethodDataName   = "\(cardsData[cardIndex].title ?? "")****\(cardsData[cardIndex].subtitle ?? "")"
        }
        let category                = selectedCategory?.id ?? ""
        let subscriptionFor         = Constants.getUserId()
        let subscriptionForName     = "Me"
        var renewalReminder         :[String] = []
        var renewalReminderValue = ""
        for item in remindersData
        {
            if item.isSelected ?? false == true
            {
                renewalReminder.append(item.value!)
                if renewalReminderValue != "" {
                    renewalReminderValue = "\(renewalReminderValue)\n\(item.title ?? "")"
                }
                else{
                    renewalReminderValue = item.title ?? ""
                }
            }
        }
        
        let input = AddSubscriptionRequest(userId               : Constants.getUserId(),
                                           serviceName          : serviceName.trimmed,
                                           amount               : Double(amount.trimmed) ?? 0.0,
                                           currency             : selectedCurrency?.code ?? "",
                                           billingCycle         : billingCycle,
                                           nextPaymentDate      : chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd"),
                                           subscriptionType     : planType.trimmed,
                                           paymentMethod        : paymentMethod,
                                           paymentMethodDataId  : paymentMethodDataId,
                                           category             : category,
                                           subscriptionFor      : subscriptionFor,
                                           renewalReminder      : renewalReminder,
                                           notes                : notes.trimmed,
                                           currencySymbol       : selectedCurrency?.symbol ?? "")
        
        let editInput = EditSubscriptionRequest(userId               : Constants.getUserId(),
                                                subscriptionId       : subscriptionId,
                                                serviceName          : serviceName.trimmed,
                                                amount               : Double(amount.trimmed) ?? 0.0,
                                                currency             : selectedCurrency?.code ?? "",
                                                billingCycle         : billingCycle,
                                                nextPaymentDate      : chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd"),
                                                subscriptionType     : planType.trimmed,
                                                paymentMethod        : paymentMethod,
                                                paymentMethodDataId  : paymentMethodDataId,
                                                category             : category,
                                                subscriptionFor      : subscriptionFor,
                                                renewalReminder      : renewalReminder,
                                                notes                : notes.trimmed,
                                                currencySymbol       : selectedCurrency?.symbol ?? "")
        
        if let errorMessage = ManualEntryValidations.shared.manualEntry(input: input) {
            ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
        } else {
            if isFromListEdit{
                addSubscriptionVM.editSubscription(input: editInput)
            }
            else if isFromEdit == true
            {
                
                globalSubscriptionData?.serviceName = serviceName.trimmed
                globalSubscriptionData?.amount = Double(amount.trimmed) ?? 0.0
                globalSubscriptionData?.currency = selectedCurrency?.code ?? ""
                globalSubscriptionData?.currencySymbol = selectedCurrency?.symbol ?? ""
                globalSubscriptionData?.subscriptionType = planType.trimmed
                globalSubscriptionData?.nextPaymentDate = chargeDate//.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                globalSubscriptionData?.billingCycle = billingCycle.lowercased()
                globalSubscriptionData?.categoryId = category
                globalSubscriptionData?.categoryName = selectedCategory?.name ?? ""
                globalSubscriptionData?.paymentMethodId = paymentMethod
                globalSubscriptionData?.paymentMethodName = selectedPayment?.name ?? ""
                globalSubscriptionData?.paymentMethodDataId = paymentMethodDataId
                globalSubscriptionData?.paymentMethodDataName = paymentMethodDataName
                globalSubscriptionData?.subscriptionFor = subscriptionFor
                globalSubscriptionData?.subscriptionForName = subscriptionForName
                globalSubscriptionData?.notes = notes.trimmed
                globalSubscriptionData?.renewalReminder = renewalReminder
                globalSubscriptionData?.renewalReminderValue = renewalReminderValue
                self.goBack()
            }
            else{
                addSubscriptionVM.addSubscription(input: input)
            }
        }
    }
    
    private func handleDone() {
        switch activeField {
        case .serviceName:
            fetchProviderDataApi()
        case .planType:
            autoFillDetails()
        case .amount:
            autoFillDetails(isAmount: true)
        case .none:
            break
        }
    }
}

//MARK: - SecureCCVField
struct SecureCCVField: View
{
    @Binding var ccv    : String
    var title           : String?
    var placeHolder     : String?
    var maxDigits       : Int = 3
    
    var masked: String {
        String(repeating: "•", count: ccv.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
            HStack{
                
                SecureField(placeHolder ?? "", text: $ccv)
                    .keyboardType(.numberPad)
                    .padding(6)
                    .textContentType(.oneTimeCode)
                    .disableAutocorrection(true)
                    .onChange(of: ccv) { newValue in
                        filterDigitsAndLimit(maxDigits: maxDigits)
                    }
                    .font(.appRegular(14))
                    .foregroundColor(.neutral2500)
                
            }
            .padding(16)
            .frame(height: 52)
            .background(.whiteNeutralCardBG)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral2200, lineWidth: 1)
            )
        }
    }
    
    private func filterDigitsAndLimit(maxDigits: Int) {
        // keep digits only and limit length
        let digitsOnly = ccv.filter { $0.isNumber }
        if digitsOnly.count > maxDigits {
            ccv = String(digitsOnly.prefix(maxDigits))
        } else {
            ccv = digitsOnly
        }
    }
}

//MARK: - FieldView
struct FieldView: View
{
    @Binding var text   : String
    var textValue       : String?
    var title           : String?
    var image           : String?
    var placeHolder     : String?
    var isButton        : Bool    = false
    var isText          : Bool    = false
    var maxDigits       : Int = 0
    var isNumberPad     : Bool = false
    var maxCharacters   : Int = 0
    var isDate          = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
            HStack{
                Image(image ?? "")
                if isText == true {
                    if isDate{
                        if text != ""
                        {
                            Text(text)
                                .padding(6)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(Color.neutralMain700)
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                        else{
                            Text(placeHolder ?? "")
                                .padding(6)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(Color.neutral2500)
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                    }else{
                        if textValue != ""
                        {
                            Text(textValue ?? "")
                                .padding(6)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(Color.neutralMain700)
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                        else{
                            Text(placeHolder ?? "")
                                .padding(6)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(Color.neutral2500)
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                    }
                }
                else{
                    if isNumberPad{
                        HStack{
                            if maxDigits == 4{
                                Text("**** **** ****")
                                    .foregroundColor(.whiteBlackBGnoPic)
                            }
                            TextField(maxDigits == 4 ? "" : placeHolder ?? "", text: $text)
                                .keyboardType(isNumberPad == true ? .decimalPad : .default)
                                .keyboardType(.default)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(.whiteBlackBGnoPic)
                                .onChange(of: text) { newValue in
                                    //                                    filterDigitsAndLimit(maxDigits: maxDigits)
                                    validateDecimalInput(maxDigits: maxDigits, maxDecimalPlaces: 2)
                                }
                        }
                        .padding(6)
                    }else{
                        HStack{
                            if maxDigits == 4{
                                Text("**** **** ****")
                                    .foregroundColor(.whiteBlackBGnoPic)
                            }
                            TextField(maxDigits == 4 ? "" : placeHolder ?? "", text: $text)
                                .keyboardType(isNumberPad == true ? .numberPad : .default)
                                .keyboardType(.default)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(.whiteBlackBGnoPic)
                                .onChange(of: text) { newValue in
                                    filterDigitsAndLimit(maxDigits: maxDigits)
                                }
                        }
                        .padding(6)
                    }
                }
                if isButton == true
                {
                    Image("downArrow")
                }
            }
            .padding(16)
            .frame(height: 52)
            //            .overlay(
            //                RoundedRectangle(cornerRadius: 12)
            //                    .stroke(Color.neutral2200, lineWidth: 1)
            //            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.neutral300Border, lineWidth: 1)
            )
            .background(Color.whiteNeutralCardBG)
            .cornerRadius(12)
        }
        .padding(5)
    }
    
    private func filterDigitsAndLimit(maxDigits: Int) {
        // keep digits only and limit length
        if maxDigits > 0
        {
            let digitsOnly = text.filter { $0.isNumber }
            if digitsOnly.count > maxDigits {
                text = String(digitsOnly.prefix(maxDigits))
            } else {
                text = digitsOnly
            }
        }
    }
    
    private func validateDecimalInput(maxDigits: Int, maxDecimalPlaces: Int = 2) {
        var value = text
        value = value.filter { $0.isNumber || $0 == "." }
        if value.filter({ $0 == "." }).count > 1 {
            var result = ""
            var dotFound = false
            for char in value {
                if char == "." {
                    if !dotFound {
                        dotFound = true
                        result.append(char)
                    }
                } else {
                    result.append(char)
                }
            }
            value = result
        }
        if let dotIndex = value.firstIndex(of: ".") {
            let before = value[..<dotIndex]
            let after  = value[value.index(after: dotIndex)...]
            let limitedAfter = after.prefix(maxDecimalPlaces)
            value = String(before) + "." + String(limitedAfter)
        }
        text = value
    }
}

//struct FieldSuggestionView: View
//{
//    @Binding var text   : String
//    var title           : String?
//    var image           : String?
//    var placeHolder     : String?
//    var isNumberPad     : Bool = false
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(LocalizedStringKey(title ?? ""))
//                .font(.appRegular(14))
//                .foregroundColor(.neutralMain700)
//            HStack{
//                Image(image ?? "")
//                TextField(placeHolder ?? "", text: $text)
//                    .keyboardType(isNumberPad == true ? .numberPad : .default)
//                    .keyboardType(.default)
//                    .autocapitalization(.none)
//                    .multilineTextAlignment(.leading)
//                    .font(.appRegular(14))
//                    .foregroundColor(.whiteBlackBGnoPic)
//            }
//            .padding(16)
//            .frame(height: 52)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(.neutral300Border, lineWidth: 1)
//            )
//            .background(Color.whiteNeutralCardBG)
//            .cornerRadius(12)
//        }
//        .padding(5)
//    }
//}

//MARK: - Field suggestions view
struct FieldSuggestionView<Item: Identifiable>: View {
    
    @Binding var text   : String
    var title           : String?
    var image           : String?
    var placeHolder     : String?
    var currency        : String?
    var isNumberPad     : Bool = false
    var suggestions     : [Item]
    var displayKey      : (Item) -> String
    
    @FocusState private var isFocused   : Bool
    
    var fieldType                       : FieldType
    @Binding var activeField            : FieldType?
    
    @State private var showSuggestions  : Bool = false
    
    private var filtered: [Item] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }
        return suggestions.filter { displayKey($0).lowercased().contains(query) }
    }
    
    let action          : () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // MARK: - Title
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
            
            // MARK: - TextField Area
            HStack {
                if isNumberPad{
                    Text(currency ?? "" == "" ? Constants.shared.currencySymbol : currency ?? "")
                        .foregroundStyle(Color.neutral400)
                        .font(.appRegular(24))
                }else{
                    Image(image ?? "")
                }
                TextField(placeHolder ?? "", text: $text)
                    .keyboardType(isNumberPad ? .decimalPad : .default)
                    .autocapitalization(.none)
                    .font(.appRegular(14))
                    .foregroundColor(.whiteBlackBGnoPic)
                    .focused($isFocused)
                    .onChange(of: text) { _ in
                        showSuggestions = isFocused && !filtered.isEmpty
                    }
                //                    .onChange(of: isFocused) { focused in
                //                        showSuggestions = focused && !filtered.isEmpty
                //                    }
                    .onChange(of: isFocused) { focused in
                        if focused {
                            activeField = fieldType
                        }
                        showSuggestions = focused && !filtered.isEmpty
                    }
                    .onSubmit {
                        closeSuggestions()
                    }
                    .padding(6)
            }
            .padding(16)
            .frame(height: 52)
            .background(Color.whiteNeutralCardBG)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.neutral300Border, lineWidth: 1)
            )
            .cornerRadius(12)
            
            // MARK: - Suggestion List
            if showSuggestions {
                suggestionList
                    .padding(.top, 10)
                    .padding(.bottom, -10)
            }
        }
        .padding(5)
    }
    
    // MARK: Suggestion List View
    private var suggestionList: some View {
        let minHeight = CGFloat(filtered.count * 50)
        let height    = min(max(minHeight, 50), 250)
        
        return VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 0) {
                            HStack {
                                Text(displayKey(item))
                                    .foregroundColor(.neutralMain700)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                text = displayKey(item)
                                closeSuggestions()
                            }
                            if index < filtered.count - 1 {
                                DashedHorizontalDivider()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
            .frame(height: height)
            .clipped()
        }
        .padding(.horizontal, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.neutral2200, lineWidth: 1)
        )
        .background(Color.whiteNeutralCardBG)
        .cornerRadius(12)
    }
    
    //    private func closeSuggestions() {
    //        DispatchQueue.main.async {
    //            isFocused = false
    //            showSuggestions = false
    //            action()
    //        }
    //    }
    
    private func closeSuggestions() {
        DispatchQueue.main.async {
            isFocused = false
            showSuggestions = false
            activeField = nil
            action()
        }
    }
}

//MARK: - ListView
struct ListView: View {
    var type                    : ListType = .billing
    var title                   : String?
    var addMore                 : Bool = false
    @Binding var data           : [ManualDataInfo]
    @Binding var selectedIndex  : Int
    @State private var showNewCardSheet    = false
    var onDismiss: (() -> Void)?
    @State private var shouldCallAPI = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
                .padding(.bottom, 4)
                .frame(maxWidth:.infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 0) {
                List {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, objc in
                        VStack(spacing: 0) {
                            rowView(for: objc, at: index)
                            
                            if index < data.count - 1 {
                                Divider()
                                    .overlay(Color.neutral2200)
                            }
                            
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollDisabled(true)
                .listStyle(.plain)
                .frame(maxWidth: .infinity)
                .scrollContentBackground(.hidden)
                .frame(height: CGFloat((52 * data.count)))
                
                if addMore == true
                {
                    Divider()
                        .overlay(Color.neutral2200)
                    VStack(alignment: .center, spacing: 0) {
                        Button(action: addMoreAction) {
                            HStack(spacing: 8) {
                                Image("AddMore")
                                    .frame(width: 20, height: 20)
                                Text(type == .cards ? "Add New Card" : "Add New Member")
                                    .font(.appRegular(14))
                                    .foregroundColor(Color.blueMain700)
                            }
                            .frame(maxWidth:.infinity, alignment: .center)
                            .frame(height: 52)
                        }
                        .sheet(isPresented: $showNewCardSheet,onDismiss:{
                            if shouldCallAPI {
                                onDismiss?()
                                shouldCallAPI = false
                            }
                        }) {
                            AddNewCardSheet(shouldCallAPI:$shouldCallAPI)
                                .presentationDetents([.height(500), .large])
                                .presentationDragIndicator(.hidden)
                        }
                        //                        .onChange(of: showNewCardSheet) { newValue in
                        //                            if newValue == false {
                        //                                onDismiss?()
                        //                            }
                        //                        }
                    }
                }
            }
            //            .overlay(
            //                RoundedRectangle(cornerRadius: 12)
            //                    .stroke(Color.neutral2200, lineWidth: 1)
            //            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.neutral300Border, lineWidth: 1)
            )
            .background(Color.whiteNeutralCardBG)
            .cornerRadius(16)
        }
        .padding(5)
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showNewCardSheet = false
        }
    }
    
    // MARK: - Extracted subview
    @ViewBuilder
    private func rowView(for objc: ManualDataInfo, at index: Int) -> some View {
        if type == .billing {
            BillingCycleItem(title: objc.title ?? "", subtitle: objc.subtitle ?? "", isSelected: index == selectedIndex ? true : false)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
        if type == .cards {
            SubscriptionItem(title: objc.title ?? "", subtitle: objc.subtitle ?? "", isSelected: index == selectedIndex ? true : false, isSubTitlePresent: true)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
        if type == .relations {
            SubscriptionItem(title: objc.title ?? "", subtitle: objc.subtitle ?? "", isSelected: index == selectedIndex ? true : false)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
        if type == .reminders {
            ReminderItem(title: objc.title ?? "", isSelected: objc.isSelected ?? false)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
    }
    
    // MARK: - Button actions
    private func selectedAction(at index: Int) {
        selectedIndex = index
        if type == .reminders {
            var obj = data[index]
            if (obj.isSelected ?? false ) == true
            {
                obj.isSelected = false
            }
            else{
                obj.isSelected = true
            }
            data[index] = obj
        }
    }
    
    private func addMoreAction() {
        if type == .cards
        {
            showNewCardSheet = true
        }
    }
}

//MARK: - BillingCycleItem
struct BillingCycleItem: View {
    var title           : String?
    var subtitle        : String?
    var isSelected      : Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(isSelected == true ? "SelectedRadio" : "UnSelectedRadio")
                Text(title ?? "")
                    .font(.appRegular(14))
                    .foregroundColor(.neutralMain700)
            }
            Spacer()
            Text(subtitle ?? "")
                .font(.appRegular(14))
                .foregroundColor(.neutral500)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
        .frame(height: 52)
        .background(.whiteNeutralCardBG)
    }
}

//MARK: - SubscriptionItem
struct SubscriptionItem: View {
    var title                   : String?
    var subtitle                : String?
    var isSelected              : Bool = false
    var isSubTitlePresent       : Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(isSelected == true ? "SelectedRadio" : "UnSelectedRadio")
            Text(title ?? "")
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
            if isSubTitlePresent == true {
                Text("**** **** **** \(subtitle ?? "")")
                    .font(.appRegular(14))
                    .foregroundColor(.neutral500)
                    .multilineTextAlignment(.trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 52)
        .background(.whiteNeutralCardBG)
    }
}

//MARK: - ReminderItem
struct ReminderItem: View {
    var title                   : String?
    var isSelected              : Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(isSelected == true ? "Checkmark" : "UnCheckmark")
            Text(title ?? "")
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 52)
        .background(.whiteNeutralCardBG)
    }
}

//MARK: - OriginalImageView
struct OriginalImageView: View {
    @Environment(\.dismiss) private var dismiss
    var image: UIImage
    
    // Calculate the aspect ratio height for available width
    private func imageHeight(for width: CGFloat) -> CGFloat {
        let aspectRatio = image.size.height / image.size.width
        return width * aspectRatio
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Capsule()
                    .fill(Color.grayCapsule)
                    .frame(width: 150, height: 5)
                    .padding(.vertical, 24)
                
                VStack(alignment: .center, spacing: 8) {
                    Text(LocalizedStringKey("Review Original Image"))
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                }
                .padding(.bottom, 24)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width - 40,
                           height: min(imageHeight(for: geometry.size.width - 40),geometry.size.height - 200))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.bottom, 16)
                
                Spacer()
            }
            .padding(.bottom,20)
            .padding(.horizontal, 20)
        }
    }
}
