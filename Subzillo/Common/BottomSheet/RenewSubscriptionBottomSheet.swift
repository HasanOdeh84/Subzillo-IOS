//
//  RenewSubscriptionBottomSheet.swift
//  Subzillo
//
//  Created by Antigravity on 24/02/26.
//

import SwiftUI

struct RenewSubscriptionBottomSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    var onRenew                         : () -> Void
    var onRenewWithChanges              : () -> Void
    var onNo                            : (() -> Void)? = nil
    @State private var contentHeight    : CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top, 24)
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Renew Subscription")
                        .font(.appRegular(24))
                        .foregroundColor(.neutralMain700)
                        .padding(.top, 24)
                    
                    Text("Your plan is about to expire\nWould you like to renew with the current plan\ndetails, or modify it before renewing?")
                        .font(.appRegular(16))
                        .foregroundColor(.neutralMain700)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                
                VStack(spacing: 16) {
                    CustomButton(
                        title   : "Renew",
                        height  : 56,
                        action  : {
                            dismiss()
                            onRenew()
                        }
                    )
                    
                    GradientBorderButton(
                        title           : "Renew with Changes",
                        isBtn           : true,
                        buttonImage     : "",
                        action          : {
                            dismiss()
                            onRenewWithChanges()
                        },
                        backgroundColor : .whiteBlack,
                        buttonHeight    : 56
                    )
                    
                    CustomBorderButton(
                        title       : "No",
                        background  : Color.clear,
                        action      : {
                            dismiss()
                            onNo?()
                        }
                    )
                    .frame(height: 56)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 15)
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            contentHeight = geo.size.height
                        }
                        .onChange(of: geo.size.height) { newHeight in
                            contentHeight = newHeight
                        }
                }
            )
        }
        .background(Color.whiteBlackBG)
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .frame(height: min(contentHeight + 50 , UIScreen.main.bounds.height - 60))
    }
}

#Preview {
    RenewSubscriptionBottomSheet(
        onRenew: {},
        onRenewWithChanges: {}
    )
}
