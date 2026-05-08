import SwiftUI

struct ConnectedEmailItemView: View {
    @State private var isExpanded: Bool = false
    let email                   : ListConnectedEmailsData
    let onSync                  : () -> Void
    let onSyncing               : () -> Void
    let onView                  : () -> Void
    let onDownloadLogs          : () -> Void
    let onReconnect             : () -> Void
    @State var provider         : EmailProvider = EmailProvider.gmail
    @State var isIntegrations   : Bool = false
    var isInlineSyncing         : Bool = false
    var emailsScanned           : Int = 0
    var subscriptionsFound      : Int = 0
    
    var body: some View {
        VStack() {
            HStack(spacing: 12) {
                // Provider Icon
                Image(provider.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 31, height: 31)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(email.email ?? "")
                        .font(.appSemiBold(16))
                        .foregroundStyle(Color.underlineGray)
                    
                    if let lastSync = email.lastSyncDate, !lastSync.isEmpty {
                        Text(lastSync)
                            .font(.appRegular(14))
                            .foregroundStyle(Color.underlineGray)
                    }
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.neutral500)
                    .font(.system(size: 14, weight: .semibold))
            }
//            .opacity(isAllSyncing ? 0.6 : 1.0)
            
            // Action Buttons
            if !isIntegrations {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        actionButtons
                        
                        if isExpanded {
                            Divider()
                                .padding(.vertical, 10)
                            
                            if isInlineSyncing {
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Emails Scanned")
                                            .font(.appRegular(14))
                                            .foregroundColor(Color.neutral500)
                                        
                                        Text("\(emailsScanned)")
                                            .font(.appBold(16))
                                            .foregroundColor(Color.navyBlueCTA700)
                                    }
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Subscription Found")
                                            .font(.appRegular(14))
                                            .foregroundColor(Color.neutral500)
                                        
                                        Text("\(subscriptionsFound)")
                                            .font(.appBold(16))
                                            .foregroundColor(Color.navyBlueCTA700)
                                    }
                                    Spacer()
                                    ProgressView()
                                        .scaleEffect(1.5)
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    Text("No sync in progress")
                                        .font(.appRegular(14))
                                        .foregroundColor(Color.neutral500)
                                    Spacer()
                                }
                                .padding(.bottom, 5)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .onAppear {
            if email.type == 1 {
                self.provider = EmailProvider.gmail
            } else if email.type == 2 {
                provider = EmailProvider.microsoft
            } else {
                provider = EmailProvider.yahoo
            }
        }
    }
    
    // MARK: - Helpers
    private var isAllSyncing: Bool {
        let statuses = [
            email.syncStatus
        ]
        return statuses.allSatisfy { $0 == 1 }
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 12) {
            approachButton()
        }
    }
    
    @ViewBuilder
    private func approachButton() -> some View {
        let syncStatus = email.syncStatus ?? 0
        let viewStatus = email.viewStatus ?? false
        if syncStatus == 1 {
            HStack(spacing: 10){
                Button(action: { onSyncing() }) {
                    Text("Syncing...")
                        .font(.appSemiBold(14))
                        .foregroundColor(Color.blueMain700)
                        .padding(.horizontal, 24)
                        .frame(height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.blueMain700, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(0.6)
                
                viewButton()
            }
        } else if syncStatus == 2 && viewStatus {
            viewButton()
        } else if syncStatus == 0 && viewStatus{
            viewButton()
        } else if syncStatus == 0 || (syncStatus == 2 && viewStatus == false){
            HStack(spacing: 12){
                if email.isValid == false && email.type == 1 {
                    reconnectButton(title: "Reconnect")
                }
                syncButton(title: "Sync")
                viewButton()
            }
        }
    }
    
    // MARK: - Reusable Button Builders
    @ViewBuilder
    private func reconnectButton(title: String) -> some View {
        Button(action: { onReconnect() }) {
            Text(title)
                .font(.appSemiBold(14))
                .foregroundColor(.redBadge)
                .padding(.horizontal, 16)
                .frame(height: 30)
                .background(Color.white)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            Color.redBadge,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func syncButton(title: String) -> some View {
        Button(action: {
            Constants.saveDefaults(value: true, key: "isSyncing")
            onSync()
        }) {
            Text(title)
                .font(.appSemiBold(14))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .frame(height: 30)
                .background(Color.blueMain700)
                .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func viewButton() -> some View {
        let isSyncingStatus = email.syncStatus == 1
        let title = isSyncingStatus ? "View Progress" : "View Results"
        
        Button(action: {
            Constants.saveDefaults(value: true, key: "isSyncing")
            if isSyncingStatus {
                onSyncing()
            } else {
                onView()
            }
        }) {
            Text(title)
                .font(.appSemiBold(14))
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .padding(.horizontal, 24)
                .frame(height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
