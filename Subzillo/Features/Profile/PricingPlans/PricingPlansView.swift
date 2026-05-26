//
//  PricingPlansView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 31/01/26.
//

import SwiftUI
import StoreKit

struct PricingPlanUI: Identifiable {
    let id = UUID()
    let title: String
    let price: String?
    let priceSubtitle: String?
    let features: [String]
    let badgeText: String?
    let badgeColor: Color?
    let buttonTitle: String
    let isCurrent: Bool
    let isLoading: Bool
    let downgradeText: String?
    let isPopularPlan: Bool?
    let isBestPlan: Bool?
    let action: (() -> Void)?
    
    init(title: String, price: String? = nil, priceSubtitle: String? = nil, features: [String], badgeText: String? = nil, badgeColor: Color? = nil, buttonTitle: String, isCurrent: Bool = false, isLoading: Bool = false, downgradeText: String? = nil, isPopularPlan: Bool = false, isBestPlan: Bool = false, action: (() -> Void)? = nil) {
        self.title = title
        self.price = price
        self.priceSubtitle = priceSubtitle
        self.features = features
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.buttonTitle = buttonTitle
        self.isCurrent = isCurrent
        self.isLoading = isLoading
        self.downgradeText = downgradeText
        self.isPopularPlan = isPopularPlan
        self.isBestPlan = isBestPlan
        self.action = action
    }
}


