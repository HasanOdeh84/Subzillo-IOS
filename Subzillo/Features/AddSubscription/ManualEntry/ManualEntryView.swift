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
import SDWebImageSwiftUI

var isCurrencyUpdateGlobalManual                = false

struct ManualEntryView: View {
    
    
    //MARK: - Properties
    @State private var fieldFrame: CGRect = .zero
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
    @State private var reminderDays: Int = 3
    @State var isPlanTypeError                  : Bool = false
    @State var isAmountError                    : Bool = false
    @State private var activeField              : FieldType?
    @State private var showPlanTypeSheet        = false
    @State var selectedPlanType                 : String?
    var familyMemberId                          = ""
    @State private var sheetHeight              : CGFloat = 400
    @State private var sheetID                  = UUID()
    @State private var serviceLastActionText    : String = ""
    @State private var planLastActionText       : String = ""
    @State private var amountLastActionText     : String = ""
    @State private var pendingUIAction          : PendingUIAction? = nil
    @State var isCurrency                       = false
    @State var isCurrencyUpdate                 = false
    var isFromEmail                             : Bool = false
    var fromEmailSync                           : Bool = false
    @State private var paymentSearchText        : String = ""
    
    var filteredPaymentMethods: [PaymentMethod] {
        if paymentSearchText.isEmpty {
            return commonApiVM.paymentMethodResponse ?? []
        }
        return commonApiVM.paymentMethodResponse?.filter {
            $0.name?.localizedCaseInsensitiveContains(paymentSearchText) ?? false
        } ?? []
    }
    
    @EnvironmentObject var themeManager         : ThemeManager
    
