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
    
    var body: some View {
        Text(getAttriText())
            .font(.appRegular(14))
            .padding(.horizontal, 20)
            .padding(.bottom, bottomPadding)
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

private func getAttriText() -> AttributedString {
    var attriString = AttributedString(
        localized: "By continuing, you agree to our Terms of Service and Privacy Policy"
    )
    attriString.foregroundColor = .gray
    
    if let privacyRange = attriString.range(of: "Privacy Policy") {
        attriString[privacyRange].link = URL(string: "app://privacy")
        attriString[privacyRange].underlineStyle = .single
        attriString[privacyRange].foregroundColor = .underlineGray
    }
    
    if let termsRange = attriString.range(of: "Terms of Service") {
        attriString[termsRange].link = URL(string: "app://terms")
        attriString[termsRange].underlineStyle = .single
        attriString[termsRange].foregroundColor = .underlineGray
    }
    
    return attriString
}
