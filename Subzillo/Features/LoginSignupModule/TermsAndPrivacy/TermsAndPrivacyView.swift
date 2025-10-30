//
//  TermsAndPrivacyView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/10/25.
//

import SwiftUI

struct TermsAndPrivacyView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) var dismiss
    var isTerm : Bool = false
    
    var body: some View {
//        ScrollView{
//            
//        }
//        .background(Color.neutralBg100)
//        .ignoresSafeArea()
        VStack{
            HeaderView(
                title: "Terms of service",
                trailingTitle: "Share",
                onBack: { dismiss() },
                onTrailingAction: { print("Share tapped") }
            )
                            
            Text("This is the main content of your screen.")
                .padding()
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TermsAndPrivacyView()
}


import SwiftUI

struct HeaderView: View {
    var title: String
    var trailingTitle: String? = nil
    var onBack: (() -> Void)? = nil
    var onTrailingAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            // MARK: - Back Button
            Button(action: {
                onBack?()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blue)
            }

            Spacer()

            // MARK: - Title
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            // MARK: - Trailing Button (optional)
            if let trailingTitle = trailingTitle {
                Button(action: {
                    onTrailingAction?()
                }) {
                    Text(trailingTitle)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.blue)
                }
            } else {
                // To keep layout balanced when no trailing item
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
}
