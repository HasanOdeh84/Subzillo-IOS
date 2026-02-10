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
    @StateObject var connectEmailVM     = ConnectEmailViewModel()
    
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
                    UploadItem(title: "Connect Gmail", subTitle: "Link your Gmail account to sync and manage all email subscriptions.", image: "google", imageColor: Color.systemInfo, action: gmailAction, isEmail: true)
                    Divider()
                        .overlay(Color.neutral300Border)
                    UploadItem(title: "Connect Outlook", subTitle: "Connect your Outlook account to access and manage your subscriptions.", image: "microsoft", imageColor: Color.systemInfo, action: outlookAction, isEmail: true)
//                    Divider()
//                        .overlay(Color.neutral300Border)
//                    UploadItem(title: "Connect Yahoo", subTitle: "Integrate your Yahoo Mail account to organize and manage subscriptions.", image: "yahoo", imageColor: Color.systemInfo, action: yahooAction, isEmail: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 160)//240)
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
                .frame(alignment: .leading)
                .frame(height: 56)
                .contentShape(Rectangle())
                .onTapGesture {
                    AppIntentRouter.shared.navigate(to: NavigationRoute.connectedEmailsList())
                }
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
        //MARK: Onchange
        //        .onChange(of: connectEmailVM.isSuccess) { success in
        //            if success, let oauthUrlString = connectEmailVM.oauthUrlResponse?.authUrl, let url = URL(string: oauthUrlString) {
        //                let callbackScheme = "com.googleusercontent.apps.955282043815-5tm4dfjcs5uv5qkvne9uv6jkf64div4a"
        //                OAuthManager.shared.startOAuth(url: url, callbackScheme: callbackScheme) { callbackURL, error in
        //                    if let callbackURL = callbackURL {
        //                        connectEmailVM.handleOAuthCallback(url: callbackURL)
        //                    } else if let error = error {
        //                        print("OAuth error: \(error.localizedDescription)")
        //                    }
        //                    connectEmailVM.isSuccess = false
        //                }
        //            }
        //        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    private func gmailAction(){
        guard let presentingVC = UIApplication.shared.rootViewController else {
            return
        }
        SocialLogins.shared.gmailSignInOAuth(presentingVC: presentingVC) { serverAuthCode in
            guard let code = serverAuthCode else {
                print("❌ serverAuthCode is nil")
                return
            }
            print("✅ serverAuthCode:", code)
            connectEmailVM.gmailOauthCallBack(input: GmailOauthCallBackRequest(userId: Constants.getUserId(), code: code, type: 1))
        }
    }
    
    private func outlookAction() {
        guard let presentingVC = UIApplication.shared.rootViewController else {
            return
        }
        SocialLogins.shared.microsoftSignInOAuth(presentingVC: presentingVC) { authCode in
            guard let code = authCode else {
                print("❌ Microsoft authCode is nil")
                return
            }
            print("✅ Microsoft authCode:", code)
            connectEmailVM.gmailOauthCallBack(input: GmailOauthCallBackRequest(userId: Constants.getUserId(), code: code, type: 2))
//            connectEmailVM.microsoftOauthCallBack(input: GmailOauthCallBackRequest(userId   : Constants.getUserId(),
//                                                                                   code     : code,
//                                                                                   type     : 2))
        }
    }
    
    private func yahooAction() {
    }
}

#Preview {
    ConnectEmailView()
}
