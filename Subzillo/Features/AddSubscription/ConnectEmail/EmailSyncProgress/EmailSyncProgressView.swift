//
//  EmailSyncProgressView.swift
//  Subzillo
//
//  Created by Antigravity on 13/03/26.
//

import SwiftUI

struct EmailSyncProgressView: View {
    
    // MARK: - Properties
    @StateObject var viewModel  = EmailSyncProgressViewModel()
    @State var logId            : String
    @Environment(\.dismiss) private var dismiss
    @State private var isNavigatingToManualEntry = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.goBack()
                    dismiss()
                })
                {
                    Image("back_gray")
                }
                
                Text("Gmail Sync Progress")
                    .font(.appRegular(20))
                    .foregroundColor(Color.neutralMain700)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // MARK: - Subtitle
            Text("We're scanning your Gmail inbox for subscription emails.")
                .font(.appRegular(16))
                .foregroundColor(Color.neutral500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .frame(maxWidth: .infinity)
            
            // MARK: - Progress Stats Cards
            HStack(spacing: 16) {
                StatCard(title: "Emails Scanned", value: "\(viewModel.emailsScannedCount)")
                StatCard(title: "Subscription Found", value: "\(viewModel.subscriptionsFoundCount)")
            }
            .padding(.horizontal)
            .padding(.top, 24)
            
            // MARK: - Recently Found Section
            Text("Recently Found Subscription")
                .font(.appRegular(18))
                .foregroundColor(Color.neutralMain700)
                .padding(.horizontal)
                .padding(.top, 24)
            
            // MARK: - Subscriptions List
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.recentlyFoundSubscriptions.isEmpty {
                        VStack(spacing: 10) {
//                            if viewModel.syncStatusData?.syncStatus == "in_progress" ||  viewModel.syncStatusData?.syncStatus == "pending"{
//                                ProgressView()
//                                    .scaleEffect(1.5)
//                                Text("Searching...")
//                                    .font(.appRegular(16))
//                                    .foregroundColor(.neutral500)
//                            }
                            if viewModel.syncStatusData?.syncStatus != "completed"{
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Scanning...")
                                    .font(.appRegular(16))
                                    .foregroundColor(.neutral500)
                            }
                        }
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(viewModel.recentlyFoundSubscriptions, id: \.id) { sub in
                                RecentlyFoundCard(subscription: sub)
                                if sub.id != viewModel.recentlyFoundSubscriptions.last?.id {
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
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden()
        .background(Color.neutralBg100)
        .onAppear {
            viewModel.startPolling(logId: logId)
        }
        .onDisappear {
            viewModel.stopPolling()
        }
        .sheet(isPresented: $viewModel.showErrorPopup, onDismiss: {
            if !isNavigatingToManualEntry {
                dismiss()
            }
            isNavigatingToManualEntry = false
        }) {
            UploadErrorImageSheet(
                isImage         : false,
                fromEmailSync   : true,
                onDelegate      : {
                    isNavigatingToManualEntry = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false, fromEmailSync: true))
                    }
                },
                onDismiss       : {
                }
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(500)])
        }
    }
}

// MARK: - Subviews
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appRegular(14))
                .foregroundColor(Color.neutral500)
            
            Text(value)
                .font(.appBold(16))
                .foregroundColor(Color.navyBlueCTA700)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(7)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
//        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RecentlyFoundCard: View {
    let subscription: RecentSubscriptionData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subscription.serviceName ?? "Unknown Service")
                .font(.appBold(16))
                .foregroundColor(Color.blueMain700)
            
            Text("Found in : \(subscription.subject ?? "Email")")
                .font(.appRegular(14))
                .foregroundColor(Color.neutralMain700)
            
            Text("Date : \(subscription.emailDate ?? "Unknown Date")")
                .font(.appRegular(12))
                .foregroundColor(Color.neutral500)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    EmailSyncProgressView(logId: "")
}
