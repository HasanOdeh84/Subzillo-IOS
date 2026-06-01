//
//  OfflineSheet.swift
//  Subzillo
//
//  Created by Ratna Kavya on 18/11/25.
//


import SwiftUI

struct OfflineSheet: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager     : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.capsuleBlack12White14)
                .frame(width: 40, height: 5)
                .padding(.vertical, 24)
            
            VStack(alignment: .center, spacing: 8) {
                Image("offlineImage")
                    .frame(width: 84, height: 84)
                    .padding(.bottom, 16)
                
                Text("You're Offline")
                    .font(.geistSemiBold(16))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                
                Text("Some features are limited without internet")
                    .font(.geistMedium(14))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                    .multilineTextAlignment(.center)
            }
            
            VStack{
                Text("Available Offline:")
                    .font(.geistBold(16))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 6)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• View existing subscriptions")
                        .font(.geistRegular(16))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 30)
            }
            .padding(16)
            .background(themeManager.white_white4)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.textPrimary0E101AF4F1FB.opacity(0.16), lineWidth: 1)
            )
            .padding(.top, 20)
            .padding(.bottom, 12)
            
            VStack{
                Text("Requires Internet:")
                    .font(.geistBold(16))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 6)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("• Email scanning")
                        .font(.geistRegular(16))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("• Voice recognition")
                        .font(.geistRegular(16))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("• OCR image processing")
                        .font(.geistRegular(16))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("• Sync across devices")
                        .font(.geistRegular(16))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 30)
            }
            .padding(16)
            .background(themeManager.white_white4)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.textPrimary0E101AF4F1FB.opacity(0.16), lineWidth: 1)
            )
            .padding(.bottom, 16)
            
            GradientBgButton(
                title       : "Ok",
                isSolid     : true,
                showChevron : false,
                action      : {
                    onOkAction()
                }
            )
            
//            CustomButton(title: "Ok",shadow: themeManager.accentShadowColor, action: onOkAction)
//                .padding(.top, 24)
//                .padding(.bottom,20)
        }
        .padding(.horizontal, 20)
        .background(.bottomBGFFFFFF120A1F)
    }
    
    //MARK: - Button actions
    private func onOkAction() {
        onDelegate?()
        dismiss()
    }
}

