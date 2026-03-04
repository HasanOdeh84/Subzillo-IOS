//
//  ManualEntryView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/11/25.
//

/*//Manual entry cases
 1. When the plan type is changed, both the amount and Billing cycle and currency and currency symbol (If plans are not related to the selected currency, then we will get other country plans then currency will change accordingly.) should be updated accordingly either empty or not empty.
 2. When billing cycle is updated, then next charge date and amount should be updated accordingly.
 3. When the amount is changed, both the plan type and the billing cycle and currency and currency symbol (If plans are not related to the selected currency, then we will get other country plans then currency will change accordingly.) should be updated accordingly if plan type is empty.
 4. If there are no plans for particular service, the available plan types are Free Plan and Basic Plan. When the user selects either one, the billing cycle should be displayed as Monthly by default.
 5. If Plan type is free then amount should be 0 in manual and review screens.
 6. If service name is empty or if service name changes then need to clear the data and need to clear the provider list.
 7. If currency is changed no need to clear the data.
 8. Amount suggestions and billing cycles list will be filtered based on plan type.
 */

import SwiftUI
import UIKit

var isCurrencyUpdateGlobalManual                = false

struct ManualEntryView: View {
    
    //MARK: - Properties
    var isFromEdit                              = false
    var isFromListEdit                          = false
    var isRenew                                 = false
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
    @StateObject var subscriptionMatchVM        = SubscriptionMatchViewModel()
    @State private var serviceName              : String = ""
    @State private var amount                   : String = ""
    @State private var currency                 : String = ""
    @State private var planType                 : String = ""
    @State private var chargeDate               : String = ""
    @State private var initialRenewDate         : String = ""
    @State private var category                 : String = ""
    @State private var paymentMethod            : String = ""
    @State private var notes                    : String = ""
    @State private var isDatePickerPresented    = false
    @State private var tempDate                 = Date()
    @State private var cardIndex                : Int = -1
    @State var relationIndex                    : Int = 0
    @State private var reminderInedex           : Int = -1
    @State private var isMoreEnable             : Bool = false
    var subscriptionId                          = ""
    @State var fromSiri                         = false
    @Environment(\.dismiss) private var dismiss
    @State var isInitialCategory                = true
    @State var isInitial                        = true
    @State var isInitialPayment                 = true
    @State private var billingCycle             : String = ""
    @State var selectedBilling                  : String?
    @State private var showBillingCycleSheet    = false
    @State private var billingData              = [
        ManualDataInfo(id: "1", title: "Daily".localized, subtitle: "Every 24 hours".localized),
        ManualDataInfo(id: "2", title: "Weekly".localized, subtitle: "Every 7 Days".localized),
        ManualDataInfo(id: "3", title: "Monthly".localized, subtitle: "Every 30 Days".localized),
        ManualDataInfo(id: "4", title: "Quarterly".localized, subtitle: "Every 90 Days".localized),
        ManualDataInfo(id: "5", title: "Biannually".localized, subtitle: "Every 180 Days".localized),
        ManualDataInfo(id: "6", title: "Yearly".localized, subtitle: "Every 360 Days".localized)
    ]
    @State private var billingIndex             : Int = -1
    @State private var cardsData                : [ManualDataInfo] = []
    @State private var relationsData            = [
        ManualDataInfo(id: Constants.getUserId(), title: "Me".localized)
    ]
    @State private var remindersData            = [
        ManualDataInfo(id: "1", title: "3 days before renewal".localized, value: "-3d"),
        ManualDataInfo(id: "2", title: "1 day before renewal".localized, value: "-1d"),
        ManualDataInfo(id: "3", title: "On renewal day".localized, value:"0d")
    ]
    @State var isPlanTypeError                  : Bool = false
    @State var isAmountError                    : Bool = false
    @State private var activeField              : FieldType?
    @State private var showPlanTypeSheet        = false
    @State var selectedPlanType                 : String?
    var familyMemberId                          = ""
    @State private var sheetHeight              : CGFloat = .zero
    @State private var sheetID                  = UUID()
    @State private var serviceLastActionText    : String = ""
    @State private var planLastActionText       : String = ""
    @State private var amountLastActionText     : String = ""
    @State private var pendingUIAction          : PendingUIAction? = nil
    @State var isCurrency                       = false
    @State var isCurrencyUpdate                 = false
    var isFromEmail                             : Bool = false
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            // MARK: Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: Title
                    Text(LocalizedStringKey(isFromEdit == true ? "Edit Details" : "Manual Entry"))
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    // MARK: SubTitle
                    Text(LocalizedStringKey(isFromEdit == true ? "Update your details" : "Add your subscription details manually."))
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
                        .padding(.leading, 5)
                    
                    //MARK: Service field
                    
                    FieldSuggestionView1(
                        text        : $serviceName,
                        title       : "Service Name",
                        image       : "gridIcon",
                        placeHolder : "e.g. Netflix, Spotify, Adobe",
                        suggestions : addSubscriptionVM.servicesList ?? [],
                        displayKey  : { $0.name ?? "" },
                        fieldType   : FieldType.serviceName,
                        activeField : $activeField,
                        //                        lastActionText : $serviceLastActionText,
                        action      : {
                            if serviceName != ""{
                                if serviceName.trimmed != serviceLastActionText{
                                    serviceLastActionText = serviceName.trimmed
                                    fetchProviderDataApi()
                                }
                            }else{
                                clearData()
                            }
                        }
                    )
                    .allowsHitTesting(!isRenew)
                    .opacity(isRenew ? 0.6 : 1.0)
                    
