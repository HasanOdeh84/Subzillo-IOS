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
    let action: (() -> Void)?
    
    init(title: String, price: String? = nil, priceSubtitle: String? = nil, features: [String], badgeText: String? = nil, badgeColor: Color? = nil, buttonTitle: String, isCurrent: Bool = false, action: (() -> Void)? = nil) {
        self.title = title
        self.price = price
        self.priceSubtitle = priceSubtitle
        self.features = features
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.buttonTitle = buttonTitle
        self.isCurrent = isCurrent
        self.action = action
    }
}


struct PricingPlansView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSegment          : Segment? = .first
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @StateObject private var storeManager       = StoreManager.shared
    @StateObject private var viewModel          = PricingPlansViewModel()
    @State private var justAppeared             : Bool = false
    
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
                            .environment(\.openURL, OpenURLAction { url in
                                if url.absoluteString.contains("privacy") {
//                                    AppIntentRouter.shared.navigate(to: .termsAndPrivacy(isTerm: false))
                                } else if url.absoluteString.contains("terms") {
//                                    AppIntentRouter.shared.navigate(to: .termsAndPrivacy(isTerm: true))
                                }
                                return .handled
                            })
                        
                        Button {
                            Task {
                                try? await storeManager.restorePurchases()
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
                        storeManager.purchaseState = .idle
                    }
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            justAppeared = true
            Task {
                viewModel.listPricingPlans()
                await storeManager.fetchProducts(productIDs: SubzilloProducts.productIdentifiers)
                await storeManager.updatePurchasedProducts()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                justAppeared = false
            }
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
    
    private func getUIPlan(from plan: PricingPlan) -> PricingPlanUI {
        let name = plan.planName ?? ""
        let isSilver = name.lowercased().contains("silver")
        let isGold = name.lowercased().contains("gold")
        let isFree = name.lowercased().contains("free")
        
        var productID: String?
        if isSilver {
            productID = (selectedSegment == .second) ? SubzilloProducts.silverYearly : SubzilloProducts.silverMonthly
        } else if isGold {
            productID = (selectedSegment == .second) ? SubzilloProducts.goldYearly : SubzilloProducts.goldMonthly
        }
        
        var displayPrice: String = ""
        var billingCycle: String = ""
        if let id = productID, let product = storeManager.products.first(where: { $0.id == id }) {
            displayPrice = product.displayPrice
            let period = product.subscription?.subscriptionPeriod
            if period?.unit == .month {
                billingCycle = "/ month"
            }
            if period?.unit == .year {
                billingCycle = "/ month"
            }
        } else {
            displayPrice = "\(plan.currencySymbol ?? "$")\(plan.price ?? 0.0)"
            billingCycle = (selectedSegment == .second ? "/ year" : "/ month")
        }
        
        return PricingPlanUI(
            title           : name,
            price           : isFree ? nil : displayPrice,
            priceSubtitle   : isFree ? nil : billingCycle,
            features        : [plan.description ?? "Basic features"],
            //            badgeColor      : isFree && (plan.isCurrentPlan ?? false) ? Color.neutral600 : nil,
            badgeColor      : (plan.isCurrentPlan ?? false) ? Color.neutral600 : nil,
            buttonTitle     : (plan.isCurrentPlan ?? false) ? "Current Plan" : (isFree ? "" : "Upgrade"),
            isCurrent       : plan.isCurrentPlan ?? false,
            action          : {
                if let id = productID, let product = storeManager.products.first(where: { $0.id == id }) {
                    Task {
                        try? await storeManager.purchase(product)
                    }
                }
            }
        )
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
                    .disabled(plan.isCurrent)
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