struct PricingPlansView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSegment          : Segment? = .first
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @StateObject private var viewModel          = PricingPlansViewModel.shared
    @State private var justAppeared             : Bool = false
    @State private var showPlatformAlert        : Bool = false
    @State private var platformAlertMessage     : String = ""
    @State private var pendingProduct           : (Product, String)?
    @State private var platformSheetHeight      : CGFloat = .zero
    var fromPreview                             : Bool = false
    @State private var products: [SKProduct]    = []
    @State var planId                           : String?
    @State private var processedTransactionIds  : Set<String> = []
    @State private var lastProcessedProductId   : String = ""
    @State private var lastProcessedDate        : Date = .distantPast
    @State private var loadingStatus            : PricingPlanProcessingType? = nil
    var selectedTab                             : Segment = .first
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedPlanId: String = ""
    
    //MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: Header
                HStack(alignment: .center, spacing: 12) {
                    
                    Button(action: {
                        AppIntentRouter.shared.pop()
                    }) {
                        HStack {
                            
                            if colorScheme == .dark
                            {
                                Image("back_gray")
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                            }
                            else{
                                Image("back_gray")
                            }
                        }
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(themeManager.white_white4)
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    themeManager.black_white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        
                        Text("Plans")
                            .font(.jetBrainsRegular(11))
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                            .tracking(1.5)
                            .textCase(.uppercase)
                        
                        Text("Pick your vibe")
                            .font(.geistBold(22))
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                            )
                            .tracking(-0.8)
                            .lineSpacing(2)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 20)
                
                
                // MARK: Toggle
                HStack {
                    SegmentViewNew(
                        selectedSegment: $selectedSegment,
                        leftText: "Monthly",
                        rightText: "Annual · −20%",
                        isUpgrade: true
                    )
                    .environmentObject(themeManager)
                    .frame(width: 220)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        
                        // MARK: Plans List
                        VStack(spacing: 12) {
                            
                            ForEach(viewModel.pricingPlans) { plan in
                                
                                PricingPlanCard(
                                    plan: getUIPlan(from: plan),
                                    isSelected: selectedPlanId == (plan.id ?? "")
                                ) {
                                    
                                    selectedPlanId = plan.id ?? ""
                                }
                            }
                        }
                        
                        
                        Text(getAttributedText())
                            .font(.jetBrainsRegular(10))
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 16)
                            .environment(\.openURL, OpenURLAction { url in
                                if url.absoluteString.contains("privacy") {
                                    viewModel.navigate(to: .termsAndPrivacy(isTerm: false))
                                } else if url.absoluteString.contains("terms") {
                                    viewModel.navigate(to: .termsAndPrivacy(isTerm: true))
                                }
                                return .handled
                            })
                        
                        Button {
                            self.loadingStatus = .loading
                            viewModel.runPrePaymentCheck { isSafe in
                                guard isSafe else {
                                    self.loadingStatus = nil
                                    return
                                }
                                restorePurchases()
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.geistBold(14))
                                .foregroundColor(.textPrimary0E101AF4F1FB)
                                .underline(true, color: .textPrimary0E101AF4F1FB)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 140)
                }
            }
            .applyAppBackground()
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            
            if let status = loadingStatus {
                PricingPlanLoadingView(type: status) {
                    self.loadingStatus = nil
                }
            }
        }
        .onAppear {
            selectedSegment = selectedTab
            justAppeared = true
            Task {
                if commonApiVM.userInfoResponse == nil {
                    commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
                }
                viewModel.listPricingPlans(type: selectedSegment == .first ? 1 : 2)
                fetchProducts()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                justAppeared = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .IAPHelperPurchaseNotification)) { notification in
            handlePurchaseNotification(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: .IAPHelperRestoreNotification)) { notification in
            handleRestoreNotification(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: .IAPHelperNoRestorablePurchasesNotification)) { _ in
            self.loadingStatus = nil
            self.platformAlertMessage = "No active subscription was found associated with your Apple ID."
            self.showPlatformAlert = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("cancelbuying"))) { _ in
            self.loadingStatus = .failed
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("alreadySubscribed"))) { _ in
            self.loadingStatus = nil
        }
        .onChange(of: selectedSegment) { _ in
            viewModel.listPricingPlans(type: selectedSegment == .first ? 1 : 2)
        }
        .onChange(of: viewModel.isSubscribe) { value in
            if value{
                viewModel.listPricingPlans(type: selectedSegment == .first ? 1 : 2)
                if fromPreview{
                    AppIntentRouter.shared.pop()
                }
                planId = ""
            }
        }
        .onChange(of: viewModel.restoreSyncFailed) { failed in
            if failed {
                self.loadingStatus = nil
                self.platformAlertMessage = "We found your previous purchase, but could not sync it to your account. Please contact support or try again later."
                self.showPlatformAlert = true
                viewModel.restoreSyncFailed = false
            }
        }
        .sheet(isPresented: $showPlatformAlert) {
            SubscriptionAlertSheet(
                onDelegate: {
                    self.loadingStatus = nil
                }, title                : "Subscription Notice",
                subTitle                : platformAlertMessage,
                buttonTitle             : "Ok",
                isBtn                   : false
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    platformSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(platformSheetHeight)])
        }
        .withToast()
    }
    
    //MARK: - User defined methods
    
    private func getAttributedText() -> AttributedString {
        var attriString = AttributedString(
            localized: "This is an auto-renewing subscription. You will be charged automatically at the end of each billing period unless you cancel at least 24 hours before the renewal date. You can manage or cancel your subscription anytime from your Apple ID settings. For more information please visit our Terms & Conditions and Privacy Policy"
        )
        attriString.foregroundColor = .textPrimary0E101AF4F1FB.opacity(0.36)
        if let privacyRange = attriString.range(of: "Privacy Policy") {
            attriString[privacyRange].link = URL(string: "app://privacy")
            attriString[privacyRange].foregroundColor = Color.textPrimary0E101AF4F1FB
            attriString[privacyRange].font = .jetBrainsBold(10)
        }
        if let termsRange = attriString.range(of: "Terms & Conditions") {
            attriString[termsRange].link = URL(string: "app://terms")
            attriString[termsRange].foregroundColor = Color.textPrimary0E101AF4F1FB
            attriString[termsRange].font = .jetBrainsBold(10)
        }
        return attriString
    }
    
    private func fetchProducts() {
        SubzilloProducts.store.requestProducts { success, products in
            if success, let products = products {
                DispatchQueue.main.async {
                    self.products = products
                }
            }
        }
    }
    
    private func restorePurchases() {
        SubzilloProducts.store.restorePurchases()
    }
    
    private func handlePurchaseNotification(_ notification: Notification) {
        guard let transaction = notification.object as? SKPaymentTransaction else { return }
        let productId = transaction.payment.productIdentifier
        
        let transactionId = transaction.transactionIdentifier ?? ""
        let originalId = transaction.original?.transactionIdentifier ?? transactionId
        
        // 1. De-duplicate by Transaction ID
        guard !transactionId.isEmpty, !processedTransactionIds.contains(transactionId) else {
            return
        }
        
        // 2. Burst protection: Skip if we just processed the SAME product in the last 3 seconds
        if lastProcessedProductId == productId && Date().timeIntervalSince(lastProcessedDate) < 3.0 {
            print("[De-duplicate] Skipping burst notification for \(productId)")
            // Still finish the transaction to clear the queue
            return
        }
        
        guard let pId = findPlanIdFor(productId: productId) else {
            self.loadingStatus = nil
            print("Auto-renewal or unmapped purchase ignored for \(productId)")
            return
        }
        
        print("Purchase completed: \(productId) (ID: \(transactionId))")
        
        processedTransactionIds.insert(transactionId)
        lastProcessedProductId = productId
        lastProcessedDate = Date()
        
        self.loadingStatus = nil
        subscribePlanAPI(planId: pId, transactionId: transactionId)
        
        // Reset planId after successful mapping
        if self.planId == pId {
            self.planId = ""
        }
    }
    
    private func handleRestoreNotification(_ notification: Notification) {
        guard let transaction = notification.object as? SKPaymentTransaction else { return }
        let productId = transaction.payment.productIdentifier
        
        let transactionId = transaction.transactionIdentifier ?? ""
        let originalTransactionId = transaction.original?.transactionIdentifier ?? transactionId

        // 1. De-duplicate by Transaction ID
        guard !transactionId.isEmpty, !processedTransactionIds.contains(transactionId) else {
            return
        }
        
        // 2. Burst protection (restores usually only deliver the latest one now, but safety first)
        if lastProcessedProductId == productId && Date().timeIntervalSince(lastProcessedDate) < 2.0 {
            print("[De-duplicate] Skipping burst restore for \(productId)")
            return
        }
        
        guard let pId = findPlanIdFor(productId: productId) else {
            self.loadingStatus = nil
            return
        }
        
        print("Restore processed: \(productId) (Orig: \(originalTransactionId))")
        
        processedTransactionIds.insert(transactionId)
        lastProcessedProductId = productId
        lastProcessedDate = Date()
        self.loadingStatus = nil
        
        let request = RestoreIosPurchaseRequest(
            userId: Constants.getUserId(),
            transactionId: transactionId,
            originalTransactionId: originalTransactionId
        )
        viewModel.restoreIosPurchase(input: request)
    }
    
    private func findPlanIdFor(productId: String) -> String? {
        // 1. Try to match by iosProductId in the pricingPlans list
        if let matchedPlan = viewModel.pricingPlans.first(where: { $0.iosProductId == productId }) {
            return matchedPlan.id
        }
        
        // 2. Fallback to name-based matching for Silver/Gold
        let isYearly = productId.lowercased().contains("yearly")
        let isSilver = productId == (isYearly ? SubzilloProducts.silverYearly : SubzilloProducts.silverMonthly)
        let isGold = productId == (isYearly ? SubzilloProducts.goldYearly : SubzilloProducts.goldMonthly)
        
        if let matchedPlan = viewModel.pricingPlans.first(where: { plan in
            let name = plan.planName?.lowercased() ?? ""
            if isSilver && name.contains("silver") { return true }
            if isGold && name.contains("gold") { return true }
            return false
        }) {
            return matchedPlan.id
        }
        
        // 3. Last resort: use the planId set by the button tap
        if let tappedPlanId = self.planId, !tappedPlanId.isEmpty {
             return tappedPlanId
        }
        
        return nil
    }
    
    private func getUIPlan(from plan: PricingPlan) -> PricingPlanUI {
        let planName            = plan.planName ?? ""
        let lowercasedPlanName  = planName.lowercased()
        
        let isFreePlan      = lowercasedPlanName.contains("free")
        let isSilverPlan    = lowercasedPlanName.contains("silver")
        let isGoldPlan      = lowercasedPlanName.contains("gold")
        
        let isYearlySelected    = selectedSegment == .second
        
        // Current User Rank (from Backend)
        let currentUserRank = viewModel.pricingPlanResponse?.data?.currentInternalPlanType ?? 0//commonApiVM.userInfoResponse?.internalPlanType ?? 0
        // Plan Rank (from Backend Pricing API)
        let targetPlanRank = plan.internalPlanType ?? 0
        
        var productID: String?
        if plan.iosProductId == nil || plan.iosProductId == ""{
            if isSilverPlan {
                productID = isYearlySelected ? SubzilloProducts.silverYearly : SubzilloProducts.silverMonthly
            } else if isGoldPlan {
                productID = isYearlySelected ? SubzilloProducts.goldYearly : SubzilloProducts.goldMonthly
            }
        }else{
            productID = plan.iosProductId ?? ""
        }
        
        var price: String = ""
        var billingCycle: String = ""
        var isLoadingPrice: Bool = false
        
        if let id = productID, !id.isEmpty {
            if let product = products.first(where: { $0.productIdentifier == id }) {
                price = formatPrice(for: product)
                //                let period = product.subscription?.subscriptionPeriod
                //                if period?.unit == .month {
                //                    billingCycle = "/ month"
                //                }
                //                if period?.unit == .year {
                //                    billingCycle = "/ year"
                //                }
                if isYearlySelected{
                    billingCycle = "/ye"
                }else{
                    billingCycle = "/mo"
                }
            } else {
                // Product ID exists but product not fetched from StoreKit yet
                isLoadingPrice = true
                price = "$ 0.00"
                billingCycle = isYearlySelected ? "/ye" : "/mo"
            }
        } else {
            // Free plan or fallback
            price = "\(plan.currencySymbol ?? "$")\(plan.price ?? 0.0)"
            billingCycle = isYearlySelected ? "/ye" : "/mo"
        }
        
        var buttonTitle         = ""
        let isCurrentPlan       = plan.isCurrentPlan ?? false
        var downGradeText       = ""
        
        if isCurrentPlan {
            buttonTitle = "Current Plan"
        }
        else if isFreePlan {
            buttonTitle = ""
        }
        else {
            if targetPlanRank > currentUserRank {
                buttonTitle = "Upgrade"
            } else {
                if viewModel.pricingPlanResponse?.data?.downgradePlanType ?? 0 == plan.internalPlanType ?? 0{
                    buttonTitle = ""
                    downGradeText = "This plan will take effect at the end of your current billing period."
                }else{
                    buttonTitle = "Downgrade"
                }
            }
        }
        
        return PricingPlanUI(
            title           : planName,
            price           : price,
            priceSubtitle   : isFreePlan ? nil : billingCycle,
            features        : [plan.description ?? "Basic features"],
            badgeColor      : isCurrentPlan ? Color.neutral600 : nil,
            buttonTitle     : buttonTitle,
            isCurrent       : isCurrentPlan,
            isLoading       : isLoadingPrice,
            downgradeText   : downGradeText,
            isPopularPlan   : isSilverPlan ? true : false,
            isBestPlan      : isGoldPlan ? true : false,
            action          : {
                self.loadingStatus = .loading
                viewModel.runPrePaymentCheck { isSafe in
                    guard isSafe else {
                        self.loadingStatus = nil
                        return
                    }
                    
                    let platform = viewModel.pricingPlanResponse?.data?.subscribedPlatformType ?? 2
                    
                    if viewModel.pricingPlanResponse?.data?.currentInternalPlanType ?? 0 == 0 || platform == 2{
                        if let id = productID, let product = products.first(where: { $0.productIdentifier == id }) {
                            print("View: Purchase Button Tapped for \(product.productIdentifier)")
                            self.planId = plan.id ?? ""
                            SubzilloProducts.store.buyProduct(product)
                        } else {
                            self.loadingStatus = nil
                        }
                        return
                    }
                    if platform == 1 { // Android
                        platformAlertMessage = "Dear User,We noticed that you initially registered your account and subscribed through our Android application, and you are now trying to upgrade your plan via the iOS application.To avoid duplicate billing, please cancel your existing subscription on the Android application before proceeding with the upgrade here.You can find the “Cancel Subscription” option in play store.Thank you for your understanding and cooperation."
                        showPlatformAlert = true
                        //            AlertManager.shared.showAlert(title: "Subscription Notice", message: platformAlertMessage)
                        //            AlertManager.shared.showAlert(title: "Subscription Notice",
                        //                                          message: platformAlertMessage,
                        //                                          okText: "Continue",
                        //                                          cancelText: "Cancel",
                        //                                          isDestructive: true,
                        //                                          okAction: {
                        //                purchaseInternal(product: product, planId: planId)
                        //            })
                    } else if platform == 3 { // Web
                        platformAlertMessage = "Dear User, We noticed that you initially registered your account and subscribed through our web application, and you are now trying to upgrade your plan via the iOS application. To avoid duplicate billing, please cancel your existing subscription on the web application before proceeding with the upgrade here. You can find the “Cancel Subscription” option under Account Settings on the web platform.Thank you for your understanding and cooperation."
                        //            AlertManager.shared.showAlert(title: "Subscription Notice", message: platformAlertMessage)
                        showPlatformAlert = true
                    }
                }
            }
        )
    }
    
    private func formatPrice(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
    
    func subscribePlanAPI(planId: String, transactionId: String) {
        let request = SubscribePlanRequest(
            userId        : Constants.getUserId(),
            pricingPlanId : planId,
            platform      : 2,
            transactionId : transactionId
        )
        viewModel.subscribePlan(input: request)
    }
}

