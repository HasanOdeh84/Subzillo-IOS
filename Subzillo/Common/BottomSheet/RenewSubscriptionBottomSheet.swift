//
//  RenewSubscriptionBottomSheet.swift
//  Subzillo
//
//  Created by Antigravity on 24/02/26.
//

import SwiftUI

struct RenewSubscriptionBottomSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    var isLoginMethods                  : Bool = false
    var title                           : String = "Renew Subscription"
    var desc                            : String = "Your plan is about to expire\nWould you like to renew with the current plan details, or modify it before renewing?"
    var btn1                            : String = "Renew"
    var btn2                            : String = "Renew with changes"
    var btn3                            : String = "No"
    var onRenew                         : () -> Void
    var onRenewWithChanges              : () -> Void
    var onNo                            : (() -> Void)? = nil
    @State private var contentHeight    : CGFloat = .zero
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.capsuleBlack12White14)
                .frame(width: 40, height: 4)
                .padding(.vertical, 16)
            
            VStack(spacing: 24) {
                
                if isLoginMethods == true {
                    Image("loginIcon")
                        .renderingMode(.template)
                        .foregroundStyle(themeManager.accentGradient)
                        .frame(width: 80, height: 80)
//                        .padding(.bottom, 18)
                }else if title == "Renew Subscription"{
                    Image("renew_new")
                        .renderingMode(.template)
                        .foregroundStyle(themeManager.accentGradient)
                        .frame(width: 80, height: 80)
                    //                        .padding(.bottom, 18)
                }
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.geistSemiBold(16))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB)
                    
                    Text(desc)
                        .font(.geistMedium(12))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 16) {
                    GradientBgButton(
                        title       : btn1,
                        isSolid     : true,
                        showChevron : false,
                        action      : {
                            dismiss()
                            onRenew()
                        }
                    )
                    
                    if btn2 != ""{
                        if title == "Renew Subscription" || isLoginMethods{
                            GradientBgButton(
                                title       : btn2,
                                isSolid     : true,
                                showChevron : false,
                                action      : {
                                    dismiss()
                                    onRenewWithChanges()
                                }
                            )
                        }else{
                            GradientBorderButtonNew(
                                title           : btn2,
                                isBtn           : true,
                                buttonImage     : "plusicon",
                                action          : {
                                    dismiss()
                                    onRenewWithChanges()
                                },
                                backgroundColor : themeManager.selectedAccent.senColor
                            )
                        }
                    }
                    
                    if btn3 != "" && isLoginMethods == false {
                        GradientBorderButtonNew(
                            title       : btn3,
                            isBtn       : true,
                            action      : {
                                dismiss()
                                onNo?()
                            },
                            backgroundColor : .dangerLightE43C5C,
                            isCancel        : true
                        )
                        .frame(height: 56)
                    }
                    if btn3 != "" && isLoginMethods == true {
                        GradientBorderBgButton(
                            title       : btn3,
                            isBtn       : true,
                            action      : {
                                dismiss()
                                onNo?()
                            },
                            backgroundColor : themeManager.white_white4,
                        )
                        .frame(height: 56)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            contentHeight = geo.size.height + 20
                        }
                        .onChange(of: geo.size.height) { newHeight in
                            contentHeight = newHeight + 20
                        }
                }
            )
            
            //            Spacer()
        }
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .frame(height: min(contentHeight + 50 , UIScreen.main.bounds.height - 60))
        .background(.bottomBGFFFFFF120A1F)
    }
}

#Preview {
    RenewSubscriptionBottomSheet(
        onRenew: {},
        onRenewWithChanges: {}
    )
}