    //MARK: - body
    var body: some View {
        let planTypeSuggestions = filteredPlanTypes()
        VStack(alignment: .leading,spacing: 0) {
            ZStack(alignment: .topLeading) {
                // MARK: Header
                HStack(alignment: .top, spacing: 8) {
                    //                // MARK: - back
                    //                Button(action: goBack) {
                    //                    Image("back_gray")
                    //                }
                    //
                    //                VStack(alignment: .leading, spacing: 2) {
                    //                    // MARK: Title
                    //                    Text(LocalizedStringKey(isFromEdit == true ? "Edit Details" : "Manual Entry"))
                    //                        .font(.appRegular(24))
                    //                        .foregroundColor(Color.neutralMain700)
                    //
                    //                    // MARK: SubTitle
                    //                    Text(LocalizedStringKey(isFromEdit == true ? "Update your details" : "Add your subscription details manually."))
                    //                        .font(.appRegular(18))
                    //                        .foregroundColor(Color.neutral500)
                    //                }
                    //                Spacer()
                    // MARK: - back
                    CircleBackButton {
                        goBack()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(LocalizedStringKey(isFromEdit == true ? "Edit subscription" : "Manual entry"))
                            .font(.geistSemiBold(16))
                            .foregroundColor(
                                Color("TextPrimary_ 0E101A_F4F1FB")
                            )
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // MARK: - Empty Space
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                //            .padding(.top, 15)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        //                    Text("Required Information")
                        //                        .font(.appRegular(18))
                        //                        .foregroundColor(.underlineGray)
                        //                        .lineLimit(1)
                        //                        .layoutPriority(1)
                        //                        .frame(maxWidth: .infinity, alignment: .leading)
                        //                        .frame(height: 28)
                        //                        .padding(.leading, 5)
                        VStack(alignment: .leading, spacing: 2) {
                            // MARK: Title
                            titleView(title: "Type the details", styledPart: "details")
                            //                        Text(LocalizedStringKey("Type the "))
                            //                            .font(.geistSemiBold(28))
                            //                            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                            //                        + Text(LocalizedStringKey("details"))
                            //                            .font(.jetBrainsSemiBoldItalic(28))
                            //                            .foregroundStyle(themeManager.gradient(style: .vertical))
                            //
                            // MARK: SubTitle
                            Text(LocalizedStringKey("We'll validate against 500+ known providers and auto-fill the rest."))
                                .font(.geistMedium(12))
                                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                        
                        //MARK: Service field
                        
                        FieldSuggestionView1(
                            text        : $serviceName,
                            title       : "Subscription Name",
                            image       : "tag_new",
                            placeHolder : "e.g. Netflix, ChatGPT...",
                            suggestions : addSubscriptionVM.servicesList ?? [],
                            displayKey  : { $0.name ?? "" },
                            isService   : true,
                            fieldType   : FieldType.serviceName,
                            activeField : $activeField,
                            action      : {
                                if serviceName.isEmpty {
                                    clearData()
                                }
                            }
                        )
                        .allowsHitTesting(!isRenew)
                        .opacity(isRenew ? 0.6 : 1.0)
                        .onChange(of: serviceName) { newValue in
                            if newValue.count >= 3 {
                                if newValue.trimmed != serviceLastActionText {
                                    serviceLastActionText = newValue.trimmed
                                    fetchProviderDataApi(showLoader: false)
                                }
                            } else {
                                addSubscriptionVM.providerData = nil
                                serviceLastActionText = ""
                                if newValue.isEmpty {
                                    clearData()
                                }
                            }
                        }
                        .padding(.top, 6)
                        
                        if addSubscriptionVM.providerData != nil, !getAllPlans().isEmpty, serviceName.count >= 3 {
                            matchCard
                        }
                        
                        //MARK: PlanType field
                        FieldSuggestionView1(
                            text        : $planType,
                            title       : "Plan Type",
                            image       : "tag_new",
                            placeHolder : "Plan type",
                            suggestions : planTypeSuggestions,
                            displayKey  : { (item: PlanTypeItem) in item.name },
                            fieldType   : FieldType.planType,
                            activeField : $activeField,
                            action      : handlePlanTypeChange
                        )
                        .allowsHitTesting(!isRenew)
                        .opacity(isRenew ? 0.6 : 1.0)
                        
                        /*
                         Button(action: selectPlanType) {
                         FieldView(text: $planType, textValue: selectedPlanType ?? "", title: "Plan Type", image: "gridicon2", placeHolder: "Please select", isButton: true, isText: true)
                         }
                         .sheet(isPresented: $showPlanTypeSheet) {
                         PlanTypeBottomSheet(selectedPlanType    : $selectedPlanType,
                         planTypeResponse    : filteredPlanTypes(),
                         header              : "Select Plan Type",
                         placeholder         : "Search",
                         action              : {
                         planLastActionText = selectedPlanType ?? ""
                         planType = selectedPlanType ?? ""
                         autoFillDetails(isAmount: false)
                         })
                         //                        .onAppear {
                         //                            DispatchQueue.main.async {
                         //                                sheetHeight = sheetHeight
                         //                            }
                         //                        }
                         //                        .id(sheetID)
                         //                        .overlay {
                         //                            GeometryReader { geo in
                         //                                Color.clear
                         //                                    .preference(
                         //                                        key: InnerHeightPreferenceKey.self,
                         //                                        value: geo.size.height
                         //                                    )
                         //                            }
                         //                        }
                         //                        .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                         //                            if height > 150 {
                         //                                sheetHeight = height
                         //                            }
                         //                        }
                         //                        .presentationDetents(
                         //                            sheetHeight > UIScreen.main.bounds.height * 0.75
                         //                                ? [.large]
                         //                                : [.height(sheetHeight)]// .large]
                         //                        )
                         .presentationDetents([.medium, .large])
                         .presentationDragIndicator(.hidden)
                         }
                         */
                        
                        HStack(spacing: 10) {
                            //MARK: Amount field
                            VStack{
                                FieldSuggestionView1(
                                    text        : $amount,
                                    title       : "Price",
                                    image       : "tag_new",
                                    placeHolder : "0.00",
                                    currency    : selectedCurrency?.symbol ?? Constants.shared.currencySymbol,
                                    isNumberPad : true,
                                    suggestions : filteredPricePlans(),
                                    displayKey  : { plan in
                                        String(format: "%.2f", plan.price ?? 0)
                                    },
                                    borderColor : !isAmountError,
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
                                    FieldView(text: $currency, textValue: selectedCurrency?.code ?? "", title: "Currency", image: "globeIcon", placeHolder: Constants.shared.currencyCode, isButton: true, isText: true, isCurrency: true, currencySymbol: selectedCurrency?.symbol ?? "")
                                        .frame(width: 140, alignment: .trailing)
                                }
                                .background {
                                    GeometryReader { geo in
                                        if #available(iOS 17.0, *) {
                                            Color.clear
                                                .onAppear {
                                                    fieldFrame = geo.frame(in: .global)
                                                }
                                                .onChange(of: geo.frame(in: .global)) { _, newFrame in
                                                    fieldFrame = newFrame
                                                }
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                    }
                                }
                                /*.sheet(isPresented: $showCurrencySheet) {
                                    CountriesBottomSheet(selectedCurrency   : $selectedCurrency,
                                                         selectedCountry    : $selectedCountry,
                                                         isCountry          : false,
                                                         currencyResponse   : commonApiVM.currencyResponse,
                                                         countryResponse    : commonApiVM.countriesResponse,
                                                         header             : "Currency",
                                                         placeholder        : "Search",
                                                         action             : {
                                        self.handleCurrencySelection()
                                    })
                                    .presentationDetents([.large])
                                    .presentationDragIndicator(.hidden)
                                }*/
                                Spacer()
                            }
                        }
                        
                        if isAmountError{
                            HStack(spacing: 6){
                                Image("info")
                                    .frame(width: 24, height: 24)
                                Text("Amount is not matching with the existing data. Are you sure you want to continue?")
                                    .font(.geistRegular(14))
                                    .foregroundColor(Color.systemInfoBlue)
                                Spacer()
                            }
                            .padding(.leading, 5)
                            .padding(.top, -29)
                        }
                        
                        //MARK: Billing cycle field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("BILLING CYCLE")
                                .font(.jetBrainsMedium(11))
                                .tracking(1)
                                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                .padding(.leading, 5)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(allBillingCycles(), id: \.self) { cycle in
                                        let isSelected = selectedBilling?.lowercased() == cycle.lowercased()
                                        Button(action: {
                                            selectedBilling = cycle
                                            updateAmount(billing: cycle)
                                        }) {
                                            Text(cycle)
                                                .font(.geistMedium(12))
                                                .foregroundColor(isSelected ? .white : themeManager.textPrimaryLight6_dark62)
                                                .padding(.horizontal, 16)
                                                .frame(height: 44)
                                                .background(
                                                    Group {
                                                        if isSelected {
                                                            themeManager.gradient(style: .horizontal)
                                                                .cornerRadius(10)
                                                        } else {
                                                            Color.clear
                                                        }
                                                    }
                                                )
                                                .shadow(color: isSelected ? themeManager.accentTextColor : Color.clear, radius: 4,x: 0,y: 2)
                                        }
                                    }
                                }
                                .padding(4)
                                .frame(minWidth: UIScreen.main.bounds.width - 30, alignment: .leading)
                            }
                            .background(themeManager.white_white4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
                            )
                            .cornerRadius(16)
                        }
                        .onChange(of: selectedBilling) { billing in
                            guard let billing else { return }
                            
                            if (isFromEdit || isRenew) && isInitialPayment {
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
                            FieldView(text: $chargeDate, textValue: "", title: "Next Charge Date", image: "timer_new", placeHolder: "dd/mm/yyyy", isButton: false, isText: true, isDate:true)
                        }
                        .background(
                            DatePickerPopup(isPresented: $isDatePickerPresented, selectedDate: $tempDate) { date in
                                let formatter = DateFormatter()
                                formatter.dateFormat = "dd/MM/yyyy"//"yyyy-MM-dd"
                                self.chargeDate = formatter.string(from: date)
                                print(chargeDate)
                            }
                        )
                        
                        //MARK: Category field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CATEGORY")
                                .font(.jetBrainsMedium(11))
                                .tracking(1)
                                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                .padding(.leading, 5)
                            
                            if let categories = commonApiVM.categoriesResponse {
                                FlowLayout {
                                    ForEach(categories, id: \.id) { cat in
                                        let isSelected = selectedCategory?.id == cat.id
                                        Button(action: {
                                            selectedCategory = cat
                                            category = cat.name ?? ""
                                        }) {
                                            Text(cat.name ?? "")
                                                .font(.geistMedium(12))
                                                .foregroundColor(isSelected ? .white : themeManager.textPrimaryLight6_dark62)
                                                .padding(.horizontal, 16)
                                                .frame(height: 36)
                                                .background(
                                                    Group {
                                                        if isSelected {
                                                            themeManager.gradient(style: .horizontal)
                                                        } else {
                                                            themeManager.white_white4
                                                        }
                                                    }
                                                )
                                                .cornerRadius(18)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 18)
                                                        .stroke(isSelected ? Color.clear : themeManager.textPrimaryLight8_white8, lineWidth: 1)
                                                )
                                                .shadow(color: isSelected ? themeManager.accentTextColor : Color.clear, radius: 5,x: 0,y: 3)
                                        }
                                    }
                                }
                                .padding(.horizontal, 5)
                            }
                        }
                        .allowsHitTesting(!isRenew)
                        .opacity(isRenew ? 0.6 : 1.0)
                        
                        //                    if let source = addSubscriptionVM.providerData?.source{
                        //                        HStack(spacing: 5){
                        //                            Text("Source: ")
                        //                                .font(.geistBold(14))
                        //                                .foregroundColor(Color.neutralMain700)
                        //                                .padding(.leading, 5)
                        //
                        //                            Text("\(source)")
                        //                                .font(.geistRegular(14))
                        //                                .foregroundColor(Color.neutralMain700)
                        //
                        //                            Spacer()
                        //                        }
                        //                    }
                        //
                        //                    if let urls = addSubscriptionVM.providerData?.urls, !urls.isEmpty {
                        //                        VStack(alignment: .leading, spacing: 4) {
                        //                            Text("URLs:")
                        //                                .font(.geistBold(14))
                        //                                .foregroundColor(Color.neutralMain700)
                        //
                        //                            //                            ForEach(urls, id: \.self) { url in
                        //                            //                                Text(url)
                        //                            //                                    .font(.appRegular(14))
                        //                            //                                    .foregroundColor(Color.neutralMain700)
                        //                            //                            }
                        //
                        //                            ForEach(urls, id: \.self) { url in
                        //                                if let link = URL(string: url) {
                        //                                    Link(url, destination: link)
                        //                                        .font(.geistRegular(14))
                        //                                }
                        //                            }
                        //                        }
                        //                        .frame(maxWidth: .infinity, alignment: .leading)
                        //                        .padding(.leading, 5)
                        //                    }
                        
                        //MARK: Optional Details
                        Button(action: optionalDetailsAction) {
                            HStack(spacing: 8) {
                                Text("Optional Details")
                                    .font(.geistMedium(16))
                                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                    .lineLimit(1)
                                    .layoutPriority(1)
                                    .padding(.leading, 5)
                                //                            DashedHorizontalDivider(dash: [3,3])
                                Spacer()
                                HStack {
                                    Image("downArrow")
                                        .rotationEffect(.degrees(isMoreEnable ? 180 : 0))
                                        .animation(.easeInOut(duration: 0.25), value: isMoreEnable)
                                }
                                .frame(width: 12, height: 7, alignment: .trailing)
                            }
                            .frame(height: 28)
                        }
                        .padding(.trailing, 10)
                        
                        if isMoreEnable == true {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Payment Method")
                                    .font(.jetBrainsMedium(11))
                                    .tracking(1)
                                    .textCase(.uppercase)
                                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                    .padding(.leading, 5)
                                
                                InlineSelectionView(
                                    title                   : "",
                                    items                   : filteredPaymentMethods,
                                    selectedItem            : $selectedPayment,
                                    isExpanded              : $showPaymentMethodSheet,
                                    searchText              : $paymentSearchText,
                                    placeholder             : "Search payment method",
                                    labelProvider           : { $0.name ?? "" },
                                    flagProvider            : nil,
                                    detailProvider          : nil,
                                    secondaryDetailProvider : nil,
                                    isPayment               : true
                                )
                                .onChange(of: selectedPayment) { newValue in
                                    guard let newValue = newValue else { return }
                                    isCards = newValue.status ?? false
                                    paymentMethod = newValue.name ?? ""
                                }
                                .padding(.horizontal, 5)
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
                            
                            ReminderSliderView(reminderDays: $reminderDays)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes")
                                    .font(.jetBrainsMedium(11))
                                    .tracking(1)
                                    .textCase(.uppercase)
                                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                VStack{
                                    
                                    if notes.isEmpty {
                                        Text("Add any additional notes about this subscription...")
                                            .background(Color.clear)
                                            .font(.geistRegular(15))
                                            .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    TextEditor(text: $notes)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                        .keyboardType(.default)
                                        .autocapitalization(.none)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .font(.geistRegular(15))
                                        .foregroundColor(.textPrimary0E101AF4F1FB)
                                        .padding(.horizontal, -5)
                                        .padding(.top, -8)
                                        .offset(x: 0, y: notes.isEmpty ? -25 : 0)
                                    
                                    Spacer(minLength: 0)
                                }
                                .padding(16)
                                .frame(height: 110)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
                                )
                                .background(themeManager.white_white4)
                                .cornerRadius(14)
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
                        
                        GradientBgButton(
                            title       : isFromEdit == true ? "Save Changes" : "Save Subscription",
                            isSolid     : true,
                            showChevron : true
                        ) {
                            saveAction()
                        }
                        .padding(5)
                        .padding(.bottom, 120)
                        //                    CustomButton(title: isFromEdit == true ? "Save Changes" : "Save Subscription", action: saveAction)
                        //                        .padding(5)
                        //                        .padding(.bottom, 120)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                
                // MARK: Popup Overlay

                if showCurrencySheet {

                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showCurrencySheet = false
                            }
                        }

                    VStack {
                        HStack {
                            Spacer()

                            CurrencyPopup
                               .position(
                                   x: fieldFrame.minX + 20,
                                   y: fieldFrame.maxY + 80
                               )
                        }

                        Spacer()
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(100)
                }
            }
            
        }
        .keyboardAdaptive()
        .navigationBarBackButtonHidden()
        .padding(.top, 10)
        .applyAppBackground()
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
            if isFromEdit || isRenew {
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
    
    
    // MARK: Popup

    private var CurrencyPopup: some View {

        ScrollView {

            VStack(spacing: 2) {

                ForEach(commonApiVM.currencyResponse ?? [], id: \.code) { currency in

                    Button {

                        selectedCurrency = currency

                        withAnimation {
                            showCurrencySheet = false
                        }
                        
                        isCurrencyUpdateGlobalManual = false
                        isCurrencyUpdateGlobal = false
                        
                        self.handleCurrencySelection()

                    } label: {

                        HStack(spacing: 10) {

                            Text(currency.symbol ?? "")
                                .font(.geistBold(13))
                                .foregroundColor(themeManager.selectedAccent.senColor)
                                .frame(width: 34, alignment: .leading)

                            VStack(alignment: .leading, spacing: 2) {

                                Text(currency.code ?? "")
                                    .font(.geistSemiBold(12))
                                    .foregroundColor(Color.textPrimary0E101AF4F1FB)

                                Text(currency.name ?? "")
                                    .font(.geistRegular(10))
                                    .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                            }

                            Spacer()
                        }
                        .padding(8)
                        .background(
                            selectedCurrency?.code == currency.code
                            ? AnyShapeStyle(themeManager.accentGradient.opacity(0.13))
                            : AnyShapeStyle(Color.clear)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(6)
        }
        .frame(width: 220, height: 260)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(themeManager.black_white.opacity(0.14))
        }
        .shadow(radius: 20)
    }
    
    //MARK: - User defined methods
    
    @ViewBuilder
    private func titleView(title: String, styledPart: String) -> some View {
        if !styledPart.isEmpty && title.contains(styledPart) {
            buildLine(line: title, styledPart: styledPart, isMask: false)
                .multilineTextAlignment(.center)
                .overlay(
                    themeManager.gradient(style: .vertical)
                        .mask(
                            buildLine(line: title, styledPart: styledPart, isMask: true)
                                .multilineTextAlignment(.center)
                        )
                )
                .foregroundColor(.clear)
        } else {
            Text(title)
                .font(.geistSemiBold(28))
                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                .multilineTextAlignment(.center)
        }
    }
    
    private func buildLine(line: String, styledPart: String, isMask: Bool) -> Text {
        let parts = line.components(separatedBy: styledPart)
        var result = Text("")
        for (index, part) in parts.enumerated() {
            result = result + Text(part)
                .font(.geistSemiBold(28))
                .foregroundColor(isMask ? .clear : Color("TextPrimary_ 0E101A_F4F1FB"))
            
            if index < parts.count - 1 {
                result = result + Text(styledPart)
                    .font(.jetBrainsSemiBoldItalic(28))
                    .italic()
                    .foregroundColor(isMask ? .black : .clear)
            }
        }
        return result
    }
    
    func fetchProviderDataApi(showLoader: Bool = true){
        addSubscriptionVM.fetchProviderData(input       : FetchProviderDataRequest(userId           : Constants.getUserId(),
                                                                                   serviceName      : nil,
                                                                                   providerName     : serviceName.trimmed,
                                                                                   currencyCode     : selectedCurrency?.code ?? "" == "" ? Constants.shared.currencyCode : selectedCurrency?.code ?? ""),
                                            showLoader  : showLoader,
                                            endPoint    : APIEndpoint.fetchProviderDbPlans)
    }
    
    func getAllPlans() -> [ProviderSubscriptionPlan] {
        guard let providers = addSubscriptionVM.providerData?.providerSubscriptionPlansList else { return [] }
        return providers.compactMap { $0.providerSubscriptionPlansList }.flatMap { $0 }
    }
    
    func filteredPricePlans() -> [ProviderSubscriptionPlan] {
        let plans = getAllPlans()
        guard !plans.isEmpty else {
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
    
    //    func filteredPlanTypes() -> [String] {
    //        guard
    //            let plans = addSubscriptionVM.providerData?.providerSubscriptionPlansList,
    //            !plans.isEmpty
    //        else {
    //            // Fallback when API returns no plans
    //            return ["Free", "Basic"]
    //        }
    //
    //        let planNames = plans.compactMap { $0.planName }
    //
    //        // If plan names are missing or empty, still return fallback
    //        guard !planNames.isEmpty else {
    //            return ["Free", "Basic"]
    //        }
    //
    //        return Array(Set(planNames))
    //    }
    
    func filteredPlanTypes() -> [PlanTypeItem] {
        let plans = getAllPlans()
        guard !plans.isEmpty else {
            return [
                PlanTypeItem(name: "Free"),
                PlanTypeItem(name: "Basic")
            ]
        }
        
        let planNames = plans.compactMap { $0.planName }
        
        guard !planNames.isEmpty else {
            return [
                PlanTypeItem(name: "Free"),
                PlanTypeItem(name: "Basic")
            ]
        }
        
        return Array(Set(planNames)).map { PlanTypeItem(name: $0) }
    }
    
    func filteredBillingCycles() -> [String] {
        let plans = getAllPlans()
        guard !plans.isEmpty else {
            // Fallback when API returns no plans
            return ["Monthly", "Yearly"]
        }
        
        let billingCycleNames = plans.compactMap { $0.billingCycle }
        
        // If plan names are missing or empty, still return fallback
        guard !billingCycleNames.isEmpty else {
            return ["Monthly", "Yearly"]
        }
        
        return Array(Set(billingCycleNames))
    }
    
    func allBillingCycles() -> [String] {
        var cycles = ["Daily", "Weekly", "Monthly", "Quarterly", "Biannually", "Yearly"]
        let apiCycles = filteredBillingCycles()
        
        for cycle in apiCycles {
            if !cycles.contains(where: { $0.caseInsensitiveCompare(cycle) == .orderedSame }) {
                cycles.append(cycle)
            }
        }
        
        if let selected = selectedBilling, !selected.isEmpty {
            if !cycles.contains(where: { $0.caseInsensitiveCompare(selected) == .orderedSame }) {
                cycles.append(selected)
            }
        }
        
        return cycles
    }
    
    func handlePlanTypeChange() {
        if planType != "" {
            if planType.trimmed != planLastActionText {
                planLastActionText = planType.trimmed
                autoFillDetails()
            }
        }
    }
    
    private func handleCurrencySelection() {
        if isCurrencyUpdateGlobalManual {
            isCurrencyUpdateGlobalManual = false
            return
        }
        guard !serviceName.isEmpty else { return }
        isCurrency = true
        fetchProviderDataApi()
    }
    
    private func updateProviderData() {
        activeField = nil
        let pending = pendingUIAction
        pendingUIAction = nil
        
        if (isFromEdit || isRenew) && isInitialCategory {
            isInitialCategory = false
        } else {
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
                isAmountError = false
                isPlanTypeError = false
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
        isAmountError = false
        isPlanTypeError = false
    }
    
    func updateAmount(billing:String){
        let plans = getAllPlans()
        guard
            !billing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !plans.isEmpty
        else {
            return
        }
        
        // Try to find a plan that matches both the selected plan type AND the new billing cycle
        var matchedPlan = plans.first(where: { plan in
            let cycleMatch = (plan.billingCycle ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare(
                    billing.trimmingCharacters(in: .whitespacesAndNewlines)
                ) == .orderedSame
            
            if let selected = selectedPlanType, !selected.isEmpty {
                return cycleMatch && (plan.planName ?? "").caseInsensitiveCompare(selected) == .orderedSame
            }
            return cycleMatch
        })
        
        // If not found with the current plan type, find ANY plan that matches the billing cycle
        if matchedPlan == nil {
            matchedPlan = plans.first(where: { plan in
                (plan.billingCycle ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .caseInsensitiveCompare(
                        billing.trimmingCharacters(in: .whitespacesAndNewlines)
                    ) == .orderedSame
            })
            
            if let matched = matchedPlan {
                // Update plan type and selectedPlanType to reflect the plan that matches this cycle
                planType = matched.planName ?? ""
                selectedPlanType = matched.planName ?? ""
                planLastActionText = planType
            }
        }
        
        if let matched = matchedPlan {
            amount = String(format: "%.2f", matched.price ?? 0)
            amountLastActionText = amount
            isAmountError = false
            updateCurrency(currencyCode     : matched.currencyCode ?? Constants.shared.currencyCode,
                           currencySymbol   : matched.currencySymbol ?? Constants.shared.currencySymbol)
        }
    }
    
    private func autoFillDetails(isAmount:Bool = false){
        activeField = nil
        let plans = getAllPlans()
        if isAmount{
            guard
                let enteredAmount = Double(amount),
                !plans.isEmpty
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
                updateCurrency(currencyCode     : matchedPlan.currencyCode ?? Constants.shared.currencyCode,
                               currencySymbol   : matchedPlan.currencySymbol ?? Constants.shared.currencySymbol)
            } else {
                if !plans.isEmpty {
                    isAmountError = true
                }
            }
        }else{
            guard
                !planType.isEmpty,
                !plans.isEmpty
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
                selectedPlanType = matchedPlan.planName ?? ""
                isPlanTypeError = false
                isAmountError = false
                updateCurrency(currencyCode     : matchedPlan.currencyCode ?? Constants.shared.currencyCode,
                               currencySymbol   : matchedPlan.currencySymbol ?? Constants.shared.currencySymbol)
            } else {
                if planType == "Free" || planType == "Basic"{
                    selectedBilling = "Monthly"
                    isAmountError = false
                }
                if planType == "Free"{
                    amount = "0.0"
                }
                if !plans.isEmpty {
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
                    if isFromListEdit{
                        goBack()
                    }else{
                        if familyMemberId == ""{
                            AppIntentRouter.shared.navigate(to: .subscriptionsListView())
                        }else{
                            goBack()
                        }
                    }
                }
            }
            else{
                if isFromListEdit{
                    goBack()
                }else{
                    if familyMemberId == ""{
                        AppIntentRouter.shared.navigate(to: .subscriptionsListView())
                    }else{
                        goBack()
                    }
                }
            }
        }
    }
    
    private func updatePaymentInfo() {
        if isFromEdit || isRenew {
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
        if isFromEdit || isRenew {
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
                if isFromEdit || isRenew {
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
        if isFromEdit || isRenew {
            let id = globalSubscriptionData?.paymentMethodDataId ?? ""
            if let index = cardsData.firstIndex(where: {
                $0.id == id
            }) {
                cardIndex = index
            }
        }
    }
    
    func updateCurrency(currencyCode: String, currencySymbol: String) {
        selectedCurrency = resolveCurrency(code: currencyCode, symbol: currencySymbol)
        isCurrencyUpdateGlobalManual = true
    }
    
    func updateCountryAndCurrency() {
        if !fromSiri {
            selectedCurrency = resolveCurrency(
                code: commonApiVM.userInfoResponse?.preferredCurrency,
                symbol: commonApiVM.userInfoResponse?.preferredCurrencySymbol
            )
        } else {
            fromSiri = false
        }
        if isFromEdit || isRenew {
            selectedCurrency = resolveCurrency(
                code: globalSubscriptionData?.currency,
                symbol: globalSubscriptionData?.currencySymbol
            )
        }
    }
    
    func resolveCurrency(code: String?, symbol: String?) -> Currency {
        let defaultCurrency = Currency(
            id: nil,
            name: Constants.shared.currencyCode,
            symbol: Constants.shared.currencySymbol,
            code: Constants.shared.currencyCode,
            flag: Constants.shared.flag(from: Constants.shared.regionCode)
        )
        
        let currencyCode = code ?? ""
        
        guard let currencies = commonApiVM.currencyResponse else {
            commonApiVM.getCurrencies()
            return currencyCode.isEmpty ? defaultCurrency : Currency(
                id: nil,
                name: "",
                symbol: symbol,
                code: currencyCode,
                flag: ""
            )
        }
        
        if let matched = currencies.first(where: { $0.code == currencyCode }) {
            return matched
        }
        
        if !currencyCode.isEmpty {
            return Currency(
                id: nil,
                name: "",
                symbol: symbol,
                code: currencyCode,
                flag: ""
            )
        }
        
        return defaultCurrency
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
        if isFromEdit || isRenew{
            let renewalReminder = globalSubscriptionData?.renewalReminder ?? []
            if let first = renewalReminder.first {
                let stripped = first.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "d", with: "")
                reminderDays = Int(stripped) ?? 0
            } else {
                reminderDays = 3
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
        if fromEmailSync{
            AppIntentRouter.shared.pop(count: 2)
        }else{
            AppIntentRouter.shared.pop()
        }
    }
    
    private func infoButtonAction() {
    }
    
    private func currencySelection() {
       /* hideKeyboard()
        handleDone()
        if commonApiVM.currencyResponse != nil {
            showCurrencySheet = true
        }else{
            commonApiVM.getCurrencies()
        }*/
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showCurrencySheet.toggle()
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
        let val = reminderDays == 0 ? "0d" : "-\(reminderDays)d"
        renewalReminder.append(val)
        renewalReminderValue = reminderDays == 0 ? "Off" : "\(reminderDays) days before renewal"
        
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
    @EnvironmentObject var themeManager: ThemeManager
    
    var masked: String {
        String(repeating: "•", count: ccv.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(title ?? ""))
                .font(.jetBrainsMedium(11))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
            HStack{
                SecureField(LocalizedStringKey(placeHolder ?? ""), text: $ccv)
                    .keyboardType(.numberPad)
                    .padding(6)
                    .textContentType(.oneTimeCode)
                    .disableAutocorrection(true)
                    .onChange(of: ccv) { newValue in
                        filterDigitsAndLimit(maxDigits: maxDigits)
                    }
                    .font(.geistRegular(15))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                
            }
            .padding(16)
            .frame(height: 52)
            .background(themeManager.white_white4)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
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
    var isPayment       = false
    var isDate          = false
    var isCardNo        = false
    var isCurrency      = false
    var currencySymbol  = ""
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(LocalizedStringKey(title ?? ""))
                .font(.jetBrainsMedium(11))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundStyle(themeManager.textPrimaryLight6_dark62)
                .padding(.bottom, 5)
            
            HStack{
                if isDate || isPayment{
                    Image(image ?? "")
                        .renderingMode(.template)
                        .foregroundStyle(themeManager.accentTextColor)
                }else{
                    if !isCurrency{
                        Image(image ?? "")
                            .renderingMode(.template)
                            .foregroundStyle(.textPrimary0E101AF4F1FB.opacity(0.6) )
                    }
                }
                
                if isCurrency{
                    HStack(spacing: 10){
                        Text(LocalizedStringKey(currencySymbol))
                            .multilineTextAlignment(.leading)
                            .font(.geistBold(15))
                            .foregroundColor(.textPrimary0E101AF4F1FB)
                        
                        if textValue != ""
                        {
                            Text(LocalizedStringKey(textValue ?? ""))
                                .multilineTextAlignment(.leading)
                                .font(isCurrency ? .geistBold(15) : .geistRegular(15))
                                .foregroundColor(.textPrimary0E101AF4F1FB)
                        }
                        else{
                            Text(LocalizedStringKey(placeHolder ?? ""))
                                .multilineTextAlignment(.leading)
                                .font(.geistRegular(15))
                                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        }
                        
                        Spacer()
                    }
                }
                
                if isText == true {
                    if isDate{
                        if text != ""
                        {
                            Text(text)
                                .padding(6)
                                .multilineTextAlignment(.leading)
                                .font(.geistRegular(15))
                                .foregroundStyle(
                                    Color.textPrimary0E101AF4F1FB
                                )
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                        else{
                            Text(LocalizedStringKey(placeHolder ?? ""))
                                .padding(6)
                                .multilineTextAlignment(.leading)
                                .font(.geistRegular(15))
                                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                .frame(maxWidth:.infinity, alignment: .leading)
                        }
                    }else{
                        if !isCurrency{
                            if textValue != ""
                            {
                                Text(LocalizedStringKey(textValue ?? ""))
                                    .padding(isCurrency ? 0 : 6)
                                    .multilineTextAlignment(.leading)
                                    .font(isCurrency ? .geistBold(15) : .geistRegular(15))
                                    .foregroundColor(.textPrimary0E101AF4F1FB)
                                    .frame(maxWidth:.infinity, alignment: .leading)
                            }
                            else{
                                Text(LocalizedStringKey(placeHolder ?? ""))
                                    .padding(6)
                                    .multilineTextAlignment(.leading)
                                    .font(.geistRegular(15))
                                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                    .frame(maxWidth:.infinity, alignment: .leading)
                            }
                        }
                    }
                }
                else{
                    if isNumberPad{
                        HStack{
                            if maxDigits == 4{
                                Text("•••• ••••")
                                    .font(.geistRegular(14))
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                    )
                            }
                            TextField(LocalizedStringKey(maxDigits == 4 ? "" : placeHolder ?? ""), text: $text)
                                .keyboardType(isNumberPad == true ? .decimalPad : .default)
                                .keyboardType(.default)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.leading)
                                .font(.geistRegular(15))
                                .foregroundColor(.textPrimary0E101AF4F1FB)
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
                                Text("4829")
                                    .font(.geistRegular(14))
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                    )
                            }
                            TextField(LocalizedStringKey(maxDigits == 4 ? "" : placeHolder ?? ""), text: $text)
                                .keyboardType(isNumberPad == true ? .numberPad : .default)
                                .keyboardType(.default)
                                .autocapitalization(.none)
                                .multilineTextAlignment(.leading)
                                .font(.geistRegular(15))
                                .foregroundColor(.textPrimary0E101AF4F1FB)
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
            .background(themeManager.white_white4)
            .overlay {
                
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color.textPrimary0E101AF4F1FB
                            .opacity(0.08),
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
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
    @EnvironmentObject var themeManager : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
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
                                //                                DashedHorizontalDivider()
                                Divider()
                                    .overlay(themeManager.textPrimaryLight8_white8)
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
            RoundedRectangle(cornerRadius: 14)
                .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
        )
        .background(themeManager.white_white4)
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
    var borderColor     = true
    var isService       = false
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
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Title
            Text(LocalizedStringKey(title ?? ""))
                .font(.jetBrainsMedium(11))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
            
            // MARK: - TextField Area
            HStack {
                if isNumberPad{
                    //                    Text(currency ?? "" == "" ? Constants.shared.currencySymbol : currency ?? "")
                    //                        .foregroundStyle(Color.neutral400)
                    //                        .font(.appRegular(24))
                    Image(image ?? "")
                }else{
                    Image(image ?? "")
                }
                TextField(LocalizedStringKey(placeHolder ?? ""), text: $text)
                    .keyboardType(isNumberPad ? .decimalPad : .default)
                    .autocapitalization(.none)
                    .font(.geistRegular(15))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
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
            .background(themeManager.white_white4)
            .cornerRadius(14)
            .overlay(
                selectionFieldBorderView
                //                RoundedRectangle(cornerRadius: 14)
                //                //                    .stroke(.neutral300Border, lineWidth: 1)
                //                    .stroke(borderColor ? themeManager.textPrimaryLight8_white8 : .red, lineWidth: borderColor ? 1 : 2)
            )
            
            // MARK: - Suggestion List
            if showSuggestions {
                if !isService{
                    suggestionList
                        .padding(.top, 10)
                }else if isService{
                    if text.count < 3{
                        suggestionList
                            .padding(.top, 10)
                    }
                }
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
                                    .foregroundColor(.textPrimary0E101AF4F1FB)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                text = displayKey(item)
                                closeSuggestions()
                            }
                            if index < filtered.count - 1 {
                                Divider()
                                    .overlay(themeManager.textPrimaryLight8_white8)
                                    .padding(.horizontal, -30)
                                //                                DashedHorizontalDivider()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                //                .padding(.bottom, 10)
            }
            .frame(height: height)
            .clipped()
        }
        .padding(.horizontal, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
        )
        .background(themeManager.white_white4)
        .cornerRadius(14)
    }
    
    private func closeSuggestions() {
        DispatchQueue.main.async {
            isFocused = false
            activeField = nil
        }
    }
    
    @ViewBuilder
    private var selectionFieldBorderView: some View {
        if isFocused{
            themeManager.selectionFieldBorder
        }else{
            //            RoundedRectangle(cornerRadius: 14)
            //                .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor ? themeManager.textPrimaryLight8_white8 : .red, lineWidth: borderColor ? 1 : 2)
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
    @EnvironmentObject var themeManager         : ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            Text(LocalizedStringKey(title ?? ""))
                .font(.jetBrainsMedium(11))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                .padding(.bottom, 8)
                .frame(maxWidth:.infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 0) {
                
                if type == .reminders {
                    remindersStack
                        .background(.clear)
                } else {
                    defaultList
                        .background(.clear)
                }
                
                if addMore == true
                {
                    if type != .reminders{
                        if data.count != 0 {
                            Divider()
                                .overlay(themeManager.textPrimaryLight8_white8)
                        }
                    }else{
                        Divider()
                            .overlay(themeManager.textPrimaryLight8_white8)
                    }
                    VStack(alignment: .center, spacing: 0) {
                        Button(action: addMoreAction) {
                            HStack(spacing: 8) {
                                Image("AddMore")
                                    .renderingMode(.template)
                                    .foregroundStyle(themeManager.accentTextColor)
                                    .frame(width: 20, height: 20)
                                Text(LocalizedStringKey(type == .cards ? "Add New Card" : "Add New Member"))
                                    .font(.geistRegular(15))
                                    .foregroundColor(themeManager.accentTextColor)
                            }
                            .frame(maxWidth:.infinity, alignment: .center)
                            .frame(height: 52)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.clear)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
            )
            .background(themeManager.white_white4)
            .cornerRadius(14)
        }
        .padding(5)
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showNewCardSheet = false
        }
        /*.sheet(isPresented: $openFamilyMemberSheet) {
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
        }*/
    }
    
    private var defaultList: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, objc in
                VStack(spacing: 0) {
                    rowView(for: objc, at: index)
                    
                    if index < data.count - 1 {
                        Divider()
                            .overlay(themeManager.textPrimaryLight8_white8)
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
                            .overlay(themeManager.textPrimaryLight8_white8)
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
                //showNewCardSheet = true
                
                AppIntentRouter.shared.navigate(to: .addNewCardSheet(shouldCallAPI: shouldCallAPI))
                
            }
        }else if type == .relations{
           // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              //  openFamilyMemberSheet = true
                
                AppIntentRouter.shared.navigate(to: .addFamilyMemberBottomSheet(header: "Add family member", description: "Add a family member to manage and share plans together.", buttonName: "Save", selectedCountry: nil))
            //}
        }
    }
}

//MARK: - BillingCycleItem
struct BillingCycleItem: View {
    var title           : String?
    var subtitle        : String?
    var isSelected      : Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(isSelected == true ? "SelectedRadio" : "UnSelectedRadio")
                Text(LocalizedStringKey(title ?? ""))
                    .font(.geistRegular(15))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
            }
            Spacer()
            Text(LocalizedStringKey(subtitle ?? ""))
                .font(.geistRegular(15))
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
        .frame(height: 52)
        .background(themeManager.white_white4)
    }
}

//MARK: - SubscriptionItem
struct SubscriptionItem: View {
    var title                   : String?
    var subtitle                : String?
    var isSelected              : Bool = false
    var isSubTitlePresent       : Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            if isSelected{
                Image(isSelected == true ? "SelectedRadio" : "UnSelectedRadio")
                    .renderingMode(.template)
                    .foregroundStyle(themeManager.accentGradient)
            }else{
                Image("UnSelectedRadio")
            }
            Text(LocalizedStringKey(title ?? ""))
                .font(.geistRegular(15))
                .foregroundColor(.textPrimary0E101AF4F1FB)
            if isSubTitlePresent == true {
                Text("**** **** **** \(subtitle ?? "")")
                    .font(.geistRegular(15))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    .multilineTextAlignment(.trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 52)
        .background(themeManager.white_white4)
    }
}

//MARK: - ReminderItem
struct ReminderItem: View {
    var title                           : String?
    var isSelected                      : Bool = false
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(isSelected ? themeManager.accentGradient : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 22, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(isSelected ? Color.clear : themeManager.textPrimaryLight14_white14, lineWidth: 1.5)
                    )
                    .shadow(color: themeManager.accentTextColor, radius: 4,x: 0,y: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            //            Image(isSelected == true ? "Checkmark" : "UnCheckmark")
            Text(LocalizedStringKey(title ?? ""))
                .font(.geistRegular(15))
                .foregroundColor(.textPrimary0E101AF4F1FB)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 52)
        .background(themeManager.white_white4)
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

//MARK: - Match card view
extension ManualEntryView {
    @ViewBuilder
    var matchCard: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // MARK: Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(themeManager.accentGradient)
                    .shadow(
                        color: themeManager.selectedAccent.senColor
                            .opacity(0.55),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
                
                Image("sparkles")
                    .frame(width: 16, height: 16)
            }
            .frame(width: 36, height: 36)
            
            // MARK: Content
            VStack(alignment: .leading, spacing: 0) {
                
                // Title
                HStack(spacing: 6) {
                    let providerName = addSubscriptionVM.providerData?.providerSubscriptionPlansList?.first?.providerName ?? ""
                    let isHundredPercent = serviceName.trimmed.lowercased() == providerName.trimmed.lowercased()
                    
                    Text("Matched to \(providerName)")
                        .font(.geistSemiBold(12))
                        .foregroundStyle(
                            .textPrimary0E101AF4F1FB
                        )
                    
                    Text(isHundredPercent ? "100% MATCH" : "85% MATCH")
                        .font(.jetBrainsMedium(9))
                        .tracking(1)
                        .foregroundStyle(
                            Color.successLight0EA870
                        )
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Color.successLight0EA870
                                .opacity(0.133)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 5,
                                style: .continuous
                            )
                        )
                }
                
                // Description
                Text(getAttributedDescription())
                    .font(.geistRegular(11))
                    .lineSpacing(2)
                    .padding(.top, 2)
                
                // Plans
                let plans = getAllPlans()
                ScrollView(.horizontal, showsIndicators: false) {
                    if !plans.isEmpty {
                        let row1 = plans.enumerated().filter { $0.offset % 3 == 0 }.map { $0.element }
                        let row2 = plans.enumerated().filter { $0.offset % 3 == 1 }.map { $0.element }
                        let row3 = plans.enumerated().filter { $0.offset % 3 == 2 }.map { $0.element }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            if !row1.isEmpty {
                                HStack(spacing: 6) {
                                    ForEach(row1, id: \.self) { plan in
                                        planPillButton(for: plan)
                                    }
                                }
                            }
                            if !row2.isEmpty {
                                HStack(spacing: 6) {
                                    ForEach(row2, id: \.self) { plan in
                                        planPillButton(for: plan)
                                    }
                                }
                            }
                            if !row3.isEmpty {
                                HStack(spacing: 6) {
                                    ForEach(row3, id: \.self) { plan in
                                        planPillButton(for: plan)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        // Fallback
                        HStack(spacing: 6) {
                            Button(action: {
                                planType = "Free"
                                selectedPlanType = "Free"
                                amount = "0.0"
                                isAmountError = false
                            }) {
                                PlanPillView(
                                    title: "Free",
                                    price: "\(selectedCurrency?.symbol ?? "")0.00"
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                planType = "Basic"
                                selectedPlanType = "Basic"
                                isAmountError = false
                            }) {
                                PlanPillView(
                                    title: "Basic",
                                    price: "\(selectedCurrency?.symbol ?? "")-"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(themeManager.accentGradient.opacity(0.133))
        .overlay {
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                themeManager.selectedAccent.senColor
                    .opacity(0.333),
                lineWidth: 1
            )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
    }
    
    
    @ViewBuilder
    private func planPillButton(for plan: ProviderSubscriptionPlan) -> some View {
        Button(action: {
            planType = plan.planName ?? ""
            selectedPlanType = plan.planName ?? ""
            if let price = plan.price {
                amount = String(format: "%.2f", price)
            }
            if let cycle = plan.billingCycle, !cycle.isEmpty {
                selectedBilling = cycle
            }
            if let curr = plan.currencyCode {
                // find currency
                if let currencies = commonApiVM.currencyResponse {
                    selectedCurrency = currencies.first(where: { $0.code == curr })
                    currency = curr
                }
            }
            
            // Update Next Charge Date if billing cycle changes
            if selectedBilling != nil && selectedBilling != "" {
                if isRenew {
                    let baseDate = Date()
                    chargeDate = Constants.shared.getNextDateByFrequency(frequency: selectedBilling ?? "", baseDate: baseDate).formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                } else {
                    chargeDate = Constants.shared.getNextDateByFrequency(frequency: selectedBilling ?? "").formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                }
            }
            
            // Also set category and service name
            if let pName = addSubscriptionVM.providerData?.providerSubscriptionPlansList?.first?.providerName, !pName.isEmpty {
                serviceLastActionText = pName.trimmed // Update this first!
                serviceName = pName
            }
            if let catName = addSubscriptionVM.providerData?.categoryName {
                category = catName
                if let categories = commonApiVM.categoriesResponse {
                    selectedCategory = categories.first(where: { $0.name?.lowercased() == catName.lowercased()})
                }
            }
            
            isAmountError = false
        }) {
            PlanPillView(
                title: plan.planName ?? "",
                price: "\(plan.currencySymbol ?? "")\(plan.price ?? 0.0)"
            )
        }
        .buttonStyle(.plain)
    }
    
    private func getAttributedDescription() -> AttributedString {
        var result = AttributedString("Auto-filled category ")
        result.foregroundColor = themeManager.textPrimaryLight6_dark62
        
        var cat = AttributedString(addSubscriptionVM.providerData?.categoryName ?? category)
        cat.font = .geistSemiBold(11)
        cat.foregroundColor = .textPrimary0E101AF4F1FB
        
        var cycle = AttributedString(", cycle ")
        cycle.foregroundColor = themeManager.textPrimaryLight6_dark62
        
        var bil = AttributedString(selectedBilling ?? "")
        bil.font = .geistSemiBold(11)
        bil.foregroundColor = .textPrimary0E101AF4F1FB
        
        var currencyAttr = AttributedString(", currency ")
        currencyAttr.foregroundColor = themeManager.textPrimaryLight6_dark62
        
        var cur = AttributedString(selectedCurrency?.code ?? "")
        cur.font = .geistSemiBold(11)
        cur.foregroundColor = .textPrimary0E101AF4F1FB
        
        var dot = AttributedString(".")
        dot.foregroundColor = themeManager.textPrimaryLight6_dark62
        
        result += cat
        result += cycle
        result += bil
        result += currencyAttr
        result += cur
        result += dot
        
        return result
    }
}

//MARK: - ReminderSliderView
struct ReminderSliderView: View {
    @Binding var reminderDays: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("REMIND ME BEFORE RENEWAL")
                .font(.jetBrainsMedium(11))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
            
            VStack(spacing: 16) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(reminderDays)")
                        .font(.appSemiBold(22))
                        .foregroundColor(.textPrimary0E101AF4F1FB)
                    
                    Text("days before")
                        .font(.geistMedium(11))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .padding(.bottom, 4)
                    
                    Spacer()
                    
                    //                    Text("0 = off")
                    //                        .font(.jetBrainsMedium(11))
                    //                        .tracking(1)
                    //                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    //                        .padding(.bottom, 4)
                }
                
                GeometryReader { geometry in
                    let sliderWidth = geometry.size.width
                    let thumbWidth: CGFloat = 20
                    let trackHeight: CGFloat = 8
                    let range: ClosedRange<Double> = 0...14
                    let percentage = CGFloat((Double(reminderDays) - range.lowerBound) / (range.upperBound - range.lowerBound))
                    let activeWidth = percentage * (sliderWidth - thumbWidth)
                    
                    ZStack(alignment: .leading) {
                        // Background Track
                        RoundedRectangle(cornerRadius: trackHeight / 2)
                            .fill(themeManager.textPrimaryLight8_white8)
                            .frame(height: trackHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: trackHeight / 2)
                                    .stroke(
                                        themeManager.black_white.opacity(0.08),
                                        lineWidth: 1
                                    )
                            )
                        
                        
                        // Active Track
                        RoundedRectangle(cornerRadius: trackHeight / 2)
                            .fill(themeManager.accentGradient)
                            .frame(width: activeWidth + thumbWidth / 2, height: trackHeight)
                        
                        // Thumb
                        RoundedRectangle(cornerRadius: thumbWidth/2)
                            .fill(themeManager.accentGradient)
                            .frame(width: thumbWidth, height: thumbWidth)
                            .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                            .offset(x: activeWidth)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        let x = min(max(0, gesture.location.x - thumbWidth / 2), sliderWidth - thumbWidth)
                                        let newPercentage = Double(x / (sliderWidth - thumbWidth))
                                        let newValue = newPercentage * (range.upperBound - range.lowerBound) + range.lowerBound
                                        reminderDays = Int(round(newValue))
                                    }
                            )
                    }
                    .frame(height: 16)
                }
                .frame(height: 16)
                .padding(.bottom, 4)
            }
            .padding(16)
            .background(themeManager.white_white4)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
            )
            .cornerRadius(14)
        }
        .padding(5)
    }
}
