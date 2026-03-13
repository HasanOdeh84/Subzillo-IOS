import SwiftUI

struct ConnectedEmailItemView: View {
    let email                   : ListConnectedEmailsData
    let onSync                  : () -> Void
    let onView                  : () -> Void
    let onDownloadLogs          : () -> Void
    @State var provider         : EmailProvider = EmailProvider.gmail
    @State var isIntegrations   : Bool = false

    var body: some View {
        VStack() {
            HStack(spacing: 12) {
                // Provider Icon
                Image(provider.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 31, height: 31)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(email.email ?? "")
                            .font(.appSemiBold(16))
                            .foregroundStyle(Color.underlineGray)
                        Spacer()
//                        Image("download")
//                            .frame(width: 30, height: 30)
//                            .onTapGesture {
//                                onDownloadLogs()
//                            }
//                            .padding(.trailing, -16)
                    }
                    .tint(Color.underlineGray) // prevents email address from appearing blue (iOS data detection)

                    if email.lastSyncDate != "" {
                        if email.lastSyncDate != nil {
                            Text(email.lastSyncDate ?? "")
                                .font(.appRegular(14))
                                .foregroundStyle(Color.underlineGray)
                        }
                    }
                }

                Spacer()
            }

            // Action Buttons
            if !isIntegrations {
                HStack {
                    Spacer()
                    actionButtons
                }
            }
        }
        .opacity(isAllSyncing ? 0.6 : 1.0)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
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
            Text("Syncing...")
                .font(.appSemiBold(14))
                .foregroundColor(Color.blueMain700)
                .padding(.horizontal, 24)
                .frame(height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.blueMain700, lineWidth: 1)
                )
                .opacity(0.6)
        } else if syncStatus == 2 && viewStatus {
            viewButton(title: "View")
        } else if syncStatus == 0 && viewStatus{
            viewButton(title: "View")
        } else if syncStatus == 0 || (syncStatus == 2 && viewStatus == false){
            syncButton(title: "Sync")
        }
    }

    // MARK: - Reusable Button Builders
    @ViewBuilder
    private func syncButton(title: String) -> some View {
        Text(title)
            .font(.appSemiBold(14))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .frame(height: 30)
            .background(Color.blueMain700)
            .cornerRadius(5)
            .onTapGesture {
                onSync()
            }
    }

    @ViewBuilder
    private func viewButton(title: String) -> some View {
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
            .onTapGesture {
                onView()
            }
    }
}
