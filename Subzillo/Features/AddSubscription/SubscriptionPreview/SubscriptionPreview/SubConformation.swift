//
//  SubConformation.swift
//  Subzillo
//
//  Created by Ratna Kavya on 22/05/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct SubConformation: View {
    
    //MARK: - Properties
    @State var isFromImage                          : Bool = false
    @State var isFromEmail                          : Bool = false
    @State var subscriptionsData                    : [SubscriptionData]?
    @State var numberOfSubscriptions                : Int = 0
    @State var currentSubscriptions                 : Int = 1
    @State var subscriptionData                     : SubscriptionData?
    @State var content                              : String = ""
    @State var confidenceStr                        : String = ""
    @State var colorValue                           : Color?
    var confidence                                  : Double = 0.0
    @State var initials                             : String  = ""
    @State private var accumulatedDuplicates        : [DuplicateDataInfo] = []
    @State private var totalInitialCount            : Int = 0
    @State private var newlyAddedSubscriptionsCount : Int = 0
    @State private var lastSavedSubscription        : SubscriptionData? = nil
    @EnvironmentObject var commonApiVM              : CommonAPIViewModel
    @StateObject var subscriptionPreviewVM          = SubscriptionPreviewViewModel()
    var audioURL                                    : URL? = nil
    @StateObject private var playerManager          = AudioRecorderManager()
    
    @State var showDiscardPopup                     : Bool = false
    @State var showImagePopup                       : Bool = false
    @State var showServiceBottom                    : Bool = false
    @State var showAmountBottom                     : Bool = false
    @State var showNextChargeDateBottom             : Bool = false
    @State var showCurrencyBottom                   : Bool = false
    @State var showCategoryBottom                   : Bool = false
    @State var showPlanTypeBottom                   : Bool = false
    @State var showBillingCycleBottom               : Bool = false
    
    @StateObject var manualEntryVM                  = ManualEntryViewModel()
    
    @State var fillRatio                            : CGFloat = 0.0
    @State var isInitialService                     = true
    @State var isInitialCurrency                    = true
    @State var isServiceChanged                     = false
    @State private var previousBillingCycle         : String?
    @State private var deleteSheetHeight            : CGFloat = .zero
    @State private var limitExceedSheetHeight       : CGFloat = .zero
    @State var showLimitExceedPopup                 : Bool = false
    @State var fromEmailSync                        : Bool = false
    @State var isRenew                              : Bool = false
    @State var isHighlight                          : HighlightType = .none
    @State var isInitialLimit                       = true
    @State private var isAmountError                : Bool = false
    
    @EnvironmentObject var themeManager             : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Body
    var body: some View {
        VStack{
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 10)
                
                ScrollView{
                    matchCard
                    
                    detailsCard
                    
                    actionButtons
                        .padding(.bottom, 120)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .applyAppBackground()
        .navigationBarBackButtonHidden()
        //MARK: OnAppear
        .onAppear{
            numberOfSubscriptions = subscriptionsData?.count ?? 0
            if totalInitialCount == 0 {
                totalInitialCount = numberOfSubscriptions
            }
            getSubDetails()
            if !isFromImage{
                if let url = audioURL{
                    playerManager.setDuration(url: url)
                }
            }
            updateSubDetails()
            manualEntryVM.getServiceProvidersList()
            if subscriptionData?.serviceName ?? "" != ""{
                fetchProviderDataApi()
            }
            if Constants.FeatureConfig.isS4Enabled {
                commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
            }
        }
        .onChange(of: globalSubscriptionData) { _ in updateSubDetails() }
        .onChange(of: commonApiVM.userInfoResponse) { _ in
            if Constants.FeatureConfig.isS4Enabled {
                if let remainingLimit = commonApiVM.userInfoResponse?.remainingSubscriptionLimit,
                   remainingLimit < numberOfSubscriptions {
                    if isInitialLimit{
                        isInitialLimit = false
                        //                        showLimitExceedPopup = true
                    }
                }
            }
        }
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
                                       providerPlansList    : getAllPlans())
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
        .sheet(isPresented: $showDiscardPopup) {
            InfoAlertSheet(
                onDelegate: {
                    performDeleteAction()
                }, title    : "Are you sure you want to discard the entry?",
                subTitle    : "Data will be permanently deleted",
                imageName   : "infoIcon",
                buttonIcon  : "del_red_newSmall",
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
        .sheet(isPresented: $showLimitExceedPopup) {
            InfoAlertSheet(
                onDelegate: {
                    AppIntentRouter.shared.navigate(to: .pricingPlans(fromPreview: true))
                }, title                : "Plan Limit Exceeded",
                subTitle                : "Your current plan allows only \(commonApiVM.userInfoResponse?.remainingSubscriptionLimit ?? 0) active subscriptions. Upgrade your plan to add more",
                buttonTitle             : "Upgrade Now",
                imageSize               : 70,
                isCancelButtonVisible   : true
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    limitExceedSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(limitExceedSheetHeight)])
        }
    }
    
    //MARK: - User defined methods
    //MARK: addSubApiResponseHandling
    private func addSubApiResponseHandling() {
        if subscriptionPreviewVM.isEntrySuccess == true {
            if let responseData = subscriptionPreviewVM.addSubscriptionResponse {
                // Extract duplicates from official response
                let duplicates = responseData.duplicates ?? []
                if !duplicates.isEmpty {
                    var updatedDuplicates: [DuplicateDataInfo] = []
                    for (index, item) in duplicates.enumerated() {
                        var newSubs = item.newSubscription ?? []
                        for i in 0..<newSubs.count {
                            if (newSubs[i].id ?? "").isEmpty {
                                newSubs[i].id = "\(i + 1)"
                            }
                        }
                        let info = DuplicateDataInfo(
                            id: String(accumulatedDuplicates.count + index + 1),
                            serviceName: newSubs.first?.serviceName ?? "",
                            newSubscriptions: newSubs,
                            existingSubscriptions: item.oldSubscription
                        )
                        updatedDuplicates.append(info)
                    }
                    accumulatedDuplicates.append(contentsOf: updatedDuplicates)
                }
            }
            
            newlyAddedSubscriptionsCount += 1
            lastSavedSubscription = subscriptionData
            currentSubscriptions += 1
            
            if currentSubscriptions > numberOfSubscriptions {
                playerManager.pausePlayback()
                
                if let lastSaved = lastSavedSubscription {
                    subscriptionsData = [lastSaved]
                    numberOfSubscriptions = 1
                    totalInitialCount = 1
                    currentSubscriptions = 1
                    getSubDetails()
                }
                
                if !accumulatedDuplicates.isEmpty {
                    isFromAdd = true
                    if isRenew || fromEmailSync{
                        AppIntentRouter.shared.navigateAndReplace(to: .duplicateSubscriptionsView(duplicateSubsList: accumulatedDuplicates, isFromEmail: isFromEmail))
                    }else{
                        AppIntentRouter.shared.navigate(to: .duplicateSubscriptionsView(duplicateSubsList: accumulatedDuplicates, isFromEmail: isFromEmail))
                    }
                } else {
                    if isRenew || fromEmailSync{
                        AppIntentRouter.shared.pop()
                    }else{
                        AppIntentRouter.shared.navigate(to: .subscriptionsListView())
                    }
                }
            } else {
                getSubDetails()
                if subscriptionData?.serviceName ?? "" != "" {
                    fetchProviderDataApi()
                }
            }
            subscriptionPreviewVM.isEntrySuccess = false
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
            validateAmount()
        }
    }
    
    func getSubDetails()
    {
        if numberOfSubscriptions > 0
        {
            subscriptionData = subscriptionsData?[currentSubscriptions-1]
            
            // Logic for Plan Type based on Amount
            let planType = (subscriptionData?.subscriptionType ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let amount = subscriptionData?.amount ?? 0.0
            
            if planType.isEmpty{
                if amount == 0.0{
                    subscriptionData?.subscriptionType = "Free"
                } else {
                    subscriptionData?.subscriptionType = "Basic"
                }
            }
            
            subscriptionData?.billingCycle = (subscriptionData?.billingCycle == "" || subscriptionData?.billingCycle == nil) ? "Monthly" : subscriptionData?.billingCycle //no need // march 20 , soniya asked to add this for safe side
            
            if isRenew {
                let baseDate = Date()
                let chargeDateFromToday = Constants.shared.getNextDateByFrequency(frequency: subscriptionData?.billingCycle ?? "", baseDate: baseDate).formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                subscriptionData?.nextPaymentDate = chargeDateFromToday
            } else if subscriptionData?.nextPaymentDate == nil || subscriptionData?.nextPaymentDate == "" {
                let chargeDate = Constants.shared.getNextDateByFrequency(frequency: subscriptionData?.billingCycle ?? "").formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                subscriptionData?.nextPaymentDate = chargeDate
            }
            let (confidenceStr1, colorValue1, fillRatio1) =
            Constants.confidenceInfo(isAssumed: false, confidence: subscriptionData?.confidenceOverall ?? 0.0)
            confidenceStr = confidenceStr1
            colorValue = colorValue1
            fillRatio = fillRatio1
            
            subscriptionsData?[currentSubscriptions-1] = subscriptionData!
            updateCountryAndCurrency()
        }
    }
    
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
        manualEntryVM.fetchProviderData(input   : FetchProviderDataRequest(userId              : Constants.getUserId(),
                                                                           serviceName         : nil,
                                                                           providerName        : subscriptionData?.serviceName ?? "",
                                                                           currencyCode        : subscriptionData?.currency ?? "" == "" ? Constants.shared.currencyCode : subscriptionData?.currency ?? ""),
                                        endPoint: APIEndpoint.fetchProviderDbPlans)
    }
    
    func getAllPlans() -> [ProviderSubscriptionPlan] {
        guard let providers = manualEntryVM.providerData?.providerSubscriptionPlansList else { return [] }
        return providers.compactMap { $0.providerSubscriptionPlansList }.flatMap { $0 }
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
        validateAmount()
    }
    
    private func validateAmount() {
        guard let enteredAmount = subscriptionData?.amount,
              let plans = Optional(getAllPlans()),
              !plans.isEmpty else {
            isAmountError = false
            return
        }
        
        let enteredDouble = Double(enteredAmount)
        let matched = plans.contains { plan in
            guard let price = plan.price else { return false }
            return abs(price - enteredDouble) < 0.01
        }
        
        isAmountError = !matched
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
        AppIntentRouter.shared.pop()
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
        if let (errorMessage, type) = ManualEntryValidations.shared.updateManualEntry(input: subscriptionData!) {
            ToastManager.shared.showToast(message: errorMessage, style: ToastStyle.error)
            isHighlight = type
        }
        else{
            currentSubscriptions = currentSubscriptions + 1
            if currentSubscriptions >= numberOfSubscriptions
            {
                currentSubscriptions = numberOfSubscriptions
            }
            getSubDetails()
            if subscriptionData?.serviceName ?? "" != "" {
                fetchProviderDataApi()
            }
        }
    }
    
    private func onSaveAction() {
        if numberOfSubscriptions > 0 {
            playerManager.pausePlayback()
            if let (errorMessage, type) = ManualEntryValidations.shared.updateManualEntry(input: subscriptionData!) {
                ToastManager.shared.showToast(message: errorMessage, style: .error)
                isHighlight = type
            } else {
                if Constants.FeatureConfig.isS4Enabled {
                    if let remainingLimit = commonApiVM.userInfoResponse?.remainingSubscriptionLimit {
                        if (remainingLimit - newlyAddedSubscriptionsCount) <= 0 {
                            AppIntentRouter.shared.navigate(to: .exceedLimit)
                            //                            showLimitExceedPopup = true
                            return
                        }
                    }
                }
                
                let source = isFromEmail ? 4 : (isFromImage ? 3 : 2)
                let objc = subscriptionsData![currentSubscriptions-1]
                var currency = objc.currency ?? ""
                if currency.isEmpty || currency == "null" {
                    currency = Constants.shared.currencyCode
                }
                
                let subObjc = ConfirmedSubscription(
                    serviceName         : objc.serviceName ?? "",
                    serviceLogo         : getFileName(from: objc.serviceLogo ?? ""),
                    amount              : objc.amount ?? 0.0,
                    currency            : currency,
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
                    sourceReference     : isFromEmail ? objc.sourceReference : nil
                )
                
                let input = PendingSubscriptionConfirmRequest(userId: Constants.getUserId(), confirmedSubscription: [subObjc])
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
                let input = DiscardEmailSubscriptionRequest(userId           : Constants.getUserId(),
                                                            subscriptionIds  : [subId])
                subscriptionPreviewVM.discardEmailSubscriptionApi(input: input)
            } else {
                handleLocalDiscard()
            }
        } else {
            handleLocalDiscard()
        }
    }
    
    private func handleLocalDiscard() {
        currentSubscriptions += 1
        
        if currentSubscriptions > numberOfSubscriptions {
            playerManager.pausePlayback()
            
            if let lastSaved = lastSavedSubscription {
                subscriptionsData = [lastSaved]
                numberOfSubscriptions = 1
                totalInitialCount = 1
                currentSubscriptions = 1
                getSubDetails()
            }
            
            if !accumulatedDuplicates.isEmpty {
                isFromAdd = true
                if isRenew || fromEmailSync{
                    AppIntentRouter.shared.navigateAndReplace(to: .duplicateSubscriptionsView(duplicateSubsList: accumulatedDuplicates, isFromEmail: isFromEmail))
                }else{
                    AppIntentRouter.shared.navigate(to: .duplicateSubscriptionsView(duplicateSubsList: accumulatedDuplicates, isFromEmail: isFromEmail))
                }
            } else {
                AppIntentRouter.shared.pop()
            }
        } else {
            getSubDetails()
            if subscriptionData?.serviceName ?? "" != "" {
                fetchProviderDataApi()
            }
        }
    }
}
// MARK: - Header

