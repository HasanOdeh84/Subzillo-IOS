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
    @State private var reconnectSheetHeight : CGFloat = .zero
    
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
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(Color("Surface_FFFFFF_0A0612"))
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                Color.black.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Connect Email")
                        .font(.geistBold(22))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                    
                    Text("Auto-detect from email")
                        .font(.geistRegular(13))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                        )
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
           /* ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    
                    
                    
                    // MARK: - Header
                    
                    Text("Connected mails")
                        .font(.geistBold(17))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                        .padding(.bottom, 12)
                    
                    
                    // MARK: - Search
                    
                    if connectedEmailsVM.connectedEmails.count != 0 {
                        
                        HStack(spacing: 10) {
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(
                                    Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                )
                            
                            TextField(
                                LocalizedStringKey("Search"),
                                text: $connectedEmailsVM.searchText
                            )
                            .font(.geistRegular(15))
                            .foregroundColor(
                                Color("TextPrimary_ 0E101A_F4F1FB")
                            )
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(Color.whiteBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1.5)
                        )
                        .padding(.bottom, 14)
                    }
                    
                    
                    // MARK: - Connected Emails
                    
                    if connectedEmailsVM.filteredEmails.count != 0 {
                        
                        LazyVStack(spacing: 10) {
                            
                            ForEach(connectedEmailsVM.filteredEmails) { email in
                                
                                VStack(spacing: 0) {
                                    
                                    // Top Content
                                    
                                    HStack(spacing: 12) {
                                        
                                        Image("google")
                                            .frame(width: 40, height: 40)
                                            .background(Color(hex: "#FCE8E6"))
                                            .clipShape(
                                                RoundedRectangle(cornerRadius: 10)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            
                                            Text(email.email ?? "")
                                                .font(.geistBold(14))
                                                .foregroundColor(
                                                    Color("TextPrimary_ 0E101A_F4F1FB")
                                                )
                                            
                                            Text("24/04/2026")
                                                .font(.custom("JetBrainsMono-Regular", size: 11))
                                                .foregroundColor(
                                                    Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                                )
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.bottom, 12)
                                    
                                    
                                    // Buttons
                                    
                                    HStack(spacing: 10) {
                                        
                                        Button {
                                            connectedEmailsVM.syncEmail(email)
                                        } label: {
                                            
                                            Text("Sync")
                                                .font(.geistSemiBold(13))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 38)
                                                .background(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(hex: "#A719DD"),
                                                            Color(hex: "#7C5CFF"),
                                                            Color(hex: "#4489EB")
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .clipShape(
                                                    RoundedRectangle(cornerRadius: 10)
                                                )
                                                .shadow(
                                                    color: Color(hex: "#7C5CFF").opacity(0.35),
                                                    radius: 10,
                                                    x: 0,
                                                    y: 4
                                                )
                                        }
                                        
                                        Button {
                                            connectedEmailsVM.viewEmail(email)
                                        } label: {
                                            
                                            Text("View")
                                                .font(.geistSemiBold(13))
                                                .foregroundColor(
                                                    Color(hex: "#7C5CFF")
                                                )
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 38)
                                                .background(Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            Color(hex: "#7C5CFF"),
                                                            lineWidth: 1.5
                                                        )
                                                )
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.whiteBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            Color.black.opacity(0.08),
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                        
                    } else {
                        
                        VStack(spacing: 16) {
                            
                            Image("noEmails")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Text("No emails Added Yet")
                                .font(.geistBold(16))
                                .foregroundColor(
                                    Color("TextPrimary_ 0E101A_F4F1FB")
                                )
                            
                            Text("Add a email to manage your subscriptions and payments easily.")
                                .font(.geistRegular(16))
                                .foregroundColor(
                                    Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                )
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }*/
            ScrollView(showsIndicators: false) {
                // MARK: - Email Providers
                
                VStack(spacing: 0) {
                    
                    UploadItemNew(
                        title: "Connect Gmail",
                        subTitle: "Link your Gmail account to sync and manage subscriptions automatically.",
                        image: "google_new",
                        backgroundColor: Color(hex: "#FCE8E6"),
                        action: gmailAction
                    )
                    
                    Divider()
                        .overlay(Color.black.opacity(0.08))
                    
                    UploadItemNew(
                        title: "Connect Outlook",
                        subTitle: "Connect your Outlook account to access and organize your subscriptions.",
                        image: "microsoft_new",
                        backgroundColor: Color(hex: "#E3F2FD"),
                        action: outlookAction
                    )
                    
                    Divider()
                        .overlay(Color.black.opacity(0.08))
                    
                    UploadItemNew(
                        title: "Connect iCloud",
                        subTitle: "Integrate your iCloud account to organize and track your subscriptions.",
                        image: "iCloud_new",
                        backgroundColor: Color(hex: "#E3F2FD"),
                        action: iCloudAction
                    )
                }
                .background(Color.whiteBlack)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                
                // MARK: - Connected mails Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Connected mails")
                        .font(.geistBold(17))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                    
                    
                    if connectedEmailsVM.connectedEmails.count != 0 {
                        // MARK: - Search Bar
                        HStack(spacing: 10) {
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(
                                    Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                )
                            
                            TextField(
                                LocalizedStringKey("Search"),
                                text: $connectedEmailsVM.searchText
                            )
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.geistRegular(15))
                            .foregroundColor(
                                Color("TextPrimary_ 0E101A_F4F1FB")
                            )
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(Color.whiteBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1.5)
                        )
                        .padding(.bottom, 14)
                    }
                    
                    if connectedEmailsVM.filteredEmails.count != 0 {
                        // MARK: Email List
                        LazyVStack(spacing: 16) {
                            ForEach(connectedEmailsVM.filteredEmails) { email in
                                let progress = connectedEmailsVM.activeSyncs[email.id ?? ""]
                                SwipeableMailRow(email              : email,
                                                 activeCardId       : $activeEmailId,
                                                 isScrollDisabled   : $isScrollDisabled,
                                                 isInlineSyncing    : progress != nil,
                                                 emailsScanned      : progress?.emailsScanned ?? 0,
                                                 subscriptionsFound : progress?.subscriptionsFound ?? 0,
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
                                }, onReconnect: {
                                    gmailAction()
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
                                    .font(.geistBold(16))
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB")
                                    )
                                
                                Text("Add a email to manage your subscriptions and payments easily.")
                                    .font(.geistRegular(16))
                                    .foregroundColor(
                                        Color("TextPrimary_ 0E101A_F4F1FB").opacity(0.6)
                                    )
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
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(20)
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
        .sheet(isPresented: $connectEmailVM.showReconnectSheet, onDismiss: {
            connectEmailVM.showReconnectSheet = false
        }) {
            InfoAlertSheet(
                onDelegate: {
                    gmailAction()
                }, title: "Gmail needs reconnection",
                subTitle: "Please reconnect your Gmail account to resume syncing.",
                imageName: "info",
                buttonTitle: "Reconnect",
                isCancelButtonVisible: true
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    reconnectSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(reconnectSheetHeight)])
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
        AppIntentRouter.shared.pop()
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
