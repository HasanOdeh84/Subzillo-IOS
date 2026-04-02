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

//    init(subscriptions: [SubscriptionData], fromEmailSyncScreen:Bool = false) {
//        _viewModel = StateObject(wrappedValue: ExtractedSubscriptionsViewModel(subscriptions: subscriptions))
//        self.fromEmailSyncScreen = fromEmailSyncScreen
//    }
    
    private var filteredSubscriptions: [SubscriptionData] {
        viewModel.subscriptions.filter { sub in
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
            
            // MARK: Toggle
//            PlanToggleView(selectedSegment : $selectedSegment,
//                           leftText        : "Active",
//                           rightText       : "Inactive")
//            .padding(.top, 20)
            
            // MARK: - Subscriptions List
            ScrollView {
//                if filteredSubscriptions.count != 0{
                if viewModel.subscriptions.count != 0{
                    VStack(spacing: 0) {
//                        ForEach(filteredSubscriptions, id: \.id) { sub in
                        ForEach(viewModel.subscriptions, id: \.id) { sub in
                            SubscriptionRowEmail(subscription: sub, isSelected: viewModel.selectedIds.contains(sub.id ?? ""), onToggle: {
                                viewModel.toggleSelection(for: sub.id ?? "")
                            })
                            
//                            if sub.id != filteredSubscriptions.last?.id {
                            if sub.id != viewModel.subscriptions.last?.id {
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
                }else{
                    HStack{
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
                    
                    Button(action: { viewModel.continueAction() }) {
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
        .onAppear{
            if fromEmailSyncScreen {
                
            } else {
                self.viewModel.subscriptions = subscriptions
            }
            self.viewModel.integrationId = integrationId
            self.viewModel.getEmailSubscriptionsList()
        }
    }
}

// MARK: - row component
struct SubscriptionRowEmail: View {
    let subscription    : SubscriptionData
    let isSelected      : Bool
    let onToggle        : () -> Void
    
    var body: some View {
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
                
                let status = Constants.shared.isSubscriptionExpired(nextPaymentDate: subscription.nextPaymentDate ?? "")
                Text(status ? "InActive" : "Active")
                    .font(.appBold(14))
                    .foregroundColor(status ? .disCardRed : .greenLG)
            }
            
            Spacer()
            
            // Amount and Currency
            Text("\(subscription.currencySymbol ?? Constants.shared.currencySymbol) \(String(format: "%.2f", subscription.amount ?? 0.0))")
                .font(.appRegular(14))
                .foregroundColor(Color.neutralMain700)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
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