extension SubConformation {
    
    var headerView: some View {
        HStack {
            
            CircleBackButton {
                goBack()
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                Text("\(currentSubscriptions)")
                    .font(.geistSemiBold(17))
                    .foregroundStyle(themeManager.accentGradient)
                
                Text("/\(totalInitialCount == 0 ? 1 : totalInitialCount)")
                    .font(.geistSemiBold(17))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
            }
        }
        .padding(.vertical, 20)
    }
}
//MARK: Matched
extension SubConformation {
    
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
                    
                    Text("Matched to \(subscriptionData?.serviceName ?? "")")
                        .font(.geistSemiBold(12))
                        .foregroundStyle(
                            .textPrimary0E101AF4F1FB
                        )
                    
                    Text("\(Int((subscriptionData?.confidenceOverall ?? 0.0) * 100))% MATCH")
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
                    HStack(spacing: 6) {
                        if !plans.isEmpty {
                            ForEach(plans, id: \.self) { plan in
                                Button(action: {
                                    subscriptionData?.subscriptionType = plan.planName
                                    if let price = plan.price {
                                        subscriptionData?.amount = price
                                    }
                                    if let cycle = plan.billingCycle, !cycle.isEmpty {
                                        subscriptionData?.billingCycle = cycle
                                    }
                                    // Update Next Charge Date if billing cycle changes
                                    if isRenew {
                                        let baseDate = Date()
                                        let chargeDateFromToday = Constants.shared.getNextDateByFrequency(frequency: subscriptionData?.billingCycle ?? "", baseDate: baseDate).formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                                        subscriptionData?.nextPaymentDate = chargeDateFromToday
                                    } else {
                                        let chargeDate = Constants.shared.getNextDateByFrequency(frequency: subscriptionData?.billingCycle ?? "").formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd")
                                        subscriptionData?.nextPaymentDate = chargeDate
                                    }
                                    validateAmount()
                                }) {
                                    PlanPillView(
                                        title: plan.planName ?? "",
                                        price: "\(subscriptionData?.currencySymbol ?? "")\(plan.price ?? 0.0)"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        } else {
                            // Fallback plans to keep the UI intact if no plans are found
                            Button(action: {
                                subscriptionData?.subscriptionType = "Free"
                                subscriptionData?.amount = 0.0
                                validateAmount()
                            }) {
                                PlanPillView(
                                    title: "Free",
                                    price: "\(subscriptionData?.currencySymbol ?? "")0.00"
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                subscriptionData?.subscriptionType = "Basic"
                                validateAmount()
                            }) {
                                PlanPillView(
                                    title: "Basic",
                                    price: "\(subscriptionData?.currencySymbol ?? "")-"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        //        .background(themeManager.accentGradient.opacity(0.133))
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
    
    private func getAttributedDescription() -> AttributedString {
        var result = AttributedString("Auto-filled category ")
        result.foregroundColor = themeManager.textPrimaryLight6_dark62
        
        var cat = AttributedString(subscriptionData?.categoryName ?? "")
        cat.font = .geistSemiBold(11)
        cat.foregroundColor = .textPrimary0E101AF4F1FB
        
        var cycle = AttributedString(", cycle ")
        cycle.foregroundColor = themeManager.textPrimaryLight6_dark62
        
        var bil = AttributedString(subscriptionData?.billingCycle ?? "")
        bil.font = .geistSemiBold(11)
        bil.foregroundColor = .textPrimary0E101AF4F1FB
        
        var currency = AttributedString(", currency ")
        currency.foregroundColor = themeManager.textPrimaryLight6_dark62
        
        var cur = AttributedString(subscriptionData?.currency ?? "")
        cur.font = .geistSemiBold(11)
        cur.foregroundColor = .textPrimary0E101AF4F1FB
        
        var dot = AttributedString(".")
        dot.foregroundColor = themeManager.textPrimaryLight6_dark62
        
        result += cat
        result += cycle
        result += bil
        result += currency
        result += cur
        result += dot
        
        return result
    }
}

struct PlanPillView: View {
    
    var title: String
    var price: String
    @EnvironmentObject var themeManager         : ThemeManager
    
    var body: some View {
        
        HStack(spacing: 4) {
            
            Text(title)
                .foregroundStyle(
                    .textPrimary0E101AF4F1FB
                )
            
            Text(price)
                .foregroundStyle(
                    themeManager.selectedAccent.senColor
                )
        }
        .font(.jetBrainsMedium(10))
        .tracking(0.2)
        .padding(.horizontal, 10)
        .frame(height: 26)
        .background(themeManager.white_white4)
        .overlay {
            Capsule()
                .stroke(
                    themeManager.textPrimaryLight8_white8,
                    lineWidth: 1
                )
        }
        .clipShape(Capsule())
    }
}
//MARK: details
extension SubConformation {
    
    var detailsCard: some View {
        
        VStack(spacing: 16) {
            
            // MARK: Header
            
            HStack(spacing: 14) {
                
                AvatarView(serviceName: subscriptionData?.serviceName ?? "", serviceLogo: subscriptionData?.serviceLogo ?? "", size: 56, fontSize: 28, fromPreview: true, isShadow: false)
                
                // Info
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(subscriptionData?.serviceName ?? "")
                        .font(.geistSemiBold(18))
                        .tracking(-0.4)
                        .foregroundStyle(
                            .textPrimary0E101AF4F1FB
                        )
                        .lineLimit(2)
                    
                    Text("\(subscriptionData?.subscriptionType ?? "")")// · \(subscriptionData?.billingCycle ?? "")")
                        .font(.jetBrainsMedium(11))
                        .foregroundStyle(
                            themeManager.textPrimaryLight6_dark62
                        )
                }
                
                Spacer()
                
                // Price
                
                Text(String(format: "%@%.2f", subscriptionData?.currencySymbol ?? "", subscriptionData?.amount ?? 0.0))
                    .font(.geistSemiBold(22))
                    .tracking(-0.6)
                    .foregroundStyle(
                        .textPrimary0E101AF4F1FB
                    )
            }
            
            // Divider
            
            Rectangle()
                .fill(
                    themeManager.textPrimaryLight8_white8
                )
                .frame(height: 1)
            
            // MARK: Details
            
            VStack(spacing: 16) {
                
                SubscriptionInfoRow(
                    title: "Category",
                    value: subscriptionData?.categoryName ?? ""
                )
                
                SubscriptionInfoRow(
                    title: "Cycle",
                    value: subscriptionData?.billingCycle ?? ""
                )
                
                SubscriptionInfoRow(
                    title: "Currency",
                    value: subscriptionData?.currency ?? ""
                )
                
                SubscriptionInfoRow(
                    title: "Next charge",
                    value: (subscriptionData?.nextPaymentDate ?? "").formattedDate()
                )
                
                //                if let pm = subscriptionData?.paymentMethodId, !pm.isEmpty {
                //                    SubscriptionInfoRow(
                //                        title: "Paid with",
                //                        value: pm
                //                    )
                //                }
            }
            HStack {
                HStack(spacing: 12) {
                    Button {
                        onEditAction()
                    } label: {
                        Image("editIcon")
                            .frame(width: 40, height: 40)
                    }
                    
                    Button {
                        onDiscardAction()
                    } label: {
                        Image("deleteIcon1")
                            .frame(width: 40, height: 40)
                    }
                }
                .frame(width: 92, height: 40, alignment: .bottomTrailing)
                Spacer()
            }
        }
        .padding(20)
        .background(themeManager.white_white4)
        .overlay {
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .stroke(
                themeManager.textPrimaryLight8_white8,
                lineWidth: 1
            )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
        .padding(.top, 16)
    }
}

struct SubscriptionInfoRow: View {
    
    var title: String
    var value: String
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        
        HStack {
            
            Text(title.uppercased())
                .font(.jetBrainsMedium(11))
                .tracking(1)
                .foregroundStyle(
                    themeManager.textPrimaryLight6_dark62
                )
            
            Spacer()
            
            Text(value)
                .font(.geistMedium(14))
                .foregroundStyle(
                    .textPrimary0E101AF4F1FB
                )
        }
    }
}
//MARK: Buttons
extension SubConformation {
    
    var actionButtons: some View {
        HStack(spacing: 10) {
            CustomBorderButton(
                title       : "Cancel",
                background  : Color.clear,
                borderColor : themeManager.textPrimaryLight14_white14,
                action      : {
                    if !accumulatedDuplicates.isEmpty {
                        isFromAdd = true
                        if isRenew || fromEmailSync{
                            AppIntentRouter.shared.navigateAndReplace(to: .duplicateSubscriptionsView(duplicateSubsList: accumulatedDuplicates, isFromEmail: isFromEmail))
                        }else{
                            AppIntentRouter.shared.navigate(to: .duplicateSubscriptionsView(duplicateSubsList: accumulatedDuplicates, isFromEmail: isFromEmail))
                        }
                    } else {
                        AppIntentRouter.shared.pop()
                    }
                }
            )
            
            GradientBgButton(
                title       : "Confirm & add",
                isSolid     : true,
                showChevron : false
            ) {
                onSaveAction()
            }
        }
        .padding(.top, 24)
    }
}
