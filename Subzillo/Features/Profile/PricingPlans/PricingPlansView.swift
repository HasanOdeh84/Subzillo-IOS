//
//  PricingPlansView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 31/01/26.
//

import SwiftUI
import StoreKit

struct PricingPlan: Identifiable {
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
    @State private var justAppeared             : Bool = false
    
    @State private var products: [SKProduct] = []
    
    //MARK: - Body
    var body: some View {
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
                
//                ZStack(alignment: .topTrailing) {
//                    Button(action: {
//                        AppIntentRouter.shared.navigate(to: .notifications)
//                    }) {
//                        Image("notification-03")
//                            .frame(width: 32, height: 32)
//                    }
//                    
//                    if let count = commonApiVM.unreadCountResponse?.unreadCount{
//                        Text("\(count)")
//                            .font(.appBold(11))
//                            .foregroundColor(Color.white)
//                            .frame(width: 16, height: 16)
//                            .background(Color.redBadge)
//                            .cornerRadius(4)
//                            .offset(x: 0, y: -5)
//                    }
//                }
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
                        PricingPlanCard(
                            plan: PricingPlan(
                                title: "Free Plan",
                                features: [
                                    "Basic renewal reminders",
                                    "Track up to 5 subscriptions",
                                    "Simple expense tracking"
                                ],
                                badgeText: "Current Plan",
                                badgeColor: Color.neutral600,
                                buttonTitle: "Current Plan",
                                isCurrent: true,
                                action: nil
                            )
                        )
                        
                        PricingPlanCard(
                            plan: PricingPlan(
                                title: "Premium Plan",
                                price: getPremiumPrice(),
                                priceSubtitle: selectedSegment == .second ? "/ year" : "/ month",
                                features: [
                                    "Basic renewal reminders",
                                    "Track up to 5 subscriptions",
                                    "Simple expense tracking"
                                ],
                                badgeText: "Recommended",
                                badgeColor: nil, // Will use gradient
                                buttonTitle: "Upgrade",
                                isCurrent: false,
                                action: {
                                    buyPremium()
                                }
                            )
                        )
                        
                        PricingPlanCard(
                            plan: PricingPlan(
                                title: "Family",
                                price: getFamilyPrice(),
                                priceSubtitle: selectedSegment == .second ? "/ year" : "/ month",
                                features: [
                                    "Basic renewal reminders",
                                    "Track up to 5 subscriptions",
                                    "Simple expense tracking"
                                ],
                                badgeText: "Family Favorite",
                                badgeColor: nil, // Will use gradient
                                buttonTitle: "Upgrade",
                                isCurrent: false,
                                action: {
                                    buyFamily()
                                }
                            )
                        )
                    }
                    
                    // MARK: tip view
                    GradienCustomeView(title: "Need help choosing?", subTitle: "Compare all features and find the perfect plan for your subscription management needs.")
                    
                    Button("Restore Purchases") {
                        restorePurchases()
                    }
                    .font(.appSemiBold(14))
                    .foregroundColor(.neutral500)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.neutralBg100)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear{
            justAppeared = true
            fetchProducts()
            //api call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                justAppeared = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshScreenData"))) { _ in
            if !justAppeared {
                fetchProducts()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .IAPHelperPurchaseNotification)) { notification in
            handlePurchaseNotification(notification)
        }
    }
    
    // MARK: - Logic Methods
    
    private func fetchProducts() {
        SubzilloProducts.store.requestProducts { success, products in
            if success, let products = products {
                DispatchQueue.main.async {
                    self.products = products
                }
            }
        }
    }
    
    private func getPremiumPrice() -> String {
        let id = (selectedSegment == .second) ? SubzilloProducts.premiumYearly : SubzilloProducts.premiumMonthly
        if let product = products.first(where: { $0.productIdentifier == id }) {
            return formatPrice(for: product)
        }
        return (selectedSegment == .second) ? "$19.99" : "$1.99" // Fallback
    }
    
    private func getFamilyPrice() -> String {
        let id = (selectedSegment == .second) ? SubzilloProducts.familyYearly : SubzilloProducts.familyMonthly
        if let product = products.first(where: { $0.productIdentifier == id }) {
            return formatPrice(for: product)
        }
        return (selectedSegment == .second) ? "$69.99" : "$6.99" // Fallback
    }
    
    private func formatPrice(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
    
    private func buyPremium() {
        let id = (selectedSegment == .second) ? SubzilloProducts.premiumYearly : SubzilloProducts.premiumMonthly
        if let product = products.first(where: { $0.productIdentifier == id }) {
            SubzilloProducts.store.buyProduct(product)
        }
    }
    
    private func buyFamily() {
        let id = (selectedSegment == .second) ? SubzilloProducts.familyYearly : SubzilloProducts.familyMonthly
        if let product = products.first(where: { $0.productIdentifier == id }) {
            SubzilloProducts.store.buyProduct(product)
        }
    }
    
    private func restorePurchases() {
        SubzilloProducts.store.restorePurchases()
    }
    
    private func handlePurchaseNotification(_ notification: Notification) {
        guard let transaction = notification.object as? SKPaymentTransaction else { return }
        print("Purchase completed: \(transaction.payment.productIdentifier)")
        // Implement further logic like API validation here
    }
}

// MARK: - Subviews

struct PricingPlanCard: View {
    let plan: PricingPlan
    
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
                    HStack(alignment: .bottom, spacing: 4) {
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
                
                CustomButton(title: plan.buttonTitle,
                             background: plan.isCurrent ? Color.neutralDisabled200 : Color.primaryBlue800,
                             textColor: plan.isCurrent ? Color.neutral500 : Color.white,
                             height: 48,
                             action: {
                    plan.action?()
                })
                .disabled(plan.isCurrent)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.neutral300Border, lineWidth: 1)
            )
            
            if let badge = plan.badgeText {
                Text(badge)
                    .font(.appSemiBold(14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(badgeBackground(for: plan))
                    .clipShape(RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight]))
                    .padding(.trailing, 24)
            }
        }
    }
    
    @ViewBuilder
    private func badgeBackground(for plan: PricingPlan) -> some View {
        if let color = plan.badgeColor {
            color
        } else {
            LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700],
                           startPoint: .leading,
                           endPoint: .trailing)
        }
    }
}

#Preview {
    PricingPlansView()
}

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
                HStack(spacing: 5) {
                    
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
                    // keep the stroke visually inside by padding the shape inward
                    RoundedCorner(radius: 8, corners: [.topLeft, .bottomLeft])
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .padding(1)                  // <- keeps stroke inside bounds
                        .opacity(selectedSegment == .first ? 0 : 1) // <- hide border when selected (without changing layout)
                )
            }
            
            // MARK: - Calendar View Button
            Button {
                selectedSegment = .second
            } label: {
                HStack(spacing: 8) {
                    
                    Text(LocalizedStringKey(rightText))
                        .font(.appSemiBold(14))
                        .foregroundColor(selectedSegment == .second ? Color.white : .navyBlueCTA700)
                    
                    Text("SAVE %24")
                        .font(.appSemiBold(14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                        .cornerRadius(18)
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
                    // keep the stroke visually inside by padding the shape inward
                    RoundedCorner(radius: 8, corners: [.topRight, .bottomRight])
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gradientPurple, Color.gradientBlue]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .padding(1)                  // <- keeps stroke inside bounds
                        .opacity(selectedSegment == .second ? 0 : 1) // <- hide border when selected (without changing layout)
                )
            }
        }
        .frame(height: 40)
    }
}
