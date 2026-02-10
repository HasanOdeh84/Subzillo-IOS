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
    var isTerm                  : Bool = false
    @StateObject var settingsVM = SettingsViewModel()
    @State private var webViewHeight: CGFloat = .zero
    
    var body: some View {
        ZStack{
            Group{
                Color(.neutralBg100)
            }
            .ignoresSafeArea()
            VStack{
                ProfileHeaderView(
                    title           : isTerm ? "Terms of service" : "Privacy Policy",
                    onBack          : { dismiss() }
                )
                .padding(.bottom,24)
                ScrollView(){
                    VStack(){
                        VStack(){
                            if let content = settingsVM.privacyData?.content {
                                HTMLWebView(htmlContent: content, dynamicHeight: $webViewHeight)
                                    .frame(height: webViewHeight)
                            } else {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 400)
                            }
                        }
                        .padding(18)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                    .padding(5)
                    Spacer()
                }
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            settingsVM.getPrivacyData(type: isTerm ? 2 : 1)
        }
    }
}

#Preview {
    TermsAndPrivacyView()
}
