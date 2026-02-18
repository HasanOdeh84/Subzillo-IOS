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
    @State private var selectedDuration : String = "6 months"
    let durations                       = ["6 months", "1 Year", "2 Years", "Never"]
    var onSelect                        : (String) -> Void
    
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
                        ForEach(durations, id: \.self) { duration in
                            Button(action: {
                                selectedDuration = duration
                            }) {
                                HStack(spacing: 12) {
                                    Image(selectedDuration == duration ? "SelectedRadio" : "UnSelectedRadio")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    
                                    Text(duration)
                                        .font(.appRegular(14))
                                        .foregroundColor(Color.neutralMain700)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Submit Button
                GradientBorderButton(
                    title           : "Submit",
                    isBtn           : true,
                    buttonImage     : "update",
                    action          : {
                        onSelect(selectedDuration)
                        dismiss()
                    },
                    backgroundColor : .white,
                    buttonHeight    : 56
                )
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

// MARK: - Preview
#Preview {
    AutoEmailSyncBottomSheet(onSelect: { _ in })
}