// MARK: - Subviews
struct PricingPlanCard: View {
    let plan: PricingPlanUI
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager         : ThemeManager
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                if plan.isPopularPlan == true {
                    HStack {
                        
                        Text("POPULAR")
                            .font(.jetBrainsBold(9))
                            .tracking(1.5)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                themeManager.accentGradient.opacity(0.8)
                            )
                            .clipShape(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 10,
                                    bottomTrailingRadius: 10,
                                    topTrailingRadius: 0
                                )
                            )
                            .shadow(
                                color: themeManager.selectedAccent.senColor.opacity(0.55),
                                radius: 12,
                                y: 4
                            )
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(alignment: .top) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            
                            HStack(spacing: 8) {
                                
                                Text(plan.title)
                                    .font(.geistBold(16))
                                    .foregroundStyle(Color.textPrimary0E101AF4F1FB)
                                if plan.isBestPlan == true {
                                    Text("BEST VALUE")
                                        .font(.jetBrainsMedium(10))
                                        .foregroundStyle(
                                            Color("Red_E85D75")
                                        )
                                        .tracking(1)
                                        .padding(.horizontal, 8)
                                        .frame(height: 20)
                                        .background(
                                            Color("Red_E85D75")
                                                .opacity(0.15)
                                        )
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 6)
                                        )
                                }
                            }
                            if plan.isCurrent == true {
                                Text("Current plan")
                                    .font(.geistRegular(12))
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.6)
                                    )
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            
                            Text(plan.price ?? "")
                                .font(.geistExtraBold(26))
                                .foregroundStyle(
                                    Color.textPrimary0E101AF4F1FB
                                )
                                .tracking(-1)
                            
                            Text(plan.priceSubtitle ?? "")
                                .font(.jetBrainsRegular(11))
                                .foregroundStyle(
                                    Color.textPrimary0E101AF4F1FB
                                        .opacity(0.6)
                                )
                        }
                    }
                    
                    
                    if isSelected == true {
                        // MARK: - Features
                        
                        VStack(alignment: .leading, spacing: 7) {
                            ForEach(plan.features, id: \.self) { title in
                                featureRow(title)
                            }
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                        
                        // MARK: - Button
                        
                        if plan.isCurrent == false {
                            Button {
                                plan.action?()
                            } label: {
                                
                                Text("\(plan.buttonTitle) →")
                                    .font(.geistBold(15))
                                    .tracking(-0.3)
                                    .foregroundStyle(themeManager.white_black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        themeManager.black_white
                                    )
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 14)
                                    )
                            }
                        }
                    }
                    else{
                        Text(plan.features[0])
                            .font(.geistRegular(12))
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                            .lineSpacing(3)
                            .padding(.top, 6)
                    }
                    
                   /* if plan.buttonTitle != ""{
                        CustomButton(title      : plan.buttonTitle,
                                     background : plan.isCurrent ? Color.neutralDisabled200 : Color.primaryBlue800,
                                     textColor  : plan.isCurrent ? Color.neutral500 : Color.white,
                                     height     : 48,
                                     isHidden   : plan.isCurrent ? true : false,
                                     action: {
                            plan.action?()
                        })
                        .disabled(plan.isCurrent || plan.isLoading)
                    }*/
                }
                .padding(18)
            }
            .background(themeManager.white_white4)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .overlay {
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected == true ? themeManager.selectedAccent.senColor : Color.textPrimary0E101AF4F1FB.opacity(0.08),
                        lineWidth: 1
                    )
            }
            .shadow(
                color: isSelected == true ? themeManager.selectedAccent.senColor.opacity(0.55) : .clear,
                radius: 32,
                y: 8
            )
        }
    }
    @ViewBuilder
    func featureRow(_ title: String) -> some View {
        
        HStack(spacing: 10) {
            
            Circle()
                .fill(
                    themeManager.accentGradient
                )
                .frame(width: 7, height: 7)
            
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                )
        }
    }
}
struct PricingPlanCardold: View {
    let plan: PricingPlanUI
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top) {
                    Text(plan.title)
                        .font(.appSemiBold(24))
                        .foregroundColor(Color.secondaryNavyBlue800)
                    
                    Spacer()
                }
                
                if let price = plan.price {
                    HStack(alignment: .center, spacing: 4) {
                        Text(price)
                            .font(.appSemiBold(28))
                            .foregroundColor(.primaryBlue800)
                        
                        if let sub = plan.priceSubtitle {
                            Text(sub)
                                .font(.appRegular(16))
                                .foregroundColor(.neutral500)
                        }
                    }
                    .redacted(reason: plan.isLoading ? .placeholder : [])
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack(spacing: 12) {
                            Image("checkmark_circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text(feature)
                                .font(.appRegular(14))
                                .foregroundColor(.neutralMain700)
                        }
                    }
                }
                
                if let text = plan.downgradeText{
                    if text != ""{
                        Text(text)
                            .font(.appRegular(14))
                            .foregroundColor(Color.grayLG)
                    }
                }
                
                if plan.buttonTitle != ""{
                    CustomButton(title      : plan.buttonTitle,
                                 background : plan.isCurrent ? Color.neutralDisabled200 : Color.primaryBlue800,
                                 textColor  : plan.isCurrent ? Color.neutral500 : Color.white,
                                 height     : 48,
                                 isHidden   : plan.isCurrent ? true : false,
                                 action: {
                        plan.action?()
                    })
                    .disabled(plan.isCurrent || plan.isLoading)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.neutral300Border, lineWidth: 1)
            )
            
            //            if let badge = plan.badgeText {
            //                Text(badge)
            //                    .font(.appSemiBold(14))
            //                    .foregroundColor(.white)
            //                    .padding(.horizontal, 16)
            //                    .padding(.vertical, 8)
            //                    .background(badgeBackground(for: plan))
            //                    .clipShape(RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight]))
            //                    .padding(.trailing, 24)
            //            }
        }
    }
    
    @ViewBuilder
    private func badgeBackground(for plan: PricingPlanUI) -> some View {
        if let color = plan.badgeColor {
            color
        } else {
            LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700],
                           startPoint: .leading,
                           endPoint: .trailing)
        }
    }
}

