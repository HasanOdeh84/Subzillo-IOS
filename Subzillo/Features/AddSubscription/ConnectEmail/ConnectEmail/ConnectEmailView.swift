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
    @StateObject private var connectedEmailsVM = ConnectedEmailsViewModel()
    
    @State private var activeEmailId        : String? = nil
    @State private var isScrollDisabled     : Bool = false
    @State var showDeletePopup              : Bool = false
    @State var selectedEmail                : ListConnectedEmailsData?
    @State private var isVisible            : Bool = false
    @State private var justAppeared         : Bool = false
    @State private var deleteSheetHeight    : CGFloat = .zero
    @State private var upgradeNowSheetHeight: CGFloat = .zero
    @State private var showPlatformAlert    : Bool = false
    @State private var mailFromPush         : String?
    @State private var integrationIdFromPush: String?
    
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
                    Divider()
                        .overlay(Color.neutral300Border)
                    //                    UploadItem(title: "Connect Yahoo", subTitle: "Integrate your Yahoo Mail account to organize and manage subscriptions.", image: "yahoo", imageColor: Color.systemInfo, action: yahooAction, isEmail: true)
                    UploadItem(title: "Connect iCloud", subTitle: "Integrate your iCloud account to organize and manage subscriptions.", image: "iCloud", imageColor: Color.systemInfo, action: iCloudAction, isEmail: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 240) //160)//
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neutral300Border, lineWidth: 1)
                )
                .padding(5)
                
                // MARK: - Connected mails Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Connected mails")
                        .font(.appSemiBold(16))
                        .foregroundColor(.neutralMain700)
                    //.padding(.top, 10)
                    
                    if connectedEmailsVM.connectedEmails.count != 0 {
                        // MARK: - Search Bar
                        HStack {
                            Image("search")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                                .padding(.leading, 16)
                            
                            TextField(LocalizedStringKey("Search"), text: $connectedEmailsVM.searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.trailing, 10)
                                .foregroundColor(Color.neutralMain700)
                        }
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue500, lineWidth: 1)
                        )
                        //.padding(.horizontal, 5)
                    }
                    
                    if connectedEmailsVM.filteredEmails.count != 0 {
                        // MARK: Email List
                        LazyVStack(spacing: 16) {
                            ForEach(connectedEmailsVM.filteredEmails) { email in
                                SwipeableMailRow(email              : email,
                                                 activeCardId       : $activeEmailId,
                                                 isScrollDisabled   : $isScrollDisabled,
                                                 isInlineSyncing    : connectedEmailsVM.isInlineSyncing && connectedEmailsVM.inlineSyncingId == email.id,
                                                 emailsScanned      : connectedEmailsVM.inlineEmailsScanned,
                                                 subscriptionsFound : connectedEmailsVM.inlineSubscriptionsFound,
                                                 onDelete           : {
                                    selectedEmail = email
                                    showDeletePopup = true
                                },              onSync    : {
                                    connectedEmailsVM.syncEmail(email)
                                },              onSyncing : {
                                    connectedEmailsVM.syncingEmail(email)
                                },              onView    : {
                                    connectedEmailsVM.viewEmail(email)
                                }, onDownloadLogs: {
                                    connectedEmailsVM.downloadLogs(email)
                                }, isIntegrations: false)
                            }
                        }
                        .padding(.top, 5)
                    } else {
                        if connectedEmailsVM.searchText == "" {
                            VStack(spacing: 16) {
                                Image("noEmails")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                
                                Text("No emails Added Yet")
                                    .font(.appBold(16))
                                    .foregroundColor(Color.neutral800)
                                
                                Text("Add a email to manage your subscriptions and payments easily.")
                                    .font(.appRegular(16))
                                    .foregroundColor(Color.grayText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 5)
                
                // MARK: - How It Works
                //                GradienCustomeView(title    : "How it work?",
                //                                   subTitle : "•  We never store full email content\n•  We cannot send emails or access personal messages",
                //                                   isImage  : false)
                //                .padding(.bottom, 24)
                //                .padding(.horizontal, 5)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(15)
        }
        .navigationBarBackButtonHidden()
        .background(Color.neutralBg100)
        //MARK: OnAppear
        .onAppear {
            Constants.saveDefaults(value: true, key: "isSyncing")
            isVisible = true
            justAppeared = true
            listConnectedMailsApi()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                justAppeared = false
            }
        }
        .onDisappear {
            isVisible = false
            connectedEmailsVM.stopInlinePolling()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshScreenData"))) { _ in
            if isVisible && !justAppeared {
                listConnectedMailsApi()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshConnectedEmails"))) { notification in
            if isVisible && AppIntentRouter.shared.currentRoute?.isConnectEmail == true {
                listConnectedMailsApi()
                if let email = notification.userInfo?["email"] as? String {
                    mailFromPush = email
                }
                if let id = notification.userInfo?["integrationId"] as? String {
                    integrationIdFromPush = id
                }
                showPlatformAlert = true
            }
        }
        //MARK: Sheets
        .sheet(isPresented: $connectedEmailsVM.showErrorPopup, onDismiss: {
            listConnectedMailsApi()
        }) {
            UploadErrorImageSheet(
                isImage     : false,
                onDelegate  : {
                },
                onDismiss   : {
                }
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(500)])
        }
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    deleteEmailAction()
                }, title    : "Are you sure you want to delete the mail \(selectedEmail?.email ?? "")",
                subTitle    : "",
                imageName   : "del_red_big",
                buttonIcon  : "deleteIcon",
                buttonTitle : "Delete",
                imageSize   : 70
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
        .sheet(isPresented: $showPlatformAlert) {
            SubscriptionAlertSheet(
                onDelegate: {
                    connectedEmailsVM.emailSubscriptionsList(input: EmailSubscriptionsListRequest(userId: Constants.getUserId(),
                                                                                                  integrationId: integrationIdFromPush ?? ""))
                }, title                : "Mail Sync Completed",
                subTitle                : "Your mails for this \(mailFromPush ?? "") have been successfully synced. You’re all up to date.",
                buttonTitle             : "Ok",
                isBtn                   : false
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    upgradeNowSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(upgradeNowSheetHeight)])
        }
        //MARK: Onchange
        .onChange(of: connectEmailVM.isSuccess) { success in
            if success, let oauthUrlString = connectEmailVM.oauthUrlResponse?.authUrl, let url = URL(string: oauthUrlString) {
                let callbackScheme = "subzillo"//"com.googleusercontent.apps.955282043815-5tm4dfjcs5uv5qkvne9uv6jkf64div4a"
                OAuthManager.shared.startOAuth(url: url, callbackScheme: callbackScheme) { callbackURL, error in
                    if let callbackURL = callbackURL {
                        connectEmailVM.handleOAuthCallback(url: callbackURL)
                        listConnectedMailsApi()
                    } else if let error = error {
                        print("OAuth error: \(error.localizedDescription)")
                    }
                    connectEmailVM.isSuccess = false
                }
            }
        }
        .onChange(of: connectEmailVM.isIcloudSuccess) { success in
            if success, let oauthUrlString = connectEmailVM.oauthUrlResponse?.authUrl, let url = URL(string: oauthUrlString) {
                let callbackScheme = "subzillo"
                OAuthManager.shared.startOAuth(url: url, callbackScheme: callbackScheme) { callbackURL, error in
                    if let callbackURL = callbackURL {
                        connectEmailVM.handleOAuthCallback(url: callbackURL, type: 3)
                        listConnectedMailsApi()
                    } else if let error = error {
                        print("OAuth error: \(error.localizedDescription)")
                    }
                    connectEmailVM.isIcloudSuccess = false
                }
            }
        }
        .onChange(of: connectEmailVM.isGmailSuccess) { success in
            if success {
                listConnectedMailsApi()
                connectEmailVM.isGmailSuccess = false
            }
        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    //MARK: - User defined methods
    private func listConnectedMailsApi() {
        connectedEmailsVM.listConnectedEmails(input: ListConnectedEmailsRequest(userId: Constants.getUserId()))
    }
    
    private func deleteEmailAction() {
        withAnimation {
            if let email = selectedEmail {
                connectedEmailsVM.deleteEmail(email)
            }
        }
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
        Constants.FeatureConfig.performS4Action {
            //            Using api auth url
            connectEmailVM.oauthUrl(input: OauthUrlRequest(userId   : Constants.getUserId(),
                                                           type     : 2))
            
            //USing SDK
            //        guard let presentingVC = UIApplication.shared.rootViewController else {
            //            return
            //        }
            //        SocialLogins.shared.microsoftSignInOAuth(presentingVC: presentingVC) { authCode in
            //            guard let code = authCode else {
            //                print("❌ Microsoft authCode is nil")
            //                return
            //            }
            //            print("✅ Microsoft authCode:", code)
            ////            connectEmailVM.gmailOauthCallBack(input: GmailOauthCallBackRequest(userId: Constants.getUserId(), code: code, type: 2))
            ////            connectEmailVM.microsoftOauthCallBack(input: GmailOauthCallBackRequest(userId   : Constants.getUserId(),
            ////                                                                                   code     : code,
            ////                                                                                   type     : 2))
            //        }
        }
    }
    
    private func iCloudAction() {
        Constants.FeatureConfig.performS4Action {
            connectEmailVM.navigate(to: .connectICloudView)
        }
    }
}

#Preview {
    ConnectEmailView()
}
