//
//  SubscriptionPreviewView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 11/11/25.
//

/* Review screens cases
 Confidence Assumed will come only for currency
 
 1. When the plan type is changed, both the amount and Billing cycle and currency and currency symbol (If plans are not related to the selected currency, then we will get other country plans then currency will change accordingly.) should be updated accordingly only if there are empty.
 2. When billing cycle is updated, then next charge date and amount should be updated only if there are empty.
 3. When the amount is changed, both the plan type and the billing cycle and currency and currency symbol (If plans are not related to the selected currency, then we will get other country plans then currency will change accordingly.) should be updated accordingly if plan type is empty.
 4. If there are no plans for particular service, the available plan types are Free Plan and Basic Plan. When the user selects either one, the billing cycle should be displayed as Monthly by default.
 5. If Plan type is free then amount should be 0 in manual and review screens.
 6. If service name is empty or if service name changes then need to clear the data and need to clear the provider list.
 7. If currency is changed no need to clear the data.
 8. Amount suggestions and billing cycles list will be filtered based on plan type.
 */

import SwiftUI
import SDWebImageSwiftUI

var globalSubscriptionData                      : SubscriptionData?
var originalImage                               : UIImage? = nil
var isCurrencyUpdateGlobal                      = false

struct SubscriptionPreviewView: View {
    
    //MARK: - Properties
    @State var isFromImage                      : Bool = false
    @State var isFromEmail                      : Bool = false
    @State var subscriptionsData                : [SubscriptionData]?
    @State var numberOfSubscriptions            : Int = 0
    @State var currentSubscriptions             : Int = 1
    @State var subscriptionData                 : SubscriptionData?
    @State var content                          : String = ""
    @State var confidenceStr                    : String = ""
    @State var colorValue                       : Color?
    var confidence                              : Double = 0.0
    @State var initials                         : String  = ""
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @StateObject var subscriptionPreviewVM      = SubscriptionPreviewViewModel()
    var audioURL                                : URL? = nil
    @StateObject private var playerManager      = AudioRecorderManager()
    @Environment(\.dismiss) private var dismiss
    
    @State var showDiscardPopup                 : Bool = false
    @State var showImagePopup                   : Bool = false
    @State var showServiceBottom                : Bool = false
    @State var showAmountBottom                 : Bool = false
    @State var showNextChargeDateBottom         : Bool = false
    @State var showCurrencyBottom               : Bool = false
    @State var showCategoryBottom               : Bool = false
    @State var showPlanTypeBottom               : Bool = false
    @State var showBillingCycleBottom           : Bool = false
    
    @StateObject var manualEntryVM              = ManualEntryViewModel()
    
    @State var fillRatio                        : CGFloat = 0.0
    @State var isInitialService                 = true
    @State var isInitialCurrency                = true
    @State var isServiceChanged                 = false
    @State private var previousBillingCycle     : String?
    @State private var deleteSheetHeight        : CGFloat = .zero
    
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
                    Text("Review entry \(currentSubscriptions) of \(numberOfSubscriptions)")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    HStack {
                        // MARK: SubTitle
                        Text("Validate extracted data")
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutral500)
                        
