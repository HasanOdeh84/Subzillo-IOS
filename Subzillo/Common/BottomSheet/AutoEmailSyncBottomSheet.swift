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
    @EnvironmentObject var themeManager : ThemeManager
    @Environment(\.colorScheme) private var colorScheme
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
                .fill(Color.capsuleBlack12White14)
                .frame(width: 40, height: 4)
                .padding(.vertical, 16)
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .center, spacing: 4) {
                    // Title
                    Text("Auto Email Sync")
                        .font(.geistSemiBold(16))
                        .foregroundColor(themeManager.textPrimaryLight_white)
                    
                    // Subtitle
                    Text("Select your email sync duration")
                        .font(.geistMedium(12))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    if settingsVM.listSyncPeriods != nil {
                        //                        ForEach(allSyncPeriods, id: \.id) { period in
                        //                            Button(action: {
                        //                                selectedId = period.id ?? ""
                        //                            }) {
                        //                                VStack {
                        //                                    HStack(spacing: 12) {
                        //                                        Image(selectedId == period.id ? "SelectedRadio" : "UnSelectedRadio")
                        //                                            .resizable()
                        //                                            .frame(width: 24, height: 24)
                        //
                        //                                        Text(LocalizedStringKey(period.label ?? ""))
                        //                                            .font(.geistMedium(13))
                        //                                            .foregroundColor(Color.textPrimary0E101AF4F1FB)
                        //                                        Spacer()
                        //                                    }
                        //                                    //.frame(height:54)
                        //                                    .padding(18)
                        //
                        //                                    Divider()
                        //                                        .overlay(colorScheme == .light ? Color.textPrimaryLight0E101A.opacity(0.10) : .white.opacity(0.08))
                        //                                }
                        //
                        //                            }
                        //                        }
                        ForEach(Array(allSyncPeriods.enumerated()), id: \.element.id) { index, period in
                            Button(action: {
                                selectedId = period.id ?? ""
                            }) {
                                VStack(spacing: 0) {
                                    HStack(spacing: 12) {
                                        Image(selectedId == period.id ? "SelectedRadio" : "UnSelectedRadio")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        
                                        Text(LocalizedStringKey(period.label ?? ""))
                                            .font(.geistMedium(13))
                                            .foregroundColor(Color.textPrimary0E101AF4F1FB)
                                        
                                        Spacer()
                                    }
                                    .padding(18)
                                    
                                    if index < allSyncPeriods.count - 1 {
                                        Divider()
                                            .overlay(
                                                colorScheme == .light
                                                ? Color.textPrimaryLight0E101A.opacity(0.10)
                                                : .white.opacity(0.08)
                                            )
                                    }
                                }
                            }
                        }
                        
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(colorScheme == .light ? .surfaceLightFFFFFF : .white.opacity(0.0392))
                    //                        .fill(themeManager.textPrimaryLight1_white8)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            colorScheme == .light ? Color.textPrimaryLight0E101A.opacity(0.10) : .white.opacity(0.08),
                            lineWidth: 1
                        )
                }
                .cornerRadius(18)
                // Submit Button
                
                /*GradientBorderButton(
                 title           : "Submit",
                 isBtn           : true,
                 buttonImage     : "update",
                 action          : {
                 onSelect(selectedId == neverId ? "" : selectedId)
                 dismiss()
                 },
                 backgroundColor : .white,
                 buttonHeight    : 56
                 )*/
                //MARK: Reset to default button
                GradientBgButton(
                    title       : "Submit",
                    isSolid     : true,
                    showChevron : false
                ) {
                    onSelect(selectedId == neverId ? "" : selectedId)
                    dismiss()
                }
                .padding(.top, 8)
                .disabled(selectedId.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            
            Spacer()
        }
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .background(.bottomBGFFFFFF120A1F)
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
