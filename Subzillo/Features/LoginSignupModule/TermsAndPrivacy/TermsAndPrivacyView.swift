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
        ZStack{
            Group{
                Color(.appBackground)
            }
            .ignoresSafeArea()
            VStack{
                HeaderView(
                    title           : isTerm ? "Terms of service" : "Privacy Policy",
                    trailingTitle   : "Share",
                    onBack          : { dismiss() },
                    onTrailingAction: { print("Share tapped") }
                )
                .padding(.bottom,24)
                ScrollView(){
                    VStack(){
                        VStack(){
                            Text("This is the main content of your screen.")
                                .multilineTextAlignment(.leading)
                        }
                        .padding(18)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    Spacer()
                }
            }
            .padding(20)
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
            Button(action: {
                onBack?()
            }) {
                Image("back_gray")
                    .frame(width: 24,height: 24)
            }

            Text(title)
                .font(.appRegular(24))
                .foregroundColor(.appNeutralMain700)

            Spacer()

            if let trailingTitle = trailingTitle {
                Button(action: {
                    onTrailingAction?()
                }) {
                    Text(trailingTitle)
                        .font(.appRegular(14))
                        .foregroundColor(.blueMain700)
                }
            } else {
                // To keep layout balanced when no trailing item
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 32)
    }
}