                        if isFromImage == true {
                            Spacer()
                            Button(action: showImage) {
                                HStack(spacing: 4) {
                                    Image("imageicon")
                                        .frame(width: 20, height: 20)
                                    Text("Original")
                                        .font(.appRegular(14))
                                        .foregroundColor(Color.blueMain700)
                                        .underline(true, color: Color.blueMain700)
                                }
                            }
                            .sheet(isPresented: $showImagePopup) {
                                if let image = originalImage {
                                    VStack(spacing: 0) {
                                        OriginalImageView(image: image)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .background(Color.clear)
                                    .presentationDetents([.height(imageHeightForSheet(image))])
                                    .presentationDragIndicator(.hidden)
                                    .ignoresSafeArea(edges: .bottom)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            ScrollView {
                VStack(spacing: 24) {
                    if isFromImage == false && isFromEmail == false && audioURL != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Original Content")
                                .foregroundColor(Color.underlineGray)
                                .font(.appRegular(18))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 16)
                                .padding(.horizontal, 16)
                            if let url = audioURL{
                                VoicePlayerUI(audioManager: playerManager, audioURL: url)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom,16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color.neutral300Border,
                                    style: StrokeStyle(lineWidth: 1, dash: [4])
                                )
                        )
                        .background(Color.whiteNeutralCardBG)
                        .cornerRadius(12)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Extracted Details")
                                .font(.appRegular(18))
                                .foregroundColor(Color.buttonsText)
                            Spacer()
                            Button(action: onEditAction) {
                                Text("Edit")
                                    .font(.appBold(18))
                                    .foregroundColor(.underlineGray)
                            }
                            .frame(width: 40, alignment: .trailing)
                        }
                        .frame(height: 28)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 16) {
                                
                                //MARK: Service
                                SubscriptionDetailsItem(title: "Service", value: subscriptionData?.serviceName ?? "", confidence: subscriptionData?.serviceNameConfidence ?? 0.0)
                                    .onTapGesture {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showServiceBottom = true
                                        }
                                    }
                                    .sheet(isPresented: $showServiceBottom, onDismiss:{
                                        print("sheet dismissed")
                                    }) {
                                        ReviewExtractedDetailsView(onDelegate: {
                                            print("clicked done")
                                            isServiceChanged = true
                                        },
                                                                   detailType   : ReviewExtractedType.service,
                                                                   confidence   : subscriptionData?.serviceNameConfidence ?? 0.0,
                                                                   extractedData: subscriptionData,
                                                                   servicesList : manualEntryVM.servicesList ?? [])
                                        .id(ReviewExtractedType.service)
                                        .presentationDragIndicator(.hidden)
                                        .presentationDetents([.height(400)])
                                    }
                                    .onChange(of: subscriptionData?.serviceName) { newValue in
                                        guard
                                            let serviceName = newValue,
                                            !serviceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        else {
                                            return
                                        }
                                        if isInitialService{
                                            isInitialService = false
                                        }else{
                                            fetchProviderDataApi()
                                        }
                                    }
                                
                                //MARK: Amount
                                SubscriptionDetailsItem(title       : "Amount",
                                                        value       : "\(subscriptionData?.currencySymbol ?? "")\(subscriptionData?.amount ?? 0.0)",
                                                        confidence  : subscriptionData?.amountConfidence ?? 0.0)
                                .onTapGesture {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showAmountBottom = true
                                    }
                                }
                                .sheet(isPresented: $showAmountBottom) {
                                    NavigationStack {
                                        ReviewExtractedDetailsView(onDelegate: {
                                        },
                                                                   detailType   : ReviewExtractedType.amount,
                                                                   confidence   : subscriptionData?.amountConfidence ?? 0.0,
                                                                   extractedData: subscriptionData,
                                                                   providerPlansList : manualEntryVM.providerData?.providerSubscriptionPlansList)
                                        .id(ReviewExtractedType.amount)
                                        .presentationDragIndicator(.hidden)
                                        .presentationDetents([.height(400)])                                        }
                                }
                            }
                            
                            HStack(spacing: 16) {
                                
                                //MARK: Next Charge Date
                                SubscriptionDetailsItem(title: "Next Charge Date", value: (subscriptionData?.nextPaymentDate ?? "").formattedDate(), confidence: subscriptionData?.nextPaymentDateConfidence ?? 0.0)
                                    .onTapGesture {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showNextChargeDateBottom = true
                                        }
                                    }
                                    .sheet(isPresented: $showNextChargeDateBottom) {
                                        ReviewExtractedDetailsView(onDelegate: {
                                        },
                                                                   detailType   : ReviewExtractedType.nextChargeDate,
                                                                   confidence   : subscriptionData?.nextPaymentDateConfidence ?? 0.0,
                                                                   extractedData: subscriptionData)
                                        .id(ReviewExtractedType.nextChargeDate)
                                        .presentationDragIndicator(.hidden)
                                        .presentationDetents([.height(400)])
                                    }
                                
