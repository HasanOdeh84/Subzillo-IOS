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
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 24)
            
            VStack(alignment: .center, spacing: 8) {
                Image("offlineImage")
                    .frame(width: 84, height: 84)
                    .padding(.bottom, 16)
                
                Text(LocalizedStringKey("You're Offline"))
                    .font(.appSemiBold(24))
                    .foregroundColor(Color.neutralMain700)
                
                Text(LocalizedStringKey("Some features are limited without internet"))
                    .font(.appRegular(18))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
            }
            
            Text(LocalizedStringKey("Available Offline:"))
                .font(.appSemiBold(16))
                .foregroundColor(Color.neutralMain700)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey("• View existing subscriptions"))
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            
            Text(LocalizedStringKey("Requires Internet:"))
                .font(.appSemiBold(16))
                .foregroundColor(Color.neutralMain700)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey("• Email scanning"))
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(LocalizedStringKey("• Voice recognition"))
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(LocalizedStringKey("• OCR image processing"))
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(LocalizedStringKey("• Sync across devices"))
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            
            CustomButton(title: "Ok", action: onOkAction)
                .padding(.top, 24)
                .padding(.bottom,20)
        }
        .padding(.horizontal, 20)
    }
    
    //MARK: - Button actions
    private func onOkAction() {
        onDelegate?()
        dismiss()
    }
}

final class SheetManager: ObservableObject {
    static let shared = SheetManager()
    
    @Published var isOfflineSheetVisible = false
    
    private init() {}
}
