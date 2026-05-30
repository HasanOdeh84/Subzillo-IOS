//
//  ExtractedSubscriptionsView.swift
//  Subzillo
//
//  Created by Antigravity on 13/03/26.
//

import SwiftUI

struct ExtractedSubscriptionsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel                  = ExtractedSubscriptionsViewModel()
    @State private var deleteSheetHeight        : CGFloat = .zero
    @State private var renewSheetHeight         : CGFloat = .zero
    @State var subscriptions                    = [SubscriptionData]()
    @State var fromEmailSyncScreen              : Bool = false
    var integrationId                           : String = ""
    @State private var showRenewSheet           = false
    @State private var selectedSubscription     : SubscriptionData?
    @EnvironmentObject var router               : AppIntentRouter
    @State private var hasAppeared              : Bool = false
    @State private var needsRefresh             : Bool = false
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    private var activeSubscriptions: [SubscriptionData] {
        viewModel.subscriptions.filter { sub in
            if sub.isExpiredLocally == true { return false }
            return !Constants.shared.isSubscriptionExpired(nextPaymentDate: sub.nextPaymentDate ?? "")
        }
    }
    
    private var inactiveSubscriptions: [SubscriptionData] {
        viewModel.subscriptions.filter { sub in
            if sub.isExpiredLocally == true { return false }
            return Constants.shared.isSubscriptionExpired(nextPaymentDate: sub.nextPaymentDate ?? "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
            HStack(spacing: 8) {
                
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                
                //                Spacer()
                //
                //                Text("\(viewModel.subscriptions.count) found")
                //                    .font(.geistSemiBold(16))
                //                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                
                Spacer()
                
            }
            .padding(.top, 10)
            .overlay(
                Text("\(viewModel.subscriptions.count) found")
                    .font(.geistSemiBold(16))
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    .padding(.top, 10)
            )
            
            // MARK: - Title
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("Here's what Subzi")
                        .font(.geistSemiBold(26))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                    Text("found")
                        .font(.appSemiBoldItalic(26))
//                        .italic()
                        .foregroundStyle(
                            themeManager.gradient(style: .vertical)
                        )
                }
                
                Text("Validated against our catalogue. Confirm the active ones; skip anything expired or already cancelled.")
                    .font(.geistMedium(12))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    .lineSpacing(4)
            }
            .padding(.top, 24)
            
            // MARK: - Subscriptions List
            if viewModel.subscriptions.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image("noSubs")
                        .frame(width: 59, height: 80, alignment: .center)
                    
                    Text("No subscriptions found")
                        .foregroundStyle(.textPrimary0E101AF4F1FB)
                        .font(.geistSemiBold(16))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - Active Section
                        if !activeSubscriptions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color("Success_0EA870_5CE4A8"))
                                        .frame(width: 6, height: 6)
                                        .shadow(color: .success0EA8705CE4A8.opacity(0.80), radius: 4, x: 0, y: 0)
                                    
                                    Text("ACTIVE • \(activeSubscriptions.count)")// recent receipts")
                                        .font(.jetBrainsSemiBold(10))
                                        .tracking(1.5)
                                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                    
                                    //                                    Text("•")
                                    //                                        .font(.system(size: 10))
                                    //                                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                                    //
                                    //                                    Text("\(activeSubscriptions.count) recent receipts")
                                    //                                        .font(.jetBrainsRegular(11))
                                    //                                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6))
                                    
                                    Spacer()
                                    
                                    let allSelected = viewModel.selectedIds.count == viewModel.subscriptions.count
                                    
                                    Button(action: {
                                        if allSelected {
                                            viewModel.selectedIds.removeAll()
                                        } else {
                                            for sub in viewModel.subscriptions {
                                                if let id = sub.id {
                                                    viewModel.selectedIds.insert(id)
                                                }
                                            }
                                        }
                                    }) {
                                        Text(allSelected ? "Unselect all" : "Select all")
                                            .font(.geistBold(12))
                                            .foregroundStyle(
                                                themeManager.accentGradient
                                            )
                                    }
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(activeSubscriptions, id: \.id) { sub in
                                        SubscriptionRowEmail(
                                            subscription    : sub,
                                            isSelected      : viewModel.selectedIds.contains(sub.id ?? ""),
                                            isActive        : true,
                                            onToggle        : {
                                                viewModel.toggleSelection(for: sub.id ?? "")
                                            },
                                            onRenew         : {
                                                selectedSubscription = sub
                                                router.navigate(to: .subscriptionPreviewView(
                                                    subscriptionsData   : [sub],
                                                    content             : "",
                                                    isFromImage         : false,
                                                    isFromEmail         : true,
                                                    audioUrl            : nil,
                                                    fromEmailSync       : true,
                                                    isRenew             : true
                                                ))
                                            },
                                            onExpire        : {
                                                if let index = viewModel.subscriptions.firstIndex(where: { $0.id == sub.id }) {
                                                    viewModel.subscriptions[index].isExpiredLocally = true
                                                    viewModel.subscriptions[index].isRenewedLocally = false
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Maybe Expired Section
                        if !inactiveSubscriptions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 6) {
                                    
                                    Circle()
                                        .fill(Color.warningAnyFFCB5C)
                                        .frame(width: 6, height: 6)
                                        .shadow(color: .warningAnyFFCB5C.opacity(0.80), radius: 4, x: 0, y: 0)
                                    
                                    Text("MAYBE EXPIRED • \(inactiveSubscriptions.count)")// no receipt in 4+ months")
                                        .font(.jetBrainsSemiBold(10))
                                        .tracking(1.5)
                                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                                    
                                    Spacer()
                                    
                                    let allSelected = viewModel.selectedIds.count == viewModel.subscriptions.count
                                    
                                    if activeSubscriptions.count == 0{
                                        Button(action: {
                                            if allSelected {
                                                viewModel.selectedIds.removeAll()
                                            } else {
                                                for sub in viewModel.subscriptions {
                                                    if let id = sub.id {
                                                        viewModel.selectedIds.insert(id)
                                                    }
                                                }
                                            }
                                        }) {
                                            Text(allSelected ? "Unselect all" : "Select all")
                                                .font(.geistBold(12))
                                                .foregroundStyle(
                                                    themeManager.accentGradient
                                                )
                                        }
                                    }
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(inactiveSubscriptions, id: \.id) { sub in
                                        SubscriptionRowEmail(
                                            subscription    : sub,
                                            isSelected      : viewModel.selectedIds.contains(sub.id ?? ""),
                                            isActive        : false,
                                            onToggle        : {
                                                viewModel.toggleSelection(for: sub.id ?? "")
                                            },
                                            onRenew         : {
                                                selectedSubscription = sub
                                                router.navigate(to: .subscriptionPreviewView(
                                                    subscriptionsData   : [sub],
                                                    content             : "",
                                                    isFromImage         : false,
                                                    isFromEmail         : true,
                                                    audioUrl            : nil,
                                                    fromEmailSync       : true,
                                                    isRenew             : true
                                                ))
                                            },
                                            onExpire        : {
                                                if let index = viewModel.subscriptions.firstIndex(where: { $0.id == sub.id }) {
                                                    viewModel.subscriptions[index].isExpiredLocally = true
                                                    viewModel.subscriptions[index].isRenewedLocally = false
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        
                    }
                    .padding(.top, 24)
                }
                
                if viewModel.selectedIds.count != 0{
                    GradientBgButton(
                        title       : "Add \(viewModel.selectedIds.count)",
                        isSolid     : true,
                        showChevron : true
                    ) {
                        hasAppeared = false
                        viewModel.continueAction()
                    }
                }
                
                Spacer(minLength: 120)
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden()
        .applyAppBackground()
        .sheet(isPresented: $viewModel.showDeletePopup , onDismiss: {
            // onDismiss logic
        }) {
            InfoAlertSheet(
                onDelegate: {
                    viewModel.deleteSelected(fromEmailSyncScreen: fromEmailSyncScreen)
                }, title    : "Are you sure you want to delete the subscriptions?\nData will be permanently deleted",
                subTitle    :"",
                imageName   : "del_red_new",
                buttonIcon  : "del_red_newSmall",
                buttonTitle : "Delete",
                imageSize   : 70
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
        .onAppear {
            //            if !hasAppeared {
            //                hasAppeared = true
            //                if fromEmailSyncScreen {
            //
            //                } else {
            //                    self.viewModel.subscriptions = subscriptions
            //                }
            //                self.viewModel.integrationId = integrationId
            //                self.viewModel.getEmailSubscriptionsList()
            //            } else {
            //                // If re-appearing, refresh the list
            //                self.viewModel.getEmailSubscriptionsList()
            //            }
            self.viewModel.subscriptions = subscriptions
            self.viewModel.integrationId = integrationId
            self.viewModel.getEmailSubscriptionsList()
            
            //            // Auto select active ones initially like in mock
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //                if viewModel.selectedIds.isEmpty {
            //                    for sub in activeSubscriptions {
            //                        if let id = sub.id {
            //                            viewModel.selectedIds.insert(id)
            //                        }
            //                    }
            //                }
            //            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshExtractedSubs)) { _ in
            self.viewModel.getEmailSubscriptionsList()
        }
    }
}

// MARK: - Row Component
struct SubscriptionRowEmail: View {
    let subscription    : SubscriptionData
    let isSelected      : Bool
    let isActive        : Bool
    let onToggle        : () -> Void
    var onRenew         : () -> Void = {}
    var onExpire        : () -> Void = {}
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                //                ZStack {
                //                    RoundedRectangle(cornerRadius: 12)
                //                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                //                        .frame(width: 44, height: 44)
                //
                //                    if let logo = subscription.serviceLogo, !logo.isEmpty, let url = URL(string: logo) {
                //                        AsyncImage(url: url) { image in
                //                            image.resizable().scaledToFill()
                //                        } placeholder: {
                //                            Text(String(subscription.serviceName?.first ?? "U"))
                //                                .font(.appBold(20))
                //                                .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                //                        }
                //                        .frame(width: 24, height: 24)
                //                        .clipShape(RoundedRectangle(cornerRadius: 6))
                //                    } else {
                //                        // Fallback letter
                //                        Text(String(subscription.serviceName?.first ?? "U"))
                //                            .font(.appBold(20))
                //                            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                //                    }
                //                }
                
                AvatarView(serviceName  : subscription.serviceName ?? "",
                           serviceLogo  : subscription.serviceLogo ?? "",
                           size         : 38,
                           isShadow     : false)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(subscription.serviceName ?? "Unknown")
                            .font(.geistSemiBold(13))
                            .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                        
                        // Tag
                        Text(isActive ? "ACTIVE" : "MAYBE EXPIRED")
                            .font(.jetBrainsMedium(9))
                            .tracking(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(isActive ? Color("Success_0EA870_5CE4A8").opacity(0.133) : Color.warningAnyFFCB5C.opacity(0.133))
                            .foregroundColor(isActive ? Color("Success_0EA870_5CE4A8") : Color.warningAnyFFCB5C)
                            .cornerRadius(4)
                    }
                    
                    // Description
                    let plan = subscription.subscriptionType ?? subscription.categoryName ?? "Standard"
                    let priceText = "\(subscription.currencySymbol ?? Constants.shared.currencyCode)\(String(format: "%.2f", subscription.amount ?? 0.0))\(subscription.billingCycleShortLabel ?? "/mo")"
                    Text("\(plan) • \(priceText)")
                        .font(.jetBrainsBold(10))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                }
                
                Spacer()
                
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isSelected ? themeManager.accentGradient : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 24, height: 24)
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
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.clear : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.textPrimaryLight14_white14, lineWidth: 1)
            )
            .opacity(isActive || isSelected ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