                                //MARK: Currency
                                if subscriptionData?.currency == nil || subscriptionData?.currency ?? "" == "" || subscriptionData?.currencyConfidence ?? 0.0 == 0.0{
                                    SubscriptionDetailsItem(title: "Currency", value: subscriptionData?.currency ?? Constants.shared.currencyCode, confidence: subscriptionData?.currencyConfidence ?? 0.0, isAssumed: true)
                                        .onTapGesture {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                showCurrencyBottom = true
                                            }
                                        }
                                }
                                else{
                                    SubscriptionDetailsItem(title: "Currency", value: subscriptionData?.currency ?? "", confidence: subscriptionData?.currencyConfidence ?? 0.0)
                                        .onTapGesture {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                showCurrencyBottom = true
                                            }
                                        }
                                }
                            }
                            
                            HStack(spacing: 16) {
                                //MARK: Category
                                SubscriptionDetailsItem(title: "Category", value: subscriptionData?.categoryName ?? "", confidence: subscriptionData?.categoryConfidence ?? 0.0)
                                    .onTapGesture {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showCategoryBottom = true
                                        }
                                    }
                                    .sheet(isPresented: $showCategoryBottom) {
                                        ReviewExtractedDetailsView(onDelegate: {
                                        },
                                                                   detailType   : ReviewExtractedType.category,
                                                                   confidence   : subscriptionData?.categoryConfidence ?? 0.0,
                                                                   extractedData: subscriptionData)
                                        .id(ReviewExtractedType.category)
                                        .presentationDragIndicator(.hidden)
                                        .presentationDetents([.height(400)])
                                    }
                                
                                //MARK: Plan Type
                                SubscriptionDetailsItem(title: "Plan Type", value: subscriptionData?.subscriptionType ?? "", confidence: subscriptionData?.subscriptionTypeConfidence ?? 0.0)
                                    .onTapGesture {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showPlanTypeBottom = true
                                        }
                                    }
                            }
                            
                            //MARK: Billing Cycle
                            SubscriptionDetailsItem(title: "Billing Cycle", value: subscriptionData?.billingCycle ?? "", confidence: subscriptionData?.billingCycleConfidence ?? 0.0)
                                .onTapGesture {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showBillingCycleBottom = true
                                    }
                                }
                                .sheet(isPresented: $showBillingCycleBottom) {
                                    ReviewExtractedDetailsView(onDelegate: {
                                    },
                                                               detailType           : ReviewExtractedType.billingCycle,
                                                               confidence           : subscriptionData?.billingCycleConfidence ?? 0.0,
                                                               extractedData        : subscriptionData,
                                                               providerPlansList    : manualEntryVM.providerData?.providerSubscriptionPlansList)
                                    .id(ReviewExtractedType.billingCycle)
                                    .presentationDragIndicator(.hidden)
                                    .presentationDetents([.height(400)])
                                }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Subscription Match")
                                .font(.appRegular(18))
                                .foregroundColor(.underlineGray)
                            Spacer()
                            Button(action: onViewAction) {
                                Text("View")
                                    .font(.appBold(18))
                                    .foregroundColor(Color.buttonsText)
                            }
                            .frame(width: 40, alignment: .trailing)
                        }
                        .frame(height: 28)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                AvatarView(serviceName: subscriptionData?.serviceName ?? "", serviceLogo: subscriptionData?.serviceLogo ?? "", size: 34, fontSize: 16, fromPreview: true)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(subscriptionData?.serviceName ?? "") \(subscriptionData?.subscriptionType ?? "")")
                                        .font(.appRegular(14))
                                        .foregroundColor(.neutralMain700)
                                    Text(String(format: "%@ • %@%.2f", subscriptionData?.billingCycle ?? "",subscriptionData?.currencySymbol ?? "",subscriptionData?.amount ?? 0.0))
                                        .font(.appRegular(12))
                                        .foregroundColor(.neutral500)
                                }
                                Spacer()
                              
                                ConfidenceBarView(
                                    text        : confidenceStr,
                                    color       : colorValue ?? .confidenceBlue.opacity(0.2),
                                    fillRatio   : fillRatio
                                )
                                .frame(width: 140)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text("Amount:")
                                        .font(.appRegular(14))
                                        .foregroundColor(.neutral500)
                                    Spacer()
                                    Text(String(format: "%@%.2f",subscriptionData?.currencySymbol ?? "",subscriptionData?.amount ?? 0.0))
                                        .font(.appBold(14))
                                        .foregroundColor(.blueMain700)
                                }
                                .frame(height: 20)
                                
                                HStack(spacing: 8) {
                                    Text("Next Charge Date:")
                                        .font(.appRegular(14))
                                        .foregroundColor(.neutral500)
                                    Spacer()
                                    Text("\(subscriptionData?.nextPaymentDate ?? "")".formattedDate())
                                        .font(.appBold(14))
                                        .foregroundColor(.blueMain700)
                                }
                                .frame(height: 20)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neutral300Border, lineWidth: 1)
                        )
                        .background(Color.whiteNeutralCardBG)
                        .cornerRadius(12)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                
                VStack(spacing: 10) {
                    if currentSubscriptions == 1
                    {
                        if currentSubscriptions == numberOfSubscriptions
                        {
                            CustomButton(title: "Save", height:50, action: onSaveAction)
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                        }
                        else{
                            CustomButton(title: "Next", height:50, action: onNextAction)
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                        }
                    }
                    else{
                        if currentSubscriptions == numberOfSubscriptions
                        {
                            HStack(spacing: 0) {
                                GradientBorderButton(title: "Previous", action:onPreviousAction, backgroundColor:.whiteBlack)
                                    .padding(.horizontal)
                                CustomButton(title: "Save All", height:50, action: onSaveAction)
                                    .padding(.horizontal)
                            }
                            .padding(.bottom, 24)
                        }
                        else{
                            HStack(spacing: 0)  {
                                GradientBorderButton(title: "Previous", action:onPreviousAction, backgroundColor:.whiteBlack)
                                    .padding(.horizontal)
                                CustomButton(title: "Next", height:50, action: onNextAction)
                                    .padding(.horizontal)
                            }
                            .padding(.bottom, 24)
                        }
                    }
                    
                    Button(action: onDiscardAction) {
                        HStack {
                            Image("IconCross")
                                .frame(width: 20, height: 20)
                            Text("Discard Entry")
                                .font(.appRegular(14))
                                .foregroundColor(Color.disCardRed)
                        }
                    }
                    .onChange(of: subscriptionPreviewVM.isDiscardSuccess) { newValue in
                        if newValue == true {
                            handleLocalDiscard()
                            subscriptionPreviewVM.isDiscardSuccess = false
                        }
                    }
                    .sheet(isPresented: $showDiscardPopup) {
                        InfoAlertSheet(
                            onDelegate: {
                                performDeleteAction()
                            }, title    : "Are you sure you want to discard the entry?\nData will be permanently deleted",
                            subTitle    : "",
                            imageName   : "infoIcon",
                            buttonIcon  : "deleteIcon",
                            buttonTitle : "Delete Entry"
                        )
                        .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                            if height > 0 {
                                deleteSheetHeight = height
                            }
                        }
                        .presentationDragIndicator(.hidden)
                        .presentationDetents([.height(deleteSheetHeight)])
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 6)
                .padding(.vertical, 24)
            }
        }
        .padding(.top, 10)
        .background(.neutralBg100)
        .navigationBarBackButtonHidden(true)
        //MARK: OnAppear
        .onAppear{
            numberOfSubscriptions = subscriptionsData?.count ?? 0
            getSubDetails()
            if !isFromImage{
                guard let url = audioURL else {
                    return
                }
                playerManager.setDuration(url: url)
            }
            updateSubDetails()
            manualEntryVM.getServiceProvidersList()
            if subscriptionData?.serviceName ?? "" != ""{
                fetchProviderDataApi()
            }
        }
        .onChange(of: globalSubscriptionData) { _ in updateSubDetails() }
        .onChange(of: commonApiVM.currencyResponse) { _ in getSubDetails() }
        .onChange(of: subscriptionPreviewVM.isEntrySuccess) { _ in
            self.addSubApiResponseHandling()
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showImagePopup = false
            showDiscardPopup = false
        }
        //MARK: Currency bottom sheet
        .sheet(isPresented: $showCurrencyBottom) {
            ReviewExtractedDetailsView(onDelegate: {
                handleCurrencySelection()
            },
                                       detailType   : ReviewExtractedType.currency,
                                       confidence   : subscriptionData?.currencyConfidence ?? 0.0,
                                       isAssumed    : (subscriptionData?.currency ?? "" == "" || subscriptionData?.currencyConfidence ?? 0.0 == 0.0) ? true : false,
                                       extractedData: subscriptionData)
            .id(ReviewExtractedType.currency)
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(400)])
        }
        //MARK: plan type bottom sheet
        .sheet(isPresented: $showPlanTypeBottom, onDismiss:{
            print("sheet plan type dismissed")
        }) {
            ReviewExtractedDetailsView(onDelegate: {
            },
                                       detailType           : ReviewExtractedType.planType,
                                       confidence           : subscriptionData?.subscriptionTypeConfidence ?? 0.0,
                                       extractedData        : subscriptionData,
                                       providerPlansList    : manualEntryVM.providerData?.providerSubscriptionPlansList)
            .id(ReviewExtractedType.planType)
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(400)])
        }
        .onChange(of: manualEntryVM.providerData) { _ in updateProviderData() }
        .onChange(of: subscriptionPreviewVM.isDiscardSuccess) { newValue in
            if newValue == true {
                handleLocalDiscard()
                subscriptionPreviewVM.isDiscardSuccess = false
            }
        }
    }
    
    //MARK: - User defined methods
    //MARK: addSubApiRespons
    private func addSubApiResponseHandling() {
        if subscriptionPreviewVM.isEntrySuccess == true{
            if subscriptionPreviewVM.addSubscriptionResponse != nil{
                
                let duplicates =  subscriptionPreviewVM.addSubscriptionResponse!.duplicates ?? []
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
                    isFromAdd = true
                    playerManager.pausePlayback()
                    AppIntentRouter.shared.navigate(to: .duplicateSubscriptionsView(duplicateSubsList: updatedDuplicates, isFromEmail: isFromEmail))
                }
                else{
                    playerManager.pausePlayback()
                    AppIntentRouter.shared.navigate(to: .subscriptionsListView())
                }
            }
            else{
                playerManager.pausePlayback()
                AppIntentRouter.shared.navigate(to: .subscriptionsListView())
            }
        }
    }
    
    private func imageHeightForSheet(_ image: UIImage) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 40
        let aspectRatio = image.size.height / image.size.width
        let imageHeight = screenWidth * aspectRatio
        return imageHeight + 150
    }
    
    func updateSubDetails()
    {
        if globalSubscriptionData != nil {
            subscriptionsData?[currentSubscriptions-1] = globalSubscriptionData!
            subscriptionData = globalSubscriptionData!
            getSubDetails()
        }
    }
    
    func getSubDetails()
    {
        if numberOfSubscriptions > 0
        {
            subscriptionData = subscriptionsData?[currentSubscriptions-1]
            //            subscriptionData?.billingCycle = (subscriptionData?.billingCycle == "" || subscriptionData?.billingCycle == nil) ? "Monthly" : subscriptionData?.billingCycle //no need
            let chargeDate = Constants.shared.getNextDateByFrequency(frequency: subscriptionData?.billingCycle ?? "").formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
            if subscriptionData?.nextPaymentDate == nil || subscriptionData?.nextPaymentDate == ""{
                subscriptionData?.nextPaymentDate = chargeDate
            }
            let (confidenceStr1, colorValue1, fillRatio1) =
            Constants.confidenceInfo(isAssumed: false, confidence: subscriptionData?.confidenceOverall ?? 0.0)
            confidenceStr = confidenceStr1
            colorValue = colorValue1
            fillRatio = fillRatio1
            updateCountryAndCurrency()
        }
    }
    
    //MARK: updateCountryAndCurrency
    func updateCountryAndCurrency() {
        if let currencies = commonApiVM.currencyResponse {
            let selectedCurrency = currencies.first(where: { $0.code == subscriptionData?.currency ?? Constants.shared.currencyCode })
            if selectedCurrency?.symbol == nil || selectedCurrency?.symbol == ""{
                subscriptionData?.currencySymbol = subscriptionData?.currencySymbol
            }else{
                subscriptionData?.currencySymbol = selectedCurrency?.symbol
            }
            subscriptionsData?[currentSubscriptions-1] = subscriptionData!
        }else{
            commonApiVM.getCurrencies()
        }
    }
    
    func fetchProviderDataApi(){
        manualEntryVM.fetchProviderData(input: FetchProviderDataRequest(userId          : Constants.getUserId(),
                                                                        serviceName     : subscriptionData?.serviceName ?? "",
                                                                        currencyCode    : subscriptionData?.currency ?? "" == "" ? Constants.shared.currencyCode : subscriptionData?.currency ?? ""))
    }
    
    private func updateProviderData() {
        if isServiceChanged{
            isServiceChanged = false
            subscriptionData?.categoryName    = manualEntryVM.providerData?.categoryName ?? ""
            subscriptionData?.categoryId      = manualEntryVM.providerData?.categoryId ?? ""
            let normalizedServiceName = subscriptionData?.serviceName?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            
            let logo = manualEntryVM.servicesList?
                .first {
                    guard
                        let name = $0.name?
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased(),
                        let targetName = normalizedServiceName
                    else {
                        return false
                    }
                    
                    return name == targetName
                }?
                .logo
            
            if let logo = logo, !logo.isEmpty {
                subscriptionData?.serviceLogo = logo
            }
        }
    }
    
    private func handleCurrencySelection() {
        if isCurrencyUpdateGlobal{
            isCurrencyUpdateGlobal = false
        }else{
            if subscriptionData?.serviceName != ""{
                fetchProviderDataApi()
            }
        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        playerManager.discardAll()
        dismiss()
    }
    
    private func showImage() {
        showImagePopup = true
    }
    
    private func onEditAction() {
        if numberOfSubscriptions > 0
        {
            globalSubscriptionData = subscriptionData!
            playerManager.pausePlayback()
            AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: true, isFromEmail: isFromEmail))
        }
    }
    
    private func onViewAction() {
        if numberOfSubscriptions > 0
        {
            if subscriptionData != nil {
                subscriptionData?.notes = subscriptionData?.reason
                globalSubscriptionData = subscriptionData!
                playerManager.pausePlayback()
                AppIntentRouter.shared.navigate(to: .subscriptionMatchView(subscriptionData: subscriptionData!))
            }
        }
    }
    
    private func onNextAction() {
        playerManager.pausePlayback()
        if let errorMessage = ManualEntryValidations.shared.updateManualEntry(input: subscriptionData!) {
            ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
        }
        else{
            currentSubscriptions = currentSubscriptions + 1
            if currentSubscriptions >= numberOfSubscriptions
            {
                currentSubscriptions = numberOfSubscriptions
            }
            getSubDetails()
        }
    }
    
    private func onPreviousAction() {
        currentSubscriptions = currentSubscriptions - 1
        if currentSubscriptions <= 1
        {
            currentSubscriptions = 1
        }
        getSubDetails()
    }
    
    private func onSaveAction() {
        if numberOfSubscriptions > 0
        {
            playerManager.pausePlayback()
            if let errorMessage = ManualEntryValidations.shared.updateManualEntry(input: subscriptionData!) {
                ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
            }
            else {
                //source -> 1- manual, 2 - voice, 3 - image, 4 - email
                var source = 2
                if isFromEmail {
                    source = 4
                } else if isFromImage == true {
                    source = 3
                }
                var subsctionsArray: [ConfirmedSubscription] = []
                for i in 0..<subscriptionsData!.count
                {
                    let objc = subscriptionsData![i]
                    var currency = objc.currency ?? ""
                    if objc.currency == "" || objc.currency == nil || objc.currency == "null" {
                        currency = Constants.shared.currencyCode
                    }
                    //                    let currency = (objc.currency ?? "" == "") ? Constants.shared.currencyCode : (objc.currency ?? "")
                    let logoUrl = getFileName(from: objc.serviceLogo ?? "")
                    let subObjc = ConfirmedSubscription(serviceName         : objc.serviceName ?? "",
                                                        serviceLogo         : logoUrl,
                                                        amount              : objc.amount ?? 0.0,
                                                        currency            : currency,//objc.currency ?? "",
                                                        billingCycle        : objc.billingCycle ?? "",
                                                        nextPaymentDate     : (objc.nextPaymentDate ?? "").formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd"),
                                                        subscriptionType    : objc.subscriptionType ?? "",
                                                        paymentMethod       : objc.paymentMethodId ?? "",
                                                        paymentMethodDataId : objc.paymentMethodDataId ?? "",
                                                        category            : objc.categoryId ?? "",
                                                        subscriptionFor     : objc.subscriptionFor ?? Constants.getUserId(),
                                                        renewalReminder     : objc.renewalReminder ?? [],
                                                        notes               : objc.reason ?? "",
                                                        currencySymbol      : objc.currencySymbol ?? "",
                                                        source              : source,
                                                        sourceReference     : isFromEmail ? objc.sourceReference : nil)
                    subsctionsArray.append(subObjc)
                }
                let input = PendingSubscriptionConfirmRequest(userId: Constants.getUserId(), confirmedSubscription: subsctionsArray)
                subscriptionPreviewVM.updateSubscriptions(input: input)
            }
        }
    }
    
    private func onDiscardAction() {
        if numberOfSubscriptions > 0
        {
            playerManager.pausePlayback()
            showDiscardPopup = true
        }
    }
    
    private func performDeleteAction() {
        if isFromEmail {
            if let subId = subscriptionData?.id {
                let input = DiscardEmailSubscriptionRequest(userId          : Constants.getUserId(),
                                                            subscriptionId  : subId)
                subscriptionPreviewVM.discardEmailSubscriptionApi(input: input)
            } else {
                handleLocalDiscard()
            }
        } else {
            handleLocalDiscard()
        }
    }
    
    private func handleLocalDiscard() {
        if numberOfSubscriptions < 2
        {
            dismiss()
        }
        else{
            subscriptionsData?.remove(at: currentSubscriptions-1)
            numberOfSubscriptions = subscriptionsData?.count ?? 0
            if currentSubscriptions <= 1
            {
                currentSubscriptions = 1
            }
            if currentSubscriptions >= numberOfSubscriptions
            {
                currentSubscriptions = numberOfSubscriptions
            }
            getSubDetails()
        }
    }
}

