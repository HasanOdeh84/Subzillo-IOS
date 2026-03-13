//
//  GmailSyncProgressView.swift
//  Subzillo
//
//  Created by Antigravity on 13/03/26.
//

import SwiftUI

struct GmailSyncProgressView: View {
    
    // MARK: - Properties
    @StateObject var viewModel: GmailSyncProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(emailData: ListConnectedEmailsData) {
        _viewModel = StateObject(wrappedValue: GmailSyncProgressViewModel(emailData: emailData))
    }
    
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
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // MARK: - Subtitle
            Text("We're scanning your Gmail inbox for subscription emails.")
                .font(.appRegular(18))
                .foregroundColor(Color.neutral500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
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
                .font(.appRegular(20))
                .foregroundColor(Color.neutralMain700)
                .padding(.horizontal)
                .padding(.top, 32)
            
            // MARK: - Subscriptions List
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.recentlyFoundSubscriptions.isEmpty {
                        VStack(spacing: 10) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Searching...")
                                .font(.appRegular(16))
                                .foregroundColor(.neutral500)
                        }
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(viewModel.recentlyFoundSubscriptions.prefix(10), id: \.id) { sub in
                                RecentlyFoundCard(subscription: sub)
                                
                                if sub.id != viewModel.recentlyFoundSubscriptions.prefix(10).last?.id {
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
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
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
                .font(.appBold(24))
                .foregroundColor(Color.blueMain700)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RecentlyFoundCard: View {
    let subscription: SubscriptionData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subscription.serviceName ?? "Unknown Service")
                .font(.appSemiBold(18))
                .foregroundColor(Color.blueMain700)
            
            Text("Found in : \(subscription.subject ?? "Email")")
                .font(.appRegular(14))
                .foregroundColor(Color.neutralMain700)
            
            Text("Date : \(subscription.date ?? "Unknown Date")")
                .font(.appRegular(12))
                .foregroundColor(Color.neutral500)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
//    GmailSyncProgressView(emailData: ListConnectedEmailsData(id: "1", email: "test@gmail.com", type: 1, lastSyncDate: nil))
}
