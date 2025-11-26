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
                Color(.neutralBg100)
            }
            .ignoresSafeArea()
            VStack{
                ProfileHeaderView(
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
