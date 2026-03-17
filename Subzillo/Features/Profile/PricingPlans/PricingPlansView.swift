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
    @StateObject private var storeManager       = StoreManager.shared
    @StateObject private var viewModel          = PricingPlansViewModel.shared
    @State private var justAppeared             : Bool = false
    @State private var showPlatformAlert        : Bool = false
    @State private var platformAlertMessage     : String = ""
    @State private var pendingProduct           : (Product, String)?
    
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
                            Task {
                                try? await storeManager.restorePurchases { restoredEntitlements in
                                    for entitlement in restoredEntitlements {
                                        if let matchedPlan = viewModel.pricingPlans.first(where: {
                                            ($0.iosProductId ?? "") == entitlement.productID ||
                                            SubzilloProducts.productId(for: $0.planName ?? "", segment: selectedSegment) == entitlement.productID
                                        }), let planId = matchedPlan.id {
                                            viewModel.pendingTransaction = entitlement.transaction
                                            subscribePlanAPI(planId: planId, transactionId: entitlement.transactionId)
                                        }
                                    }
                                }
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
            .blur(radius: storeManager.purchaseState != .idle ? 3 : 0)
            
            // MARK: Loading/Error Overlay
            if storeManager.purchaseState != .idle {
                PricingPlanLoadingView(
                    type        : storeManager.purchaseState == .loading ? .loading : .failed,
                    onTryAgain  : {
                        viewModel.cancelPurchase()
                        storeManager.purchaseState = .idle
                    }
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            justAppeared = true
            Task {
                if commonApiVM.userInfoResponse == nil {
                    commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
                }
                viewModel.listPricingPlans(type: selectedSegment == .first ? 1 : 2)
                await storeManager.fetchProducts(productIDs: SubzilloProducts.productIdentifiers)
                await storeManager.updatePurchasedProducts()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                justAppeared = false
            }
        }
        .onChange(of: selectedSegment) { _ in
            viewModel.listPricingPlans(type: selectedSegment == .first ? 1 : 2)
        }
        .onChange(of: viewModel.isSubscribe) { value in
            if value{
                viewModel.listPricingPlans(type: selectedSegment == .first ? 1 : 2)
            }
        }
        //        .alert(isPresented: $showPlatformAlert) {
        //            Alert(
        //                title           : Text("Subscription Notice"),
        //                message         : Text(platformAlertMessage),
        //                primaryButton   : .default(Text("Ok")) {
        ////                    if let (product, planId) = pendingProduct {
        ////                        purchaseInternal(product: product, planId: planId)
        ////                    }
        //                }
        ////                ,
        ////                secondaryButton: .cancel()
        //            )
        //        }
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
    
    //upgrade button with storekit
    //    private func getUIPlan(from plan: PricingPlan) -> PricingPlanUI {
    //        let planName            = plan.planName ?? ""
    //        let lowercasedPlanName  = planName.lowercased()
    //
    //        let isFreePlan      = lowercasedPlanName.contains("free")
    //        let isSilverPlan    = lowercasedPlanName.contains("silver")
    //        let isGoldPlan      = lowercasedPlanName.contains("gold")
    //
    //        let isYearlySelected    = selectedSegment == .second
    //
    //        var productID: String?
    //        if plan.iosProductId == nil || plan.iosProductId == ""{
    //            if isSilverPlan {
    //                productID = isYearlySelected ? SubzilloProducts.silverYearly : SubzilloProducts.silverMonthly
    //            } else if isGoldPlan {
    //                productID = isYearlySelected ? SubzilloProducts.goldYearly : SubzilloProducts.goldMonthly
    //            }
    //        }else{
    //            productID = plan.iosProductId ?? ""
    //        }
    //
    //        let isActuallyCurrent = (productID != nil && storeManager.currentActiveProductID == productID) || (isFreePlan && storeManager.currentActiveProductID == nil)
    //
    //        var buttonTitle         = ""
    //
    //        let isCurrentPlan = plan.isCurrentPlan ?? false
    //
    //        var price: String = ""
    //        var billingCycle: String = ""
    //        if let id = productID, let product = storeManager.products.first(where: { $0.id == id }) {
    //            price = product.displayPrice
    //            let period = product.subscription?.subscriptionPeriod
    //            if period?.unit == .month {
    //                billingCycle = "/ month"
    //            }
    //            if period?.unit == .year {
    //                billingCycle = "/ year"
    //            }
    //        } else {
    //            price = "\(plan.currencySymbol ?? "$")\(plan.price ?? 0.0)"
    //            billingCycle = isYearlySelected ? "/ year" : "/ month"
    //        }
    //
    //        let hierarchy = [
    //            "free",
    //            SubzilloProducts.silverMonthly,
    //            SubzilloProducts.silverYearly,
    //            SubzilloProducts.goldMonthly,
    //            SubzilloProducts.goldYearly
    //        ]
    //
    //        let currentProductID = storeManager.currentActiveProductID ?? "free"
    //        let targetProductID = productID ?? "free"
    //
    //        let currentRank = hierarchy.firstIndex(of: currentProductID) ?? 0
    //        let targetRank = hierarchy.firstIndex(of: targetProductID) ?? 0
    //
    //        if isActuallyCurrent {
    //            buttonTitle = "Current Plan"
    //        }
    //        else if isFreePlan {
    //            buttonTitle = ""
    //        }
    //        else {
    //            if targetRank > currentRank {
    //                buttonTitle = "Upgrade"
    //            } else {
    //                buttonTitle = ""
    //            }
    //        }
    //
    //        return PricingPlanUI(
    //            title           : planName,
    //            price           : isFreePlan ? nil : price,
    //            priceSubtitle   : isFreePlan ? nil : billingCycle,
    //            features        : [plan.description ?? "Basic features"],
    //            badgeColor      : isActuallyCurrent ? Color.neutral600 : nil,
    //            buttonTitle     : buttonTitle,
    //            isCurrent       : isActuallyCurrent,
    //                action          : {
    //                    if let id = productID, let product = storeManager.products.first(where: { $0.id == id }) {
    //                        Task {
    //                            if let transaction = try? await storeManager.purchase(product),
    //                               let planId = plan.id {
    //                                viewModel.pendingTransaction = transaction
    //                                print("Transaction ID \(String(transaction.id))")
    //                                subscribePlanAPI(planId: planId, transactionId: String(transaction.id))
    //                            }
    //                        }
    //                    }
    //                }
    //        )
    //    }
    
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
            if let product = storeManager.products.first(where: { $0.id == id }) {
                price = product.displayPrice
                let period = product.subscription?.subscriptionPeriod
                if period?.unit == .month {
                    billingCycle = "/ month"
                }
                if period?.unit == .year {
                    billingCycle = "/ year"
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
                buttonTitle = ""
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
                if let id = productID, let product = storeManager.products.first(where: { $0.id == id }) {
                    print("View: Purchase Button Tapped for \(product.id)")
                    handleUpgradeSelected(product: product, planId: plan.id ?? "")
                }
            }
        )
    }
    
    private func handleUpgradeSelected(product: Product, planId: String) {
        if viewModel.pricingPlanResponse?.data?.currentInternalPlanType ?? 0 == 0 {
            purchaseInternal(product: product, planId: planId)
            return
        }
        let platform = viewModel.pricingPlanResponse?.data?.subscribedPlatformType ?? 2
        if platform == 1 { // Android
            platformAlertMessage = "Dear User,We noticed that you initially registered your account and subscribed through our Android application, and you are now trying to upgrade your plan via the iOS application. avoid duplicate billing, please cancel your existing subscription on the Android application before proceeding with the upgrade here.You can find the “Cancel Subscription” option under play store.If this step is skipped, both subscriptions (Android and iOS) will remain active, and charges will be deducted from both platforms automatically during the renewal process.Thank you for your understanding and cooperation."
            AlertManager.shared.showAlert(title: "Subscription Notice", message: platformAlertMessage)
//            AlertManager.shared.showAlert(title: "Subscription Notice",
//                                          message: platformAlertMessage,
//                                          okText: "Continue",
//                                          cancelText: "Cancel",
//                                          isDestructive: true,
//                                          okAction: {
//                purchaseInternal(product: product, planId: planId)
//            })
        } else if platform == 3 { // Web
            platformAlertMessage = "Dear User, We noticed that you initially registered your account and subscribed through our web application, and you are now trying to upgrade your plan via the iOS application. To avoid duplicate billing, please cancel your existing subscription on the web application before proceeding with the upgrade here. You can find the “Cancel Subscription” option under Account Settings on the web platform. If this step is skipped, both subscriptions (web and mobile) will remain active, and charges will be deducted from both platforms automatically during the renewal process.Thank you for your understanding and cooperation."
            AlertManager.shared.showAlert(title: "Subscription Notice", message: platformAlertMessage)
        } else {
            purchaseInternal(product: product, planId: planId)
        }
    }
    
    private func purchaseInternal(product: Product, planId: String) {
        Task {
            do {
                if let transaction = try await storeManager.purchase(product) {
                    print("View: StoreKit success! Transaction ID: \(transaction.id)")
                    viewModel.pendingTransaction = transaction
                    subscribePlanAPI(planId: planId, transactionId: String(transaction.id))
                } else {
                    print("View: StoreKit returned nil (User Cancelled or Pending)")
                    viewModel.cancelPurchase()
                }
            } catch {
                print("View: StoreKit exception caught: \(error.localizedDescription)")
                viewModel.cancelPurchase()
            }
        }
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