//MARK: - ConfidenceBarView
struct ConfidenceBarView: View {
    
    let text: String
    let color: Color
    let fillRatio: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            let borderColor: Color =
            text == "------------"
            ? Color.lineGray
            : Color.confidenceBlue
            
            
            RoundedRectangle(cornerRadius: 6)
                .stroke(borderColor, lineWidth: 1)
                .frame(height: 28)
            
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(
                        width: geo.size.width * fillRatio,
                        height: 28
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(text)
                .font(.appRegular(14))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 28)
    }
}

//MARK: - SubscriptionDetailsItem
struct SubscriptionDetailsItem: View {
    var title                   : String
    var value                   : String?
    var confidence              : Double = 0.0
    var isAssumed               : Bool = false
    
    var body: some View {
        let (confidenceStr, colorValue, fillRatio) = Constants.confidenceInfo(isAssumed: isAssumed, confidence: confidence)
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 9) {
                Text(title)
                    .font(.appRegular(14))
                    .foregroundColor(.neutral500)
                
                Text(value ?? "")
                    .font(.appBold(16))
                    .foregroundColor(.neutralMain700)
                
                ConfidenceBarView(
                    text        : confidenceStr,
                    color       : colorValue,
                    fillRatio   : fillRatio
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .frame(height: 106)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(value == "" ? Color.disCardRed : Color.neutral300Border, lineWidth: 1)
        )
        .background(.whiteNeutralCardBG)
        .cornerRadius(12)
    }
}