                    //MARK: PlanType field
                    Button(action: selectPlanType) {
                        FieldView(text: $planType, textValue: selectedPlanType ?? "", title: "Plan Type", image: "gridicon2", placeHolder: "Please select", isButton: true, isText: true)
                    }
                    .sheet(isPresented: $showPlanTypeSheet) {
                        PlanTypeBottomSheet(selectedPlanType    : $selectedPlanType,
                                            planTypeResponse    : filteredPlanTypes(),
                                            header              : "Select Plan Type",
                                            placeholder         : "Search Plan Type",
                                            action              : {
                            planLastActionText = selectedPlanType ?? ""
                            planType = selectedPlanType ?? ""
                            autoFillDetails(isAmount: false)
                        })
                        .onAppear {
                            DispatchQueue.main.async {
                                sheetHeight = sheetHeight
                            }
                        }
                        .id(sheetID)
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
                        .interactiveDismissDisabled(false)
                    }
                    
                    HStack(spacing: 24) {
                        //MARK: Amount field
                        VStack{
                            FieldSuggestionView1(
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
                                //                                lastActionText : $amountLastActionText,
                                action      : {
                                    autoFillDetails(isAmount: true)
                                }
                            )
                            .addDoneButton{
                            }
                            Spacer()
                        }
                        
                        //MARK: currency field
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
                                                     placeholder        : "Search currency",
                                                     action             : {
                                    self.handleCurrencySelection()
                                })
                                .presentationDetents([.large])
                                .presentationDragIndicator(.hidden)
                            }
                            Spacer()
                        }
                        //                        .onChange(of: selectedCurrency) { newCurrency in
                        //                            guard let currency = newCurrency else { return }
                        //                            //                            if isCurrencyUpdateGlobalManual{
                        //                            //                                isCurrencyUpdateGlobalManual = false
                        //                            //                            }else{
                        //                            //                                if serviceName != ""{
                        //                            //                                    if isFromEdit && isInitial{
                        //                            //                                        isInitial = false
                        //                            //                                    }else{
                        //                            //                                        isCurrency = true
                        //                            //                                    }
                        //                            //                                    fetchProviderDataApi()
                        //                            //                                }
                        //                            //                            }
                        //                            handleCurrencySelection()
                        //                        }
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
                        .padding(.top, -29)
                    }
                    
                    //MARK: Category field
                    Button(action: selectCategory) {
                        FieldView(text: $category, textValue: selectedCategory?.name ?? category, title: "Category", image: "gridIcon", placeHolder: "Please select", isButton: true, isText: true)
                    }
                    .allowsHitTesting(!isRenew)
                    .opacity(isRenew ? 0.6 : 1.0)
                    .sheet(isPresented: $showCategorySheet) {
                        CategoriesBottomSheet(selectedCategory: $selectedCategory, categoryResponse:commonApiVM.categoriesResponse, header: "Select Category", placeholder: "Search Category")
                            .presentationDetents([.large])
                            .presentationDragIndicator(.hidden)
                    }
                    
                    //MARK: Billing cycle field
                    Button(action: selectBilling) {
                        FieldView(text: $billingCycle, textValue: selectedBilling ?? "", title: "Billing Cycle", image: "billing", placeHolder: "Select billing cycle", isButton: true, isText: true)
                    }
                    .sheet(isPresented: $showBillingCycleSheet) {
                        BillingCycleBottomSheet(selectedBilling         : $selectedBilling,
                                                billingCyclesResponse   : filteredBillingCycles(),
                                                header                  : "Select Billing Cycle",
                                                placeholder             : "Search billing cycle",
                                                onSelect: { billing in
                            //amount should be changed based on the billing cycle
                            self.updateAmount(billing: billing)
                        })
                        .onAppear {
                            DispatchQueue.main.async {
                                sheetHeight = sheetHeight
                            }
                        }
                        .id(sheetID)
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
                    .onChange(of: selectedBilling) { billing in
                        guard let billing else { return }
                        
                        if isFromEdit && isInitialPayment {
                            isInitialPayment = false
                            return
                        }
                        if billing != ""{
                            chargeDate = Constants.shared.getNextDateByFrequency(
                                frequency: billing
                            )
                        }
                    }
                    
                    //MARK: Next Charge Date field
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
                    
                    //MARK: Optional Details
                    Button(action: optionalDetailsAction) {
                        HStack(spacing: 8) {
                            Text("Optional Details")
                                .font(.appRegular(18))
                                .foregroundColor(.whiteBlackBGnoPic)
                                .lineLimit(1)
                                .layoutPriority(1)
                                .padding(.leading, 5)
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
                                .presentationDetents([.large])
                                .presentationDragIndicator(.hidden)
                        }
                        .onChange(of: selectedPayment) { newValue in
                            guard let newValue = newValue else { return }
                            isCards = newValue.status ?? false
                            paymentMethod = newValue.name!
                        }
                        if isCards == true {
                            ListView(type: .cards, title: "Which card is linked to this subscription?", addMore: true, data: $cardsData, selectedIndex: $cardIndex,onDismiss: {
                                addSubscriptionVM.listUserCards(input: ListUserCardsRequest(userId: Constants.getUserId()))
                            } )
                            .frame(height: Double(75 + (52 * cardsData.count)))
                        }
                        
                        ListView(type           : .relations,
                                 title          : "Who will benefit from this subscription?",
                                 addMore        : canAddMembers,
                                 data           : $relationsData,
                                 selectedIndex  : $relationIndex,
                                 onAddFamily    : {nickName, phone, countryCode, colorHex in
                            let input = AddFamilyMemberRequest(userId       : Constants.getUserId(),
                                                               nickName     : nickName.trimmed,
                                                               phoneNumber  : phone,
                                                               countryCode  : countryCode,
                                                               color        : colorHex)
                            addSubscriptionVM.addfamilyMember(input: input)
                        })
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
                    CustomButton(title: isFromEdit == true ? "Save Changes" : "Save Subscription", action: saveAction)
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
        //MARK: OnAppear
        .onAppear{
            addSubscriptionVM.getServiceProvidersList()
            updateSubDetailsTOView()
            commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
            commonApiVM.getCategories()
            commonApiVM.getPaymentMethods()
            addSubscriptionVM.listUserCards(input: ListUserCardsRequest(userId: Constants.getUserId()))
            addSubscriptionVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
            updateCountryAndCurrency()
            if isFromEdit{
                if !serviceName.isEmpty{
                    fetchProviderDataApi()
                }
            }
        }
        .onChange(of: addSubscriptionVM.providerData) { _ in updateProviderData() }
        .onChange(of: commonApiVM.paymentMethodResponse) { _ in updatePaymentInfo() }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
        .onChange(of: commonApiVM.userInfoResponse) { _ in updateUserInfo() }
        .onChange(of: addSubscriptionVM.listFamilyMembersResponse?.familyMembers) { _ in updateRelationInfo() }
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
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: addSubscriptionVM.isAddFamilyMember) { value in
            if value{
                addSubscriptionVM.listFamilyMembers(input: ListFamilyMembersRequest(userId: Constants.getUserId()))
            }
        }
        .onChange(of: subscriptionMatchVM.isRenewSuccess) { value in
            if value{
                goBack()
            }
        }
    }
    
    //MARK: - User defined methods
    
    func fetchProviderDataApi(){
        addSubscriptionVM.fetchProviderData(input: FetchProviderDataRequest(userId          : Constants.getUserId(),
                                                                            serviceName     : serviceName.trimmed,
                                                                            currencyCode    : selectedCurrency?.code ?? "" == "" ? Constants.shared.currencyCode : selectedCurrency?.code ?? ""))
    }
    
    func filteredPricePlans() -> [ProviderSubscriptionPlan] {
        guard let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList else {
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
            let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList,
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
    
    func filteredBillingCycles() -> [String] {
        guard
            let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList,
            !plans.isEmpty
        else {
            // Fallback when API returns no plans
            return ["Monthly", "Yearly"]
        }
        
        let filteredPlans: [ProviderSubscriptionPlan]
        if let selected = selectedPlanType, !selected.isEmpty {
            filteredPlans = plans.filter { ($0.planName ?? "").caseInsensitiveCompare(selected) == .orderedSame }
        } else {
            filteredPlans = plans
        }
        
        let billingCycleNames = filteredPlans.compactMap { $0.billingCycle }
        
        // If plan names are missing or empty, still return fallback
        guard !billingCycleNames.isEmpty else {
            return ["Monthly", "Yearly"]
        }
        
        return Array(Set(billingCycleNames))
    }
    
    private func handleCurrencySelection() {
        if isCurrencyUpdateGlobalManual {
            isCurrencyUpdateGlobalManual = false
            return
        }
        guard !serviceName.isEmpty else { return }
        //        if isFromEdit && isInitial {
        //            isInitial = false
        //        } else {
        ////            isCurrency = true
        //        }
        isCurrency = true
        fetchProviderDataApi()
    }
    
    private func updateProviderData() {
        activeField = nil
        let pending = pendingUIAction
        pendingUIAction = nil
        
        if isFromEdit && isInitialCategory{
            isInitialCategory = false
        }else{
            if addSubscriptionVM.providerData?.categoryName ?? "" != "" && addSubscriptionVM.providerData?.categoryId ?? "" != ""{
                if let categories = commonApiVM.categoriesResponse {
                    selectedCategory = categories.first(where: { $0.id?.lowercased() == addSubscriptionVM.providerData?.categoryId ?? ""})
                }
            }
            if isCurrency{
                isCurrency = false
            }else{
                planType = ""
                selectedPlanType = ""
                amount = ""
                selectedBilling = ""
                chargeDate = ""
            }
        }
        
        if let pendingAction = pending {
            executePendingUIAction(pendingAction)
        }
    }
    
    private func executePendingUIAction(_ action: PendingUIAction) {
        switch action {
        case .selectPlanType:
            sheetID = UUID()
            showPlanTypeSheet = true
        case .selectBilling:
            sheetID = UUID()
            showBillingCycleSheet = true
        case .selectCategory:
            showCategorySheet = true
        case .selectpaymentMethod:
            showPaymentMethodSheet = true
        case .dateSelection:
            withAnimation(.easeInOut) {
                isDatePickerPresented = true
            }
        }
    }
    
    func clearData(){
        planType = ""
        selectedPlanType = ""
        amount = ""
        selectedBilling = ""
        chargeDate = ""
        selectedCategory = nil
        category = ""
        addSubscriptionVM.providerData = nil
        serviceLastActionText = ""
    }
    
    func updateAmount(billing:String){
        guard
            !billing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList
        else {
            return
        }
        
        if let matchedPlan = plans.first(where: { plan in
            let cycleMatch = (plan.billingCycle ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare(
                    billing.trimmingCharacters(in: .whitespacesAndNewlines)
                ) == .orderedSame
            
            if let selected = selectedPlanType, !selected.isEmpty {
                return cycleMatch && (plan.planName ?? "").caseInsensitiveCompare(selected) == .orderedSame
            }
            return cycleMatch
        }) {
            amount = String(format: "%.2f", matchedPlan.price ?? 0)
            amountLastActionText = amount
            updateCurrency(currencyCode     : matchedPlan.currencyCode ?? Constants.shared.regionCode,
                           currencySymbol   : matchedPlan.currencySymbol ?? Constants.shared.currencySymbol)
        }
    }
    
    private func autoFillDetails(isAmount:Bool = false){
        activeField = nil
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
                    planLastActionText = planType
                    selectedPlanType = matchedPlan.planName ?? ""
                    selectedBilling = matchedPlan.billingCycle ?? ""
                }
                isAmountError = false
                updateCurrency(currencyCode     : matchedPlan.currencyCode ?? Constants.shared.regionCode,
                               currencySymbol   : matchedPlan.currencySymbol ?? Constants.shared.currencySymbol)
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
                //For first-time users, the available plan types are Free Plan and Basic Plan. When the user selects either one, the billing cycle should be displayed as Monthly by default.
                if planType == "Free" || planType == "Basic"{
                    selectedBilling = "Monthly"
                }
                if planType == "Free"{
                    amount = "0.0"
                }
                
                return
            }
            if let matchedPlan = plans.first(where: {
                ($0.planName ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .caseInsensitiveCompare(
                        planType.trimmingCharacters(in: .whitespacesAndNewlines)
                    ) == .orderedSame
            }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    amount = String(format: "%.2f", matchedPlan.price ?? 0)
                    amountLastActionText = amount
                }
                selectedBilling = matchedPlan.billingCycle ?? ""
                isPlanTypeError = false
                updateCurrency(currencyCode     : matchedPlan.currencyCode ?? Constants.shared.regionCode,
                               currencySymbol   : matchedPlan.currencySymbol ?? Constants.shared.currencySymbol)
            } else {
                if planType == "Free" || planType == "Basic"{
                    selectedBilling = "Monthly"
                }
                if planType == "Free"{
                    amount = "0.0"
                }
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
                    AppIntentRouter.shared.navigate(to: .duplicateSubscriptionsView(duplicateSubsList: updatedDuplicates, fromFamily: familyMemberId == "" ? false : true, isFromEmail: isFromEmail))
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
                        if familyMemberId == ""{
                            AppIntentRouter.shared.navigate(to: .subscriptionsListView())
                        }else{
                            dismiss()
                        }
                    }
                }
            }
            else{
                if isFromListEdit{
                    dismiss()
                }else{
                    if familyMemberId == ""{
                        AppIntentRouter.shared.navigate(to: .subscriptionsListView())
                    }else{
                        dismiss()
                    }
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
                    isCards = selectedPayment?.status ?? false
                    paymentMethod = selectedPayment?.name ?? ""
                }else{
                    paymentMethod = globalSubscriptionData?.paymentMethodName ?? ""
                }
            }
        }
    }
    
    private func updateCatInfo() {
        if isFromEdit == true
        {
            //            if globalSubscriptionData?.categoryId ?? "" != "" {
            //                if let categories = commonApiVM.categoriesResponse {
            //                    selectedCategory = categories.first(where: { $0.id == globalSubscriptionData?.categoryId ?? ""})
            //                }
            //            }
            if let categories = commonApiVM.categoriesResponse,
               let categoryName = globalSubscriptionData?.categoryName {
                selectedCategory = categories.first {
                    $0.name == categoryName
                }
                if selectedCategory == nil {
                    selectedCategory = Category(id: nil, name: categoryName)
                }
            }else{
                selectedCategory = Category(id: nil, name: globalSubscriptionData?.categoryName)
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
        //        if commonApiVM.userInfoResponse?.tierName?.lowercased() == "family plan"
        //        {
        //            let familyMembersLimit = commonApiVM.userInfoResponse?.familyMembersLimit ?? 0
        //            if familyMembersLimit > relationsData.count - 1
        //            {
        //                canAddMembers = true
        //            }
        //        }
        if addSubscriptionVM.listFamilyMembersResponse?.remainingFamilyMembersLimit ?? 0 > 0{
            canAddMembers = true
        }else{
            canAddMembers = false
        }
        updateCountryAndCurrency()
    }
    
    func updateRelationInfo()
    {
        relationsData.removeAll()
        relationsData.append(ManualDataInfo(id: Constants.getUserId(), title: "Me".localized))
        if let familyCards = addSubscriptionVM.listFamilyMembersResponse?.familyMembers {
            for family in familyCards {
                relationsData.append(
                    ManualDataInfo(
                        id      : family.id ?? "",
                        title   : family.nickName
                    )
                )
            }
            updateUserInfo()
            if familyMemberId != ""{
                if let index = relationsData.firstIndex(where: { $0.id == familyMemberId }) {
                    relationIndex = index
                }
            }else{
                if isFromEdit{
                    if let index = relationsData.firstIndex(where: { $0.id == globalSubscriptionData?.subscriptionFor }) {
                        relationIndex = index
                    }
                }
            }
        }
        if addSubscriptionVM.listFamilyMembersResponse?.remainingFamilyMembersLimit ?? 0 > 0{
            canAddMembers = true
        }else{
            canAddMembers = false
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
        isCurrencyUpdateGlobalManual = true
    }
    
    func updateCountryAndCurrency() {
        if !fromSiri{
            selectedCurrency = Currency(id      : nil,
                                        name    : Constants.shared.currencyCode,
                                        symbol  : Constants.shared.currencySymbol,
                                        code    : Constants.shared.currencyCode,
                                        flag    : Constants.shared.flag(from: Constants.shared.regionCode))
            if let currencies = commonApiVM.currencyResponse {
                selectedCurrency = currencies.first(where: { $0.code == commonApiVM.userInfoResponse?.preferredCurrency })
                if selectedCurrency == nil{
                    selectedCurrency = Currency(id      : nil,
                                                name    : "",
                                                symbol  : commonApiVM.userInfoResponse?.preferredCurrencySymbol,
                                                code    : commonApiVM.userInfoResponse?.preferredCurrency,
                                                flag    : "")//Constants.shared.flag(from: Constants.shared.regionCode))
                }
            }else{
                commonApiVM.getCurrencies()
            }
        }else{
            fromSiri = false
        }
        if isFromEdit == true
        {
            if let currencies = commonApiVM.currencyResponse {
                selectedCurrency = currencies.first(where: { $0.code == globalSubscriptionData?.currency ?? ""})
                if selectedCurrency == nil{
                    selectedCurrency = Currency(id      : nil,
                                                name    : "",
                                                symbol  : globalSubscriptionData?.currencySymbol ?? "",
                                                code    : globalSubscriptionData?.currency ?? "",
                                                flag    : "")
                }
            } else if let currencyCode = globalSubscriptionData?.currency {
                selectedCurrency = Currency(id: nil, name: "", symbol: globalSubscriptionData?.currencySymbol ?? "", code: currencyCode, flag: "")
            }
        }
    }
    
    private func updateSubDetailsTOView() {
        if siriData != nil
        {
            fromSiri = true
            print(siriData)
            serviceName = siriData["serviceName"] as? String ?? ""
            serviceLastActionText = serviceName
            amount = "\(siriData["price"] as? Double ?? 0.00)"
            amountLastActionText = amount
            planType = siriData["planName"] as? String ?? ""
            planLastActionText = planType
            selectedPlanType = siriData["planName"] as? String ?? ""
            currency = siriData["currencyCode"] as? String ?? ""
            category = siriData["category"] as? String ?? ""
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self.chargeDate = formatter.string(from: siriData["nextChargeDate"] as? Date ?? Date())
            var billing = siriData["billingCycle"] as? String ?? ""
            if billing.lowercased() == "annual" {
                billing = "yearly"
            }
            selectedBilling = billing//billingData.first(where: { $0.title == billing})
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
            serviceLastActionText = serviceName
            amount = "\(globalSubscriptionData?.amount ?? 0.00)"
            amountLastActionText = amount
            currency = globalSubscriptionData?.currency ?? ""
            planType = globalSubscriptionData?.subscriptionType ?? ""
            planLastActionText = planType
            selectedPlanType = globalSubscriptionData?.subscriptionType ?? ""
            chargeDate = (globalSubscriptionData?.nextPaymentDate ?? "").formattedDate(to: "dd/MM/yyyy")
            let billing = globalSubscriptionData?.billingCycle ?? ""
            //            if let index = billingData.firstIndex(where: {
            //                $0.title!.lowercased() == billing.lowercased()
            //            }) {
            //                billingIndex = index
            //            }
            selectedBilling = billing//billingData.first(where: { $0.title == billing})
            if let categories = commonApiVM.categoriesResponse,
               let categoryName = globalSubscriptionData?.categoryName {
                selectedCategory = categories.first {
                    $0.name == categoryName
                }
            }else{
                selectedCategory?.name = globalSubscriptionData?.categoryName
                category = globalSubscriptionData?.categoryName ?? ""
            }
            if globalSubscriptionData?.paymentMethodId ?? "" != "" {
                if let paymentMethod1 = commonApiVM.paymentMethodResponse {
                    selectedPayment = paymentMethod1.first(where: { $0.id == globalSubscriptionData?.paymentMethodId ?? ""})
                    isCards = selectedPayment?.status ?? false
                    paymentMethod = selectedPayment?.name ?? ""
                }else{
                    paymentMethod = globalSubscriptionData?.paymentMethodName ?? ""
                }
            }
            if billing != ""{
                if isRenew {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    // Use the original yyyy-MM-dd string for parsing
                    if let baseDate = formatter.date(from: globalSubscriptionData?.nextPaymentDate ?? "") {
                        chargeDate = Constants.shared.getNextDateByFrequency(
                            frequency: billing,
                            baseDate: baseDate
                        )
                    } else {
                        chargeDate = Constants.shared.getNextDateByFrequency(
                            frequency: billing
                        )
                    }
                    initialRenewDate = chargeDate
                } else {
                    chargeDate = Constants.shared.getNextDateByFrequency(
                        frequency: billing
                    )
                }
            }
        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    private func infoButtonAction() {
    }
    
    private func currencySelection() {
        hideKeyboard()
        handleDone()
        if commonApiVM.currencyResponse != nil {
            showCurrencySheet = true
        }else{
            commonApiVM.getCurrencies()
        }
    }
    
    private func selectCategory()
    {
        hideKeyboard()
        if serviceName.trimmed != serviceLastActionText {
            pendingUIAction = .selectCategory
            fetchProviderDataApi()
            handleDone()
        } else {
            showCategorySheet = true
        }
    }
    
    private func selectPlanType()
    {
        hideKeyboard()
        if serviceName.trimmed != serviceLastActionText {
            pendingUIAction = .selectPlanType
            fetchProviderDataApi()
            handleDone()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sheetID = UUID()
                showPlanTypeSheet = true
            }
        }
    }
    
    private func selectBilling()
    {
        hideKeyboard()
        if serviceName.trimmed != serviceLastActionText {
            pendingUIAction = .selectBilling
            fetchProviderDataApi()
            handleDone()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sheetID = UUID()
                showBillingCycleSheet = true
            }
        }
    }
    
    private func selectpaymentMethod()
    {
        hideKeyboard()
        if serviceName.trimmed != serviceLastActionText {
            pendingUIAction = .selectpaymentMethod
            fetchProviderDataApi()
            handleDone()
        } else {
            showPaymentMethodSheet = true
        }
    }
    
    private func dateSelection() {
        hideKeyboard()
        if serviceName.trimmed != serviceLastActionText {
            pendingUIAction = .dateSelection
            fetchProviderDataApi()
            handleDone()
        } else {
            withAnimation(.easeInOut) {
                isDatePickerPresented = true
            }
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
        billingCycle = selectedBilling ?? ""//?.title ?? ""//.lowercased()
        let paymentMethod           = selectedPayment?.id ?? ""
        var paymentMethodDataId     = ""
        var paymentMethodDataName   = ""
        if cardIndex != -1 && isCards == true {
            paymentMethodDataId     = cardsData[cardIndex].id
            paymentMethodDataName   = "\(cardsData[cardIndex].title ?? "")****\(cardsData[cardIndex].subtitle ?? "")"
        }
        let category                = selectedCategory?.id ?? ""
        var subscriptionFor         = Constants.getUserId()
        var subscriptionForName     = "Me".localized
        if relationsData.indices.contains(relationIndex) {
            let selectedRelation = relationsData[relationIndex]
            subscriptionFor     = selectedRelation.id
            subscriptionForName = selectedRelation.title ?? ""
        }
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
                                           amount               : Double(amount.trimmed),// ?? 0.0,
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
        
        if let errorMessage = ManualEntryValidations.shared.manualEntry(input: input, category: selectedCategory?.name ?? "") {
            ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
        } else {
            if isRenew {
                handleRenewalSave(billingCycle: billingCycle, paymentMethod: paymentMethod, paymentMethodDataId: paymentMethodDataId, paymentMethodDataName: paymentMethodDataName, category: category, subscriptionFor: subscriptionFor, renewalReminder: renewalReminder)
            } else if isFromListEdit {
                addSubscriptionVM.editSubscription(input: editInput)
            }
            else if isFromEdit == true
            {
                // ... rest of existing edit logic ...
                updateGlobalSubscriptionData(billingCycle: billingCycle, paymentMethod: paymentMethod, paymentMethodDataId: paymentMethodDataId, paymentMethodDataName: paymentMethodDataName, category: category, subscriptionFor: subscriptionFor, subscriptionForName: subscriptionForName, renewalReminder: renewalReminder, renewalReminderValue: renewalReminderValue)
                self.goBack()
            }
            else{
                addSubscriptionVM.addSubscription(input: input)
            }
        }
    }
    
    private func handleRenewalSave(billingCycle: String, paymentMethod: String, paymentMethodDataId: String, paymentMethodDataName: String, category: String, subscriptionFor: String, renewalReminder: [String]) {
        let original = globalSubscriptionData
        
        let effectiveCurrency = selectedCurrency?.code ?? (original?.currency ?? "")
        let originalSubFor = (original?.subscriptionFor ?? "").isEmpty ? Constants.getUserId() : (original?.subscriptionFor ?? "")
        
        print("Debug Renewal: planType (\(planType.trimmed)) vs (\(original?.subscriptionType ?? ""))")
        print("Debug Renewal: amount (\(Double(amount.trimmed) ?? 0.0)) vs (\(original?.amount ?? 0.0))")
        print("Debug Renewal: currency (\(selectedCurrency?.code ?? "")) vs (\(original?.currency ?? ""))")
        print("Debug Renewal: category (\(category)) vs (\(original?.categoryId ?? ""))")
        print("Debug Renewal: billingCycle (\(billingCycle)) vs (\(original?.billingCycle ?? ""))")
        print("Debug Renewal: subscriptionFor (\(subscriptionFor)) vs (\(originalSubFor))")
        print("Debug Renewal: paymentMethod (\(paymentMethod)) vs (\(original?.paymentMethodId ?? ""))")
        print("Debug Renewal: paymentMethodDataId (\(paymentMethodDataId)) vs (\(original?.paymentMethodDataId ?? ""))")
        print("Debug Renewal: renewal reminders (\(renewalReminder)) vs (\(original?.renewalReminder ?? []))")
        print("Debug Renewal: notes (\(notes.trimmed)) vs (\(original?.notes ?? ""))")
        
        // Mandatory fields check
        let mandatoryChanged =
        serviceName.trimmed != (original?.serviceName ?? "") ||
        planType.trimmed != (original?.subscriptionType ?? "") ||
        abs((Double(amount.trimmed) ?? 0.0) - (original?.amount ?? 0.0)) > 0.01 ||
        effectiveCurrency != (original?.currency ?? "") ||
        billingCycle != (original?.billingCycle ?? "")
        
        let nextDateChanged = chargeDate != initialRenewDate
        
        let optionalChanged =
        paymentMethod != (original?.paymentMethodId ?? "") ||
        paymentMethodDataId != (original?.paymentMethodDataId ?? "") ||
        subscriptionFor != originalSubFor ||
        renewalReminder != (original?.renewalReminder ?? []) ||
        notes.trimmed != original?.notes
        
        if mandatoryChanged {
            // If mandatory changed, use type 2.
            let renewalRequest = RenewalUpdateRequest(
                userId: Constants.getUserId(),
                subscriptionId: subscriptionId,
                type: 2,
                serviceName: serviceName.trimmed,
                amount: Double(amount.trimmed),
                currency: selectedCurrency?.code ?? "",
                currencySymbol: selectedCurrency?.symbol ?? "",
                billingCycle: billingCycle,
                nextPaymentDate: chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd"),
                subscriptionType: planType.trimmed,
                paymentMethod: paymentMethod,
                paymentMethodDataId: paymentMethodDataId,
                category: category,
                subscriptionFor: subscriptionFor,
                renewalReminder: renewalReminder,
                notes: notes.trimmed
            )
            subscriptionMatchVM.renewalUpdate(input: renewalRequest)
        } else if optionalChanged || nextDateChanged {
            // If optional fields or next charge date changed, call edit API
            let editInput = EditSubscriptionRequest(
                userId: Constants.getUserId(),
                subscriptionId: subscriptionId,
                serviceName: serviceName.trimmed,
                amount: Double(amount.trimmed) ?? 0.0,
                currency: selectedCurrency?.code ?? "",
                billingCycle: billingCycle,
                nextPaymentDate: chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd"),
                subscriptionType: planType.trimmed,
                paymentMethod: paymentMethod,
                paymentMethodDataId: paymentMethodDataId,
                category: category,
                subscriptionFor: subscriptionFor,
                renewalReminder: renewalReminder,
                notes: notes.trimmed,
                currencySymbol: selectedCurrency?.symbol ?? ""
            )
            addSubscriptionVM.editSubscription(input: editInput)
        } else {
            // If nothing changed, call renewalUpdate API with type 1
            let renewalRequest = RenewalUpdateRequest(
                userId          : Constants.getUserId(),
                subscriptionId  : subscriptionId,
                type            : 1)
            subscriptionMatchVM.renewalUpdate(input: renewalRequest)
        }
    }
    
    private func updateGlobalSubscriptionData(billingCycle: String, paymentMethod: String, paymentMethodDataId: String, paymentMethodDataName: String, category: String, subscriptionFor: String, subscriptionForName: String, renewalReminder: [String], renewalReminderValue: String) {
        let logo = addSubscriptionVM.servicesList?.first {
            $0.name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == serviceName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }?.logo
        globalSubscriptionData?.serviceName = serviceName.trimmed
        if logo != "" && logo != nil {
            globalSubscriptionData?.serviceLogo = logo
        }
        globalSubscriptionData?.amount = Double(amount.trimmed) ?? 0.0
        globalSubscriptionData?.currency = selectedCurrency?.code ?? ""
        globalSubscriptionData?.currencySymbol = selectedCurrency?.symbol ?? ""
        globalSubscriptionData?.subscriptionType = planType.trimmed
        globalSubscriptionData?.nextPaymentDate = chargeDate.formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
        globalSubscriptionData?.billingCycle = billingCycle
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
    }
    
    private func handleDone() {
        switch activeField {
        case .serviceName:
            if serviceName != ""{
                if serviceName.trimmed != serviceLastActionText{
                    serviceLastActionText = serviceName.trimmed
                    fetchProviderDataApi()
                }
            }else{
                clearData()
            }
        case .planType:
            if planType != planLastActionText {
                planLastActionText = planType
                autoFillDetails()
            }
        case .amount:
            if amount != amountLastActionText {
                amountLastActionText = amount
                autoFillDetails(isAmount: true)
            }
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
                SecureField(LocalizedStringKey(placeHolder ?? ""), text: $ccv)
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
    var isCardNo        = false
    
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
                            Text(LocalizedStringKey(placeHolder ?? ""))
                                .padding(6)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(Color.neutral2500)
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                    }else{
                        if textValue != ""
                        {
                            Text(LocalizedStringKey(textValue ?? ""))
                                .padding(6)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(Color.neutralMain700)
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                        else{
                            Text(LocalizedStringKey(placeHolder ?? ""))
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
                            TextField(LocalizedStringKey(maxDigits == 4 ? "" : placeHolder ?? ""), text: $text)
                                .keyboardType(isNumberPad == true ? .decimalPad : .default)
                                .keyboardType(.default)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.leading)
                                .font(.appRegular(14))
                                .foregroundColor(.whiteBlackBGnoPic)
                                .onChange(of: text) { newValue in
                                    if isCardNo{
                                        filterDigitsAndLimit(maxDigits: maxDigits)
                                    }else{
                                        validateDecimalInput(maxDigits: maxDigits, maxDecimalPlaces: 2)
                                    }
                                }
                        }
                        .padding(6)
                    }else{
                        HStack{
                            if maxDigits == 4{
                                Text("**** **** ****")
                                    .foregroundColor(.whiteBlackBGnoPic)
                            }
                            TextField(LocalizedStringKey(maxDigits == 4 ? "" : placeHolder ?? ""), text: $text)
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

//MARK: - Field suggestions view
struct FieldSuggestionView<Item: Identifiable>: View {
    
    //MARK: - Properties
    @Binding var text                   : String
    var title                           : String?
    var image                           : String?
    var placeHolder                     : String?
    var currency                        : String?
    var isNumberPad                     : Bool = false
    var suggestions                     : [Item]
    var displayKey                      : (Item) -> String
    @FocusState.Binding var isFocused   : Bool
    var fieldType                       : FieldType
    @Binding var activeField            : FieldType?
    private var showSuggestions         : Bool { isFocused && !filtered.isEmpty }
    let action                          : () -> Void
    private var filtered: [Item] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if isFocused && query.isEmpty {
            return suggestions
        }
        guard !query.isEmpty else { return [] }
        return suggestions.filter {
            displayKey($0).lowercased().contains(query)
        }
    }
    var onSelect: (Item) -> Void = {_ in }
    
    //MARK: - body
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
                TextField(LocalizedStringKey(placeHolder ?? ""), text: $text)
                    .keyboardType(isNumberPad ? .decimalPad : .default)
                    .autocapitalization(.none)
                    .font(.appRegular(14))
                    .foregroundColor(.whiteBlackBGnoPic)
                    .focused($isFocused)
                    .onChange(of: isFocused) { focused in
                        if focused {
                            activeField = fieldType
                        } else {
                            action()
                        }
                    }
                    .onSubmit {
                        closeSuggestions()
                    }
                    .padding(6)
                
                if text != ""{
                    Button(action: {
                        text = ""
                    }) {
                        Image("cross")
                            .frame(width: 20, height: 20)
                    }
                }
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
                                Text(LocalizedStringKey(displayKey(item)))
                                    .foregroundColor(.neutralMain700)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                text = displayKey(item)
                                onSelect(item)
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
    
    private func closeSuggestions() {
        DispatchQueue.main.async {
            isFocused = false
            activeField = nil
        }
    }
}

//MARK: - Field suggestions view
struct FieldSuggestionView1<Item: Identifiable>: View {
    
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
    //    @Binding var lastActionText         : String
    @State private var focusTask        : Task<Void, Never>? = nil
    
    private var showSuggestions: Bool { isFocused && !filtered.isEmpty }
    
    private var filtered: [Item] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if isFocused && query.isEmpty {
            return suggestions
        }
        guard !query.isEmpty else { return [] }
        return suggestions.filter {
            displayKey($0).lowercased().contains(query)
        }
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
                TextField(LocalizedStringKey(placeHolder ?? ""), text: $text)
                    .keyboardType(isNumberPad ? .decimalPad : .default)
                    .autocapitalization(.none)
                    .font(.appRegular(14))
                    .foregroundColor(.whiteBlackBGnoPic)
                    .focused($isFocused)
                    .onChange(of: isFocused) { focused in
                        if focused {
                            //                            focusTask?.cancel()
                            activeField = fieldType
                            //                            lastActionText = text.trimmed
                        } else {
                            //                            focusTask = Task {
                            //                                try? await Task.sleep(nanoseconds: 200_000_000)
                            //                                if !Task.isCancelled && text.trimmed != lastActionText {
                            //                                    lastActionText = text.trimmed
                            //                                    action()
                            //                                }
                            //                            }
                            action()
                        }
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
                                Text(LocalizedStringKey(displayKey(item)))
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
    
    private func closeSuggestions() {
        DispatchQueue.main.async {
            isFocused = false
            activeField = nil
        }
    }
}

//MARK: - ListView
struct ListView: View {
    var type                                    : ListType = .billing
    var title                                   : String?
    var addMore                                 : Bool = false
    @Binding var data                           : [ManualDataInfo]
    @Binding var selectedIndex                  : Int
    @State private var showNewCardSheet         = false
    @State private var openFamilyMemberSheet    = false
    @State private var shouldCallAPI            = false
    @State private var sheetHeight              : CGFloat = .zero
    @State private var sheetID                  = UUID()
    var onDismiss   : (() -> Void)?
    var onAddFamily : ((String, String, String, String) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
                .padding(.bottom, 4)
                .frame(maxWidth:.infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 0) {
                
                if type == .reminders {
                    remindersStack
                } else {
                    defaultList
                }
                
                if addMore == true
                {
                    Divider()
                        .overlay(Color.neutral2200)
                    VStack(alignment: .center, spacing: 0) {
                        Button(action: addMoreAction) {
                            HStack(spacing: 8) {
                                Image("AddMore")
                                    .frame(width: 20, height: 20)
                                Text(LocalizedStringKey(type == .cards ? "Add New Card" : "Add New Member"))
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
//                                .onAppear {
//                                    DispatchQueue.main.async {
//                                        sheetHeight = sheetHeight
//                                    }
//                                }
//                                .id(sheetID)
//                                .overlay {
//                                    GeometryReader { geo in
//                                        Color.clear
//                                            .preference(
//                                                key: InnerHeightPreferenceKey.self,
//                                                value: geo.size.height
//                                            )
//                                    }
//                                }
//                                .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
//                                    if height > 150 {
//                                        sheetHeight = height
//                                    }
//                                }
//                                .presentationDetents([.height(sheetHeight)])
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.hidden)
//                                .interactiveDismissDisabled(false)
                        }
                        //                        .onChange(of: showNewCardSheet) { newValue in
                        //                            if newValue == false {
                        //                                onDismiss?()
                        //                            }
                        //                        }
                    }
                }
            }
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
        .sheet(isPresented: $openFamilyMemberSheet) {
            AddFamilyMemberBottomSheet(header       : "Add Family Member",
                                       description  : "Add a family member to manage and share plans together.",
                                       buttonName   : "Save",
                                       action       : {nickName, phone, countryCode, colorHex in
                onAddFamily?(nickName, phone, countryCode, colorHex)
                //                let input = AddFamilyMemberRequest(userId       : Constants.getUserId(),
                //                                                   nickName     : nickName.trimmed,
                //                                                   phoneNumber  : phone,
                //                                                   countryCode  : countryCode,
                //                                                   color        : colorHex)
                //                manualVM.addfamilyMember(input: input)
            })
            .id(UUID())
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(600)])
        }
    }
    
    private var defaultList: some View {
        LazyVStack(spacing: 0) {
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
        //        .scrollDisabled(true)
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .scrollContentBackground(.hidden)
        .frame(height: CGFloat((52 * data.count)))
    }
    
    private var remindersStack: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, objc in
                VStack(spacing: 0) {
                    rowView(for: objc, at: index)
                    
                    if index < data.count - 1 {
                        Divider()
                            .overlay(Color.neutral2200)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedAction(at: index)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Extracted subview
    @ViewBuilder
    private func rowView(for objc: ManualDataInfo, at index: Int) -> some View {
        if type == .billing { //not using, if using need add this type in selectedAction function
            BillingCycleItem(title: objc.title ?? "", subtitle: objc.subtitle ?? "", isSelected: index == selectedIndex ? true : false)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
        if type == .cards {
            Button {
                selectedAction(at: index)
            } label: {
                SubscriptionItem(
                    title: objc.title ?? "",
                    subtitle: objc.subtitle ?? "",
                    isSelected: index == selectedIndex,
                    isSubTitlePresent: true
                )
            }
            .buttonStyle(.plain)
        }
        if type == .relations {
            SubscriptionItem(title: objc.title ?? "", subtitle: objc.subtitle ?? "", isSelected: index == selectedIndex ? true : false)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
        if type == .reminders {
            Button {
                selectedAction(at: index)
            } label: {
                ReminderItem(title: objc.title ?? "", isSelected: objc.isSelected ?? false)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Button actions
    private func selectedAction(at index: Int) {
        selectedIndex = index
        if type == .reminders || type == .cards{
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sheetID = UUID()
                showNewCardSheet = true
            }
        }else if type == .relations{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                openFamilyMemberSheet = true
            }
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
                Text(LocalizedStringKey(title ?? ""))
                    .font(.appRegular(14))
                    .foregroundColor(.neutralMain700)
            }
            Spacer()
            Text(LocalizedStringKey(subtitle ?? ""))
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
            Text(LocalizedStringKey(title ?? ""))
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
            Text(LocalizedStringKey(title ?? ""))
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
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 24)
            
            VStack(alignment: .center, spacing: 8) {
                Text("Review Original Image")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
            }
            .padding(.bottom, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .padding(.bottom, 16)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
