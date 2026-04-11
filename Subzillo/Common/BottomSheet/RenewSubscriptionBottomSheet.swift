//
//  RenewSubscriptionBottomSheet.swift
//  Subzillo
//
//  Created by Antigravity on 24/02/26.
//

import SwiftUI

struct RenewSubscriptionBottomSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    var title                           : String = "Renew Subscription"
    var desc                            : String = "Your plan is about to expire\nWould you like to renew with the current plan\ndetails, or modify it before renewing?"
    var btn1                            : String = "Renew"
    var btn2                            : String = "Expired"
    var btn3                            : String = "No"
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
                    Text(title)
                        .font(.appRegular(24))
                        .foregroundColor(.neutralMain700)
                        .padding(.top, 24)
                    
                    Text(desc)
                        .font(.appRegular(16))
                        .foregroundColor(.neutralMain700)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                
                VStack(spacing: 16) {
                    CustomButton(
                        title   : btn1,
                        height  : 56,
                        action  : {
                            dismiss()
                            onRenew()
                        }
                    )
                    
                    GradientBorderButton(
                        title           : btn2,
                        isBtn           : true,
                        buttonImage     : "",
                        action          : {
                            dismiss()
                            onRenewWithChanges()
                        },
                        backgroundColor : .whiteBlack,
                        buttonHeight    : 56
                    )
                    
                    if btn3 != ""{
                        CustomBorderButton(
                            title       : btn3,
                            background  : Color.clear,
                            action      : {
                                dismiss()
                                onNo?()
                            }
                        )
                        .frame(height: 56)
                    }
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
