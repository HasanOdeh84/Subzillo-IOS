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
    @State var subscriptions                    = [SubscriptionData]()
    @State var fromEmailSyncScreen              : Bool = false
    var integrationId                           : String = ""
    @State private var selectedSegment          : Segment? = .first
    @State private var showRenewSheet           = false
    @State private var selectedSubscription     : SubscriptionData?
    @EnvironmentObject var router               : AppIntentRouter
    @State private var hasAppeared               : Bool = false

    private var filteredSubscriptions: [SubscriptionData] {
        viewModel.subscriptions.filter { sub in
            if sub.isExpiredLocally == true { return false } // Don't show in active/inactive filter if manually marked as Expired? Wait, user said "update that subscription card with Expired tag without highlight the card and below text".
            
            let isInactive = Constants.shared.isSubscriptionExpired(nextPaymentDate: sub.nextPaymentDate ?? "")
            if selectedSegment == .first {
                return !isInactive // Active
            } else {
                return isInactive // Inactive
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Header
            HStack(spacing: 8) {
                Button(action: {
                    dismiss()
                }) {
                    Image("back_gray")
                }
                
                Text("Extracted Subscriptions")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                
                Spacer()
            }
            .padding(.top, 20)
            
            // MARK: - Quick Navigation & Skip All
            HStack {
                Text("Quick Navigation")
                    .font(.appRegular(18))
                    .foregroundColor(Color.neutralMain700)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Skip all")
                        .font(.appBold(16))
                        .foregroundColor(Color.navyBlueCTA700)
                }
            }
            .padding(.top, 20)
            
            // MARK: - Subscriptions List
            ScrollView {
                if viewModel.subscriptions.count != 0 {
                    VStack(spacing: 0) {
                        ForEach(viewModel.subscriptions.indices, id: \.self) { index in
                            let sub = viewModel.subscriptions[index]
                            SubscriptionRowEmail(subscription: sub, isSelected: viewModel.selectedIds.contains(sub.id ?? ""), onToggle: {
                                viewModel.toggleSelection(for: sub.id ?? "")
                            }, onTap: {
                                let isInactive = Constants.shared.isSubscriptionExpired(nextPaymentDate: sub.nextPaymentDate ?? "") && (sub.isExpiredLocally != true)
                                if isInactive {
                                    selectedSubscription = sub
                                    showRenewSheet = true
                                }
                            })
                            
                            if index != viewModel.subscriptions.count - 1 {
                                Divider()
                                    .background(Color.neutral300Border)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .padding(.top, 12)
                    .padding(.horizontal, 2)
                } else {
                    HStack {
                        Spacer()
                        Text("No data found")
                            .padding(30)
                            .foregroundStyle(Color.gray)
                            .font(.appRegular(16))
                        Spacer()
                    }
                }
            }
            .padding(.top, 10)
            
            // MARK: - Action Buttons
            if viewModel.showActionButtons {
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.showDeletePopup = true
                    }) {
                        Text("Delete")
                            .font(.appBold(18))
                            .foregroundColor(Color("redColor"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.systemError)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        hasAppeared = false
                        viewModel.continueAction()
                    }) {
                        Text("Continue")
                            .font(.appBold(18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.navyBlueCTA700)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 20)
                .padding(.top, 20)
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden()
        .background(Color.neutralBg100)
        .sheet(isPresented: $viewModel.showDeletePopup , onDismiss: {
            // onDismiss logic
        }) {
            InfoAlertSheet(
                onDelegate: {
                    viewModel.deleteSelected(fromEmailSyncScreen: fromEmailSyncScreen)
                }, title    : "Are you sure you want to delete the subscriptions?\nData will be permanently deleted",
                subTitle    :"",
                imageName   : "del_red_big",
                buttonIcon  : "deleteIcon",
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
        .sheet(isPresented: $showRenewSheet) {
            RenewSubscriptionBottomSheet(
                title   : "Renew subscription",
                desc    : "This service is currently inactive. Please choose an action: renew or expire.",
                btn1    : "Renew",
                btn2    : "Expired",
                btn3    : "No",
                onRenew : {
                    if let sub = selectedSubscription {
                        //                        let nextDate = Constants.shared.getNextDateByFrequency(frequency: sub.billingCycle ?? "Monthly", baseDate: sub.nextPaymentDate?.toDate(format: "yyyy-MM-dd") ?? Date())
                        
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = "yyyy-MM-dd"
//                        var chargeDate : String = ""
//                        // Use the original yyyy-MM-dd string for parsing
//                        if let baseDate = formatter.date(from: sub.nextPaymentDate ?? "") {
//                            chargeDate = Constants.shared.getNextDateByFrequency(
//                                frequency: sub.billingCycle ?? "Monthly",
//                                baseDate: baseDate
//                            )
//                        } else {
//                            chargeDate = Constants.shared.getNextDateByFrequency(
//                                frequency: sub.billingCycle ?? "Monthly"
//                            )
//                        }
                        
                        var renewSub = sub
//                        renewSub.nextPaymentDate = chargeDate
                        
                        globalSubscriptionData = renewSub
                        router.navigate(to: .manualEntry(isRenew: true, subscriptionId: sub.id ?? "", isFromEmail: true, isFromEmailExtracted: true))
                    }
                },
                onRenewWithChanges: {
                    if let sub = selectedSubscription {
                        if let index = viewModel.subscriptions.firstIndex(where: { $0.id == sub.id }) {
                            viewModel.subscriptions[index].isExpiredLocally = true
                            viewModel.subscriptions[index].isRenewedLocally = false
                        }
                    }
                },
                onNo: {
                    showRenewSheet = false
                }
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(350)])
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                if fromEmailSyncScreen {
                    
                } else {
                    self.viewModel.subscriptions = subscriptions
                }
                self.viewModel.integrationId = integrationId
                self.viewModel.getEmailSubscriptionsList()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SubscriptionRenewedLocally"))) { notification in
            if let updatedSub = notification.userInfo?["subscription"] as? SubscriptionData {
                if let index = viewModel.subscriptions.firstIndex(where: { $0.id == updatedSub.id }) {
                    viewModel.subscriptions[index] = updatedSub
                    viewModel.subscriptions[index].isRenewedLocally = true
                    viewModel.subscriptions[index].isExpiredLocally = false
                }
            }
        }
    }
}

// MARK: - row component
struct SubscriptionRowEmail: View {
    let subscription    : SubscriptionData
    let isSelected      : Bool
    let onToggle        : () -> Void
    let onTap           : () -> Void
    
    var body: some View {
        let isInactive = Constants.shared.isSubscriptionExpired(nextPaymentDate: subscription.nextPaymentDate ?? "") && (subscription.isExpiredLocally != true)
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Checkbox
                Button(action: onToggle) {
                    Image(isSelected ? "Checkmark" : "UnCheckmark")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                
                // Service Name and Status
                HStack(spacing: 8) {
                    Text(subscription.serviceName ?? "Unknown")
                        .font(.appRegular(14))
                        .foregroundColor(Color.neutralMain700)
                    
                    if subscription.isExpiredLocally == true {
                        Text("Expired")
                            .font(.appBold(14))
                            .foregroundColor(.disCardRed)
                    } else {
                        Text(isInactive ? "" : "Active")
                            .font(.appBold(14))
                            .foregroundColor(isInactive ? .disCardRed : .greenLG)
                    }
                }
                
                Spacer()
                
                // Amount and Currency
                Text("\(subscription.currencySymbol ?? Constants.shared.currencySymbol) \(String(format: "%.2f", subscription.amount ?? 0.0))")
                    .font(.appRegular(14))
                    .foregroundColor(Color.neutralMain700)
            }
            
            if isInactive {
                Text("This service is currently inactive. Please choose an action: renew or expire.")
                    .font(.appRegular(12))
                    .foregroundColor(.disCardRed)
                    .padding(.leading, 36)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isInactive ? Color.disCardRed : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
//    ExtractedSubscriptionsView(subscriptions: [
//        SubscriptionData(id: "1", serviceName: "Replit", amount: 50.20, currency: "USD", status: "Expired"),
//        SubscriptionData(id: "2", serviceName: "Replit", amount: 50.20, currency: "USD", status: "Active"),
//        SubscriptionData(id: "3", serviceName: "Replit", amount: 50.20, currency: "USD", status: "Expired")
//    ])
}
