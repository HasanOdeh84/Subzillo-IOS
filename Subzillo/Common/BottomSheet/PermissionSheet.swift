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
    var icon                          : String? = "lockicon"
    var hideManualBtn                 : Bool = false
    @EnvironmentObject var themeManager     : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.capsuleBlack12White14)
                .frame(width: 40, height: 4)
                .padding(.vertical, 16)
            
            VStack(alignment: .center, spacing: 8) {
                Image(icon ?? "lockicon")
                    .renderingMode(.template)
                    .foregroundStyle(themeManager.accentGradient)
                    .frame(width: 80, height: 80)
                    .padding(.bottom, 18)
                
                if type != "notifications"
                {
                    Text("Permission Required".capitalized)
                        .font(.geistSemiBold(16))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB)
                }
                else{
                    Text("\(type) Permission Required".capitalized)
                        .font(.geistSemiBold(16))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB)
                }
                
                Text(LocalizedStringKey(title))
                    .font(.geistMedium(12))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedStringKey("To enable \(type) input:"))
                    .font(.geistBold(12))
                    .foregroundColor(themeManager.black_white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("• Go to Settings → Privacy & Security")
                        .font(.geistRegular(12))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(LocalizedStringKey("• \(value)"))
                        .font(.geistRegular(12))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("• Enable for Subzillo")
                        .font(.geistRegular(12))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(themeManager.textPrimaryLight1_white8)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        Color.textPrimary0E101AF4F1FB
                            .opacity(0.08),
                        lineWidth: 1
                    )
            }
            .cornerRadius(18)
            .padding(.vertical, 20)
            
            GradientBgButton(
                title       : "Open settings",
                isSolid     : true,
                showChevron : false,
                icon        : "settingsicon",
                iconOnLeft  : false,
                action      : onSettingsAction
            )
            
            if !hideManualBtn{
                GradientBorderButtonNew(title: "Add Manually Instead", isBtn: true, buttonImage: "plusicon", action: onManualAction, backgroundColor: themeManager.selectedAccent.senColor)
                    .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 20)
        .background(.bottomBGFFFFFF120A1F)
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
