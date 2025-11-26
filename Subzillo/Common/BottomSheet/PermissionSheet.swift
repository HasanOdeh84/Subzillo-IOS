//
//  PermissionSheet.swift
//  Subzillo
//
//  Created by Ratna Kavya on 13/11/25.
//
import SwiftUI

struct PermissionSheet: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    var title                         : String
    var type                          : String
    var value                         : String
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.vertical, 24)
            
            VStack(alignment: .center, spacing: 8) {
                Image("lockicon")
                    .frame(width: 84, height: 84)
                    .padding(.bottom, 16)
                
                Text(LocalizedStringKey("Permission Required"))
                    .font(.appSemiBold(24))
                    .foregroundColor(Color.neutralMain700)
                
                Text(LocalizedStringKey(title))
                    .font(.appRegular(18))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
            }
            
            Text(LocalizedStringKey("To enable \(type) input:"))
                .font(.appSemiBold(16))
                .foregroundColor(Color.neutralMain700)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(LocalizedStringKey("• Go to Settings → Privacy & Security"))
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(LocalizedStringKey("• \(value)"))
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(LocalizedStringKey("• Enable for Subzillo"))
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            
            CustomButton(title: "Open settings", buttonImage: "settingsicon", action: onSettingsAction)
                .padding(.top, 24)
            
            GradientBorderButton(title: "Add Manually Instead", isBtn: true, buttonImage: "text-creation1", action: onManualAction, backgroundColor: .whiteBlackBG)
                .padding(.vertical, 16)
        }
        .padding(.horizontal, 20)
    }
    
    //MARK: - Button actions
    private func onManualAction() {
        onDelegate?()
        dismiss()
        AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: false))
    }
    
    private func onSettingsAction() {
        dismiss()
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