//MARK: - PlanToggleView
struct PlanToggleView: View {
    
    @Binding var selectedSegment    : Segment?
    var leftText                    : String
    var rightText                   : String
    
    var body: some View {
        HStack(spacing: 0) {
            
            // MARK: - List View Button
            Button {
                selectedSegment = .first
            } label: {
                HStack() {
                    Text(LocalizedStringKey(leftText))
                        .font(.appSemiBold(14))
                        .foregroundColor(selectedSegment == .first ? Color.white : .navyBlueCTA700)
                }
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(
                    Group {
                        if selectedSegment == .first {
                            Color.navyBlueCTA700
                                .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .bottomLeft]))
                        } else {
                            Color.clear
                        }
                    }
                )
                .overlay(
                    RoundedCorner(radius: 8, corners: [.topLeft, .bottomLeft])
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .padding(1)
                        .opacity(selectedSegment == .first ? 0 : 1)
                )
            }
            
            // MARK: - Calendar View Button
            Button {
                selectedSegment = .second
            } label: {
                HStack() {
                    Text(LocalizedStringKey(rightText))
                        .font(.appSemiBold(14))
                        .foregroundColor(selectedSegment == .second ? Color.white : .navyBlueCTA700)
                    
                    //                    Text("SAVE %24")
                    //                        .font(.appSemiBold(14))
                    //                        .foregroundColor(.white)
                    //                        .padding(.horizontal, 8)
                    //                        .padding(.vertical, 4)
                    //                        .background(
                    //                            LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700],
                    //                                           startPoint: .top,
                    //                                           endPoint: .bottom)
                    //                        )
                    //                        .cornerRadius(18)
                }
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(
                    Group {
                        if selectedSegment == .second {
                            Color.navyBlueCTA700
                                .clipShape(RoundedCorner(radius: 8, corners: [.topRight, .bottomRight]))
                        } else {
                            Color.clear
                        }
                    }
                )
                .overlay(
                    RoundedCorner(radius: 8, corners: [.topRight, .bottomRight])
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .padding(1)
                        .opacity(selectedSegment == .second ? 0 : 1)
                )
            }
        }
        .frame(height: 40)
    }
}
