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
    @State private var selectedSegment          : Segment? = .first
    @State private var showRenewSheet           = false
    @State private var selectedSubscription     : SubscriptionData?
    @EnvironmentObject var router               : AppIntentRouter
    @State private var hasAppeared              : Bool = false
    @State private var needsRefresh             : Bool = false
    
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
            if viewModel.subscriptions.count != 0 {
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
            }
            
            // MARK: - Subscriptions List
            if viewModel.subscriptions.count != 0 {
                ScrollView {
                    //                if viewModel.subscriptions.count != 0 {
                    VStack(spacing: 16) {
                        ForEach(viewModel.subscriptions.indices, id: \.self) { index in
                            let sub = viewModel.subscriptions[index]
                            HStack(spacing: 12) {
                                // Checkbox OUTSIDE
                                Button(action: {
                                    viewModel.toggleSelection(for: sub.id ?? "")
                                }) {
                                    Image(viewModel.selectedIds.contains(sub.id ?? "") ? "Checkmark" : "UnCheckmark")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                
                                // Individual Card
                                SubscriptionRowEmail(
                                    subscription: sub,
                                    isSelected: viewModel.selectedIds.contains(sub.id ?? ""),
                                    onToggle: {
                                        viewModel.toggleSelection(for: sub.id ?? "")
                                    },
                                    onRenew: {
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
                                    onExpire: {
                                        if let index = viewModel.subscriptions.firstIndex(where: { $0.id == sub.id }) {
                                            viewModel.subscriptions[index].isExpiredLocally = true
                                            viewModel.subscriptions[index].isRenewedLocally = false
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(.top, 10)
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    Image("noSubs")
                        .frame(width: 59, height: 80, alignment: .center)
                    
                    Text("No subscriptions found")
                        .font(.appBold(16))
                        .foregroundColor(Color.neutral800)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
            
            // MARK: - Action Buttons
            if viewModel.subscriptions.count != 0 {
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
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                if fromEmailSyncScreen {
                    
                } else {
                    self.viewModel.subscriptions = subscriptions
                }
                self.viewModel.integrationId = integrationId
                self.viewModel.getEmailSubscriptionsList()
            } else {
                // If re-appearing, refresh the list
                self.viewModel.getEmailSubscriptionsList()
            }
        }
    }
}

// MARK: - row component
struct SubscriptionRowEmail: View {
    let subscription    : SubscriptionData
    let isSelected      : Bool
    let onToggle        : () -> Void
    var onRenew         : () -> Void = {}
    var onExpire        : () -> Void = {}
    
    var body: some View {
        let isInactive = Constants.shared.isSubscriptionExpired(nextPaymentDate: subscription.nextPaymentDate ?? "") && (subscription.isExpiredLocally != true)
        let isExpired = subscription.isExpiredLocally == true
        
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(subscription.serviceName ?? "Unknown")
                    .font(.appRegular(14))
                    .foregroundColor(Color.neutralMain700)
                
                if isExpired {
                    Text("Expired")
                        .font(.appBold(14))
                        .foregroundColor(.disCardRed)
                } else {
                    Text(isInactive ? "" : "Active")
                        .font(.appBold(14))
                        .foregroundColor(isInactive ? .disCardRed : .greenLG)
                }
                
                Spacer()
                
                // Amount and Currency
                Text("\(subscription.currencySymbol ?? Constants.shared.currencyCode) \(String(format: "%.2f", subscription.amount ?? 0.0))")
                    .font(.appRegular(14))
                    .foregroundColor(Color.neutralMain700)
            }
            
            if isInactive {
                VStack(alignment: .leading, spacing: 12) {
                    Text("This service is currently inactive. Please choose an action: renew or expire.")
                        .font(.appRegular(12))
                        .foregroundColor(.disCardRed)
                        .padding(.leading, 0)
                    
                    HStack(spacing: 16) {
                        Button(action: onRenew) {
                            Text("Renew")
                                .font(.appBold(14))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 36)
                                .background(Color.navyBlueCTA700)
                                .cornerRadius(8)
                        }
                        
                        Button(action: onExpire) {
                            Text("Expire")
                                .font(.appBold(14))
                                .foregroundColor(.disCardRed)
                                .frame(width: 100, height: 36)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.disCardRed, lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isInactive ? Color.disCardRed : Color.neutral300Border, lineWidth: 1)
        )
    }
}
