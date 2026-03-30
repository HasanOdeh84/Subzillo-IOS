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
    let action: (() -> Void)?
    
    init(title: String, price: String? = nil, priceSubtitle: String? = nil, features: [String], badgeText: String? = nil, badgeColor: Color? = nil, buttonTitle: String, isCurrent: Bool = false, isLoading: Bool = false, action: (() -> Void)? = nil) {
        self.title = title
        self.price = price
        self.priceSubtitle = priceSubtitle
        self.features = features
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.buttonTitle = buttonTitle
        self.isCurrent = isCurrent
        self.isLoading = isLoading
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
    @State private var loadingStatus            : PricingPlanProcessingType? = nil
    var selectedTab                             : Segment = .first
    
    //MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: Header
                HStack(spacing: 8) {
                    // MARK: back
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image("back_gray")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // MARK: Title
                        Text("Plans & Pricing")
                            .font(.appRegular(24))
                            .foregroundColor(Color.neutralMain700)
                            .padding(.top, 20)
                        
                        // MARK: SubTitle
                        Text("Here's subscription Plans")
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutral500)
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                HStack{
                    Spacer()
                    Button(action: {
                        Constants.shared.OpenSubscriptionsInAppStore()
                    }) {
                        Text("Manage Subscription")
                            .font(.appRegular(18))
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // MARK: Toggle
                PlanToggleView(selectedSegment : $selectedSegment,
                               leftText        : "Monthly",
                               rightText       : "Annually")
                .padding(.bottom, 24)
                .padding(.horizontal, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: Plans List
                        VStack(spacing: 20) {
                            ForEach(viewModel.pricingPlans) { plan in
                                PricingPlanCard(plan: getUIPlan(from: plan))
                            }
                        }
                        
                        // MARK: tip view
                        //                        GradienCustomeView(title    : "Need help choosing?",
                        //                                           subTitle : "Compare all features and find the perfect plan for your subscription management needs.")
                        
                        Text(getAttributedText())
                            .font(.appRegular(14))
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
                                .font(.appBold(14))
                                .foregroundColor(.neutralMain700)
                                .underline(true, color: .neutralMain700)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.neutralBg100)
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
            self.loadingStatus = nil
            handlePurchaseNotification(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("cancelbuying"))) { _ in
            self.loadingStatus = .failed
        }
        .onChange(of: selectedSegment) { _ in
            viewModel.listPricingPlans(type: selectedSegment == .first ? 1 : 2)
        }
        .onChange(of: viewModel.isSubscribe) { value in
            if value{
                viewModel.listPricingPlans(type: selectedSegment == .first ? 1 : 2)
                if fromPreview{
                    dismiss()
                }
                planId = ""
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
    }
    
    //MARK: - User defined methods
    
    private func getAttributedText() -> AttributedString {
        var attriString = AttributedString(
            localized: "This is an auto-renewing subscription. You will be charged automatically at the end of each billing period unless you cancel at least 24 hours before the renewal date. You can manage or cancel your subscription anytime from your Apple ID settings. For more information please visit our Terms & Conditions and Privacy Policy"
        )
        attriString.foregroundColor = .neutralMain700
        if let privacyRange = attriString.range(of: "Privacy Policy") {
            attriString[privacyRange].link = URL(string: "app://privacy")
            attriString[privacyRange].foregroundColor = .blueMain700
            attriString[privacyRange].font = .appBold(12)
        }
        if let termsRange = attriString.range(of: "Terms & Conditions") {
            attriString[termsRange].link = URL(string: "app://terms")
            attriString[termsRange].foregroundColor = .blueMain700
            attriString[termsRange].font = .appBold(12)
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
        print("Purchase completed: \(transaction.payment.productIdentifier)")
        
        let transactionId = transaction.transactionIdentifier ?? transaction.original?.transactionIdentifier ?? ""
        
        if let pId = self.planId, !pId.isEmpty {
            if planId != ""{
                subscribePlanAPI(planId: pId, transactionId: transactionId)
            }else{
                print("Error: planId is empty.")
            }
        } else {
            print("Error: No planId found to trigger subscribePlanAPI.")
        }
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
                    billingCycle = "/ year"
                }else{
                    billingCycle = "/ month"
                }
            } else {
                // Product ID exists but product not fetched from StoreKit yet
                isLoadingPrice = true
                price = "$ 0.00"
                billingCycle = isYearlySelected ? "/ year" : "/ month"
            }
        } else {
            // Free plan or fallback
            price = "\(plan.currencySymbol ?? "$")\(plan.price ?? 0.0)"
            billingCycle = isYearlySelected ? "/ year" : "/ month"
        }
        
        var buttonTitle         = ""
        let isCurrentPlan       = plan.isCurrentPlan ?? false
        
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
                buttonTitle = "Downgrade"
            }
        }
        
        return PricingPlanUI(
            title           : planName,
            price           : isFreePlan ? nil : price,
            priceSubtitle   : isFreePlan ? nil : billingCycle,
            features        : [plan.description ?? "Basic features"],
            badgeColor      : isCurrentPlan ? Color.neutral600 : nil,
            buttonTitle     : buttonTitle,
            isCurrent       : isCurrentPlan,
            isLoading       : isLoadingPrice,
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
                
                if plan.buttonTitle != ""{
                    CustomButton(title      : plan.buttonTitle,
                                 background : plan.isCurrent ? Color.neutralDisabled200 : Color.primaryBlue800,
                                 textColor  : plan.isCurrent ? Color.neutral500 : Color.white,
                                 height     : 48,
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