//MARK: - VoicePlayerUI
struct VoicePlayerUI: View {
    
    @ObservedObject var audioManager: AudioRecorderManager
    @State var audioURL : URL
    
    var body: some View {
        HStack(alignment: .center,spacing: 5) {
            
            Button(action: {
                if audioManager.isPlaying {
                    audioManager.pausePlayback()
                } else {
                    audioManager.playFirstRecording(url: audioURL)
                }
            }) {
                Image(audioManager.isPlaying ? "pause_review" : "play_review")
                    .frame(width: 40, height: 40)
            }
            
            VStack{
                Spacer()
                GradientThumbSlider(
                    value: Binding(
                        get: { audioManager.currentTime },
                        set: { newValue in
                            audioManager.audioPlayer?.currentTime = newValue
                            audioManager.currentTime = newValue
                        }
                    ),
                    range: 0...audioManager.duration,
                    thumbImage: "sliderThumb"
                )
                Spacer()
            }
            
            Text("\(formatTime(TimeInterval(Int(audioManager.currentTime)))) / \(formatTime(TimeInterval(Int(audioManager.duration))))")
                .font(.appRegular(14))
                .foregroundStyle(Color.whiteBlackBGnoPic)
                .padding(.leading, 10)
            
            Spacer()
        }
    }
}
