//
//  TermsAndPrivacyTV.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 03/11/25.
//

import SwiftUI

struct TermsAndPrivacyText: View {
    var onTapTerms      : (() -> Void)?
    var onTapPrivacy    : (() -> Void)?
    var bottomPadding   : CGFloat = 18
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        Text(getAttriText(themeManager: themeManager))
            .font(.appRegular(14))
            .padding(.horizontal, 20)
//            .padding(.bottom, bottomPadding)
            .multilineTextAlignment(.center)
            .environment(\.openURL, OpenURLAction { url in
                if url.absoluteString.contains("privacy") {
                    onTapPrivacy?()
                } else if url.absoluteString.contains("terms") {
                    onTapTerms?()
                }
                return .handled
            })
    }
}

@MainActor private func getAttriText(themeManager: ThemeManager) -> AttributedString {
    var attriString = AttributedString(
        localized: "By continuing, you agree to our Terms of Service and Privacy Policy"
    )
    attriString.foregroundColor = .gray
    
    if let privacyRange = attriString.range(of: "Privacy Policy") {
        attriString[privacyRange].link = URL(string: "app://privacy")
        attriString[privacyRange].underlineStyle = .single
        attriString[privacyRange].foregroundColor = themeManager.accentTextColor
    }
    
    if let termsRange = attriString.range(of: "Terms of Service") {
        attriString[termsRange].link = URL(string: "app://terms")
        attriString[termsRange].underlineStyle = .single
        attriString[termsRange].foregroundColor = themeManager.accentTextColor
    }
    
    return attriString
}
