//
//  ConnectEmailView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 08/01/26.
//

import SwiftUI

struct ConnectEmailView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading) {
            
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: - Title
                    Text("Connect Email")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    // MARK: - SubTitle
                    Text("Auto-detect from email")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    UploadItem(title: "Connect Gmail", subTitle: "Capture Gmail notification on screen", image: "google", imageColor: Color.systemInfo, action: gmailAction, isEmail: true)
                    Divider()
                        .overlay(Color.neutral300Border)
                    UploadItem(title: "Connect Outlook", subTitle: "Capture Outlook notification on screen", image: "microsoft", imageColor: Color.systemInfo, action: outlookAction, isEmail: true)
                    Divider()
                        .overlay(Color.neutral300Border)
                    UploadItem(title: "Connect Yahoo", subTitle: "Capture Yahoo notification on screen", image: "yahoo", imageColor: Color.systemInfo, action: yahooAction, isEmail: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 240)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neutral300Border, lineWidth: 1)
                )
                .padding(5)
                
                // MARK: - Connected mails
                VStack(spacing: 0) {
                    HStack{
                        Text("Connected mails")
                            .font(.appSemiBold(16))
                            .foregroundColor(.neutralMain700)
                        
                        Spacer()
                        Image("arrow-right-01-round")
                            .renderingMode(.template)
                            .foregroundColor(.secondaryNavyBlue400)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.vertical, 20)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                }
                .onTapGesture {
                    AppIntentRouter.shared.navigate(to: NavigationRoute.connectedEmailsList)
                }
                .frame(alignment: .leading)
                .frame(height: 56)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neutral300Border, lineWidth: 1)
                )
                .padding(.vertical, 24)
                .padding(.horizontal, 5)
                
                // MARK: - How It Works
                GradienCustomeView(title    : "How it work?",
                                   subTitle : "•  We never store full email content\n•  We cannot send emails or access personal messages",
                                   isImage  : false)
                .padding(.bottom, 24)
                .padding(.horizontal, 5)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(15)
        }
        .navigationBarBackButtonHidden()
        .background(Color.neutralBg100)
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    private func gmailAction() {
    }
    
    private func outlookAction() {
    }
    
    private func yahooAction() {
    }
}

#Preview {
    ConnectEmailView()
}
