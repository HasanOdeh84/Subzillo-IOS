//
//  AutoEmailSyncBottomSheet.swift
//  Subzillo
//
//  Created by Antigravity on 17/02/26.
//

import SwiftUI

struct AutoEmailSyncBottomSheet: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject var settingsVM         = SettingsViewModel()
    @State private var selectedId       : String = ""
    var onSelect                        : (String) -> Void
    
    private let neverId = "never_sync_id"
    
    private var allSyncPeriods: [ListSyncPeriodResponseData] {
        let neverOption = ListSyncPeriodResponseData(id: neverId, label: "Never", durationValue: -1, durationType: "", isSelected: false)
        var list = settingsVM.listSyncPeriods ?? []
        if !list.isEmpty || settingsVM.listSyncPeriods != nil {
            list.insert(neverOption, at: 0)
        }
        return list
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 24)
            
            VStack(alignment: .leading, spacing: 32) {
                // Title
                Text("Auto Email Sync")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Subtitle
                    Text("Select your email sync duration")
                        .font(.appSemiBold(16))
                        .foregroundColor(Color.neutralMain700)
                    
                    // Options
                    VStack(alignment: .leading, spacing: 16) {
                        if settingsVM.listSyncPeriods != nil {
                            ForEach(allSyncPeriods, id: \.id) { period in
                                Button(action: {
                                    selectedId = period.id ?? ""
                                }) {
                                    HStack(spacing: 12) {
                                        Image(selectedId == period.id ? "SelectedRadio" : "UnSelectedRadio")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        
                                        Text(LocalizedStringKey(period.label ?? ""))
                                            .font(.appRegular(14))
                                            .foregroundColor(Color.neutralMain700)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } else {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                // Submit Button
                GradientBorderButton(
                    title           : "Submit",
                    isBtn           : true,
                    buttonImage     : "update",
                    action          : {
                        onSelect(selectedId == neverId ? "" : selectedId)
                        dismiss()
                    },
                    backgroundColor : .white,
                    buttonHeight    : 56
                )
                .padding(.top, 8)
                .disabled(selectedId.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .onAppear {
            settingsVM.listSyncPeriods(input: ListSyncPeriodRequest(userId: Constants.getUserId()))
        }
        .onChange(of: settingsVM.listSyncPeriods) { _ in
            if let selected = settingsVM.listSyncPeriods?.first(where: { $0.isSelected == true }) {
                selectedId = selected.id ?? ""
            }
            else {
                selectedId = neverId
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AutoEmailSyncBottomSheet(settingsVM: SettingsViewModel(), onSelect: { _ in })
}
