//
//  SettingsView.swift
//  Subzillo
//
//  Created by Antigravity on 27/01/26.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var isEmailConnectionEnabled     = true
    @State private var renewalRemindersEnabled      = true
    @State private var priceChangesEnabled          = false
    @State var appVersion                           = "1.2.3"
    @StateObject var settingsVM                     = SettingsViewModel()
    @EnvironmentObject var commonApiVM              : CommonAPIViewModel
    @State var showDeletePopup                      : Bool = false
    @State private var deleteSheetHeight            : CGFloat = .zero
    @State var showPermissionPopup                  : Bool = false
    @State var showEmailSyncBottomSheet             : Bool = false
    @State var accountDeleteDescription             : String = ""
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            //MARK: Header
            SettingsHeader(title: "Settings", onBack: {
                dismiss()
            }, onNotification: {
                settingsVM.navigate(to: .notifications)
            })
            .padding(.top, 60)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Data Connections Section
                    //                    SettingsSection(title: "Data Connections") {
                    //                        SettingsRow(
                    //                            title: "Email Connection",
                    //                            subtitle: "Auto-detect subscriptions from receipts",
                    //                            trailingContent: AnyView(
                    //                                Button(action: {
                    //                                    // Connect action
                    //                                }) {
                    //                                    Text("Connect")
                    //                                        .font(.appSemiBold(14))
                    //                                        .foregroundColor(.blueMain700)
                    //                                        .padding(.horizontal, 16)
                    //                                        .padding(.vertical, 8)
                    //                                        .overlay(
                    //                                            RoundedRectangle(cornerRadius: 8)
                    //                                                .stroke(Color.blueMain700, lineWidth: 1)
                    //                                        )
                    //                                }
                    //                            )
                    //                        )
                    //                    }
                    
                    //MARK: Privacy & Data Section
                    SettingsSection(title: "Privacy & Data") {
                        
                        SettingsRow(
                            title: "Privacy & Data"
                        )
                        
                        Divider().overlay(Color.neutral300Border)
                        
//                        SettingsRow(
//                            title: "Email Connection",
//                            subtitle: "Process data on device when possible",
//                            trailingContent: AnyView(
//                                Toggle("", isOn: $isEmailConnectionEnabled)
//                                    .toggleStyle(SwitchToggleStyle(tint: .blueMain700))
//                                    .labelsHidden()
//                                    .onChange(of: isEmailConnectionEnabled) { newValue in
//                                        //                                        if newValue != (commonApiVM.userInfoResponse?.isEmailConnection ?? false) {
//                                        //                                            settingsVM.toggleReminders(input: ToggleRemindersRequest(userId               : Constants.getUserId(),
//                                        //                                                                                                   type                 : 3,
//                                        //                                                                                                   status               : newValue))
//                                        //                                        }
//                                    }
//                            )
//                        )
                        
                        SettingsRow(
                            title: "Auto Email Sync",
                            subtitle: "Automatically syncs data via email",
                            trailingContent: AnyView(
                                Image("arrow-right-01-round")
                                    .renderingMode(.template)
                                    .foregroundColor(.secondaryNavyBlue400)
                                    .frame(width: 24, height: 24)
                            ),
                            action: {
                                Constants.FeatureConfig.performS5Action {
                                    showEmailSyncBottomSheet = true
                                }
                            }
                        )
                        .sheet(isPresented: $showEmailSyncBottomSheet) {
                            AutoEmailSyncBottomSheet(onSelect: { id in
                                settingsVM.updateSyncPeriod(input: UpdateSyncPeriodRequest(userId       : Constants.getUserId(),
                                                                                           syncPeriodId : id))
                            })
                                .presentationDragIndicator(.hidden)
                                .presentationDetents([.height(420)])
                        }
                        
                        Divider().overlay(Color.neutral300Border)
                        
                        SettingsRow(
                            title: "Export My Data",
                            subtitle: "Download all subscription data",
                            //                            trailingContent: AnyView(
                            //                                Image("arrow-right-01-round")
                            //                                    .renderingMode(.template)
                            //                                    .foregroundColor(.secondaryNavyBlue400)
                            //                                    .frame(width: 24, height: 24)
                            //                            ),
                            action: {
                                settingsVM.exportSubscriptionData(input: ExportSubscriptionDataRequest(userId: Constants.getUserId()))
                            }
                        )
                        
                        Divider().overlay(Color.neutral300Border)
                        
                        SettingsRow(
                            title: "Delete Account",
                            subtitle: "Permanently delete all data",
                            action: {
                                Task {
                                        accountDeleteDescription = "Are you sure you want to delete account?"
                                    showDeletePopup = true
                                }
                            }
                        )
                    }
                    .padding(.top, 3)
                    
                    //MARK: Notifications Section
                    SettingsSection(title: "Notifications") {
                        
                        SettingsRow(
                            title: "Notifications"
                        )
                        
                        Divider().overlay(Color.neutral300Border)
                        
                        SettingsRow(
                            title           : "Renewal Reminders",
                            subtitle        : "3 days before subscription renews",
                            trailingContent : AnyView(
                                Toggle("", isOn: $renewalRemindersEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .blueMain700))
                                    .labelsHidden()
                                    .onChange(of: renewalRemindersEnabled) { newValue in
                                        if newValue {
                                            checkNotificationPermission { granted in
                                                if granted {
                                                    if newValue != (commonApiVM.userInfoResponse?.renewalReminders ?? false) {
                                                        settingsVM.toggleReminders(input: ToggleRemindersRequest(userId: Constants.getUserId(), type: 1, status: newValue))
                                                    }
                                                } else {
                                                    showPermissionPopup = true
                                                    renewalRemindersEnabled = false
                                                }
                                            }
                                        } else {
                                            if newValue != (commonApiVM.userInfoResponse?.renewalReminders ?? false) {
                                                settingsVM.toggleReminders(input: ToggleRemindersRequest(userId: Constants.getUserId(), type: 1, status: newValue))
                                            }
                                        }
                                    }
                            )
                        )
                        
//                        Divider().overlay(Color.neutral300Border)
//                        
//                        SettingsRow(
//                            title           : "Price Changes",
//                            subtitle        : "Notify when subscription costs change",
//                            trailingContent : AnyView(
//                                Toggle("", isOn: $priceChangesEnabled)
//                                    .toggleStyle(SwitchToggleStyle(tint: .blueMain700))
//                                    .labelsHidden()
//                                    .onChange(of: priceChangesEnabled) { newValue in
//                                        if newValue {
//                                            checkNotificationPermission { granted in
//                                                if granted {
//                                                    if newValue != (commonApiVM.userInfoResponse?.priceChangeReminders ?? false) {
//                                                        settingsVM.toggleReminders(input: ToggleRemindersRequest(userId: Constants.getUserId(), type: 2, status: newValue))
//                                                    }
//                                                } else {
//                                                    showPermissionPopup = true
//                                                    priceChangesEnabled = false
//                                                }
//                                            }
//                                        } else {
//                                            if newValue != (commonApiVM.userInfoResponse?.priceChangeReminders ?? false) {
//                                                settingsVM.toggleReminders(input: ToggleRemindersRequest(userId: Constants.getUserId(), type: 2, status: newValue))
//                                            }
//                                        }
//                                    }
//                            )
//                        )
                    }
                    
                    //MARK: Support & Legal Section
//                    SettingsSection(title: "Privacy & Data") { //antigravity changed to suport & legal
                    SettingsSection(title: "Support & Legal") {
                        
                        SettingsRow(
//                            title: "Privacy & Data" //antigravity changed to suport & legal
                            title: "Support & Legal"
                        )
                        
                        Divider().overlay(Color.neutral300Border)
                        
                        SettingsRow(
                            title: "Privacy Policy",
                            subtitle: "How we protect your data",
                            trailingContent: AnyView(
                                Image("arrow-right-01-round")
                                    .renderingMode(.template)
                                    .foregroundColor(.secondaryNavyBlue400)
                                    .frame(width: 24, height: 24)
                            ),
                            action: {
                                settingsVM.navigate(to: .termsAndPrivacy(isTerm: false))
                            }
                        )
                        
                        Divider().overlay(Color.neutral300Border)
                        
                        SettingsRow(
                            title: "Terms of Service",
                            subtitle: "Usage terms and conditions",
                            trailingContent: AnyView(
                                Image("arrow-right-01-round")
                                    .renderingMode(.template)
                                    .foregroundColor(.secondaryNavyBlue400)
                                    .frame(width: 24, height: 24)
                            ),
                            action: {
                                settingsVM.navigate(to: .termsAndPrivacy(isTerm: true))
                            }
                        )
                        
                        Divider().overlay(Color.neutral300Border)
                        
                        SettingsRow(
                            title: "Contact Support",
                            subtitle: "Get help with your account",
                            trailingContent: AnyView(
                                Image("arrow-right-01-round")
                                    .renderingMode(.template)
                                    .foregroundColor(.secondaryNavyBlue400)
                                    .frame(width: 24, height: 24)
                            ),
                            action: {
                                settingsVM.navigate(to: .contactUs)
                            }
                        )
                        
                        Divider().overlay(Color.neutral300Border)
                        
                        SettingsRow(
                            title: "App Version",
                            subtitle: "Subzillo v\(appVersion)",
                            trailingContent: nil
                        )
                    }
                    
                    //MARK: Reset to default button
                    GradientBorderButton(title: "Reset to default") {
                        settingsVM.toggleReminders(input: ToggleRemindersRequest(userId         : Constants.getUserId(),
                                                                                 type           : 3,
                                                                                 status         : true))
                    }
                    .background(Color.clear)
                    .padding(.bottom,48)
                    
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color.neutralBg100)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                appVersion = version
            }
            getUserDetailsApi()
        }
        .onChange(of: commonApiVM.userInfoResponse) { _ in
            renewalRemindersEnabled     = commonApiVM.userInfoResponse?.renewalReminders ?? false
            priceChangesEnabled         = commonApiVM.userInfoResponse?.priceChangeReminders ?? false
//            isEmailConnectionEnabled    = commonApiVM.userInfoResponse?.isEmailConnection ?? false
        }
        .onChange(of: settingsVM.isUpdateSuccess) { _ in
            if settingsVM.isUpdateSuccess{
                renewalRemindersEnabled     = true
                priceChangesEnabled         = true
            }
        }
        .onChange(of: settingsVM.isUpdateError1) { errorOccurred in
            if errorOccurred {
                renewalRemindersEnabled = commonApiVM.userInfoResponse?.renewalReminders ?? false
            }
        }
        .onChange(of: settingsVM.isUpdateError2) { errorOccurred in
            if errorOccurred {
                priceChangesEnabled = commonApiVM.userInfoResponse?.priceChangeReminders ?? false
            }
        }
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    settingsVM.deleteAccount(input: DeleteAccountRequest(userId: Constants.getUserId()))
                }, title                : "Delete Account",
                subTitle                : accountDeleteDescription,
                imageName               : "del_red_big",
                buttonIcon              : "deleteIcon",
                buttonTitle             : "Delete",
                imageSize               : 70,
                isCancelButtonVisible   : true
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
        .sheet(isPresented: $showPermissionPopup) {
            PermissionSheet(onDelegate: {
                //dismiss()
            }, title: "We need notification access to recieve notifications",
                            type            : "notifications",
                            value           : "Tap Notifications",
                            hideManualBtn   : true)
            .id(UUID())
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(500)])
        }
    }
    
    //MARK: - Userdefined methods
    func getUserDetailsApi(){
        commonApiVM.getUserInfo(input: getUserInfoRequest(userId: Constants.getUserId()))
    }
    
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct SettingsHeader: View {
    var title                           : String
    var onBack                          : () -> Void
    var onNotification                  : () -> Void
    @EnvironmentObject var commonApiVM  : CommonAPIViewModel
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image("back_gray")
                    .frame(width: 24, height: 24)
            }
            
            Text(title)
                .font(.appRegular(24))
                .foregroundColor(.neutralMain700)
            
            Spacer()
            
            //            ZStack(alignment: .topTrailing) {
            //                Button(action: {
            //                    onNotification()
            //                }) {
            //                    Image("notification-03")
            //                        .frame(width: 32, height: 32)
            //                }
            //
            //                if let count = commonApiVM.unreadCountResponse?.unreadCount{
            //                    Text("\(count)")
            //                        .font(.appBold(11))
            //                        .foregroundColor(Color.white)
            //                        .frame(width: 16, height: 16)
            //                        .background(Color.redBadge)
            //                        .cornerRadius(4)
            //                        .offset(x: 0, y: -5)
            //                }
            //            }
        }
        .frame(height: 32)
    }
}

struct SettingsSection<Content: View>: View {
    var title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            //            Text(title)
            //                .font(.appRegular(16))
            //                .foregroundColor(.neutral500)
            //                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.neutral300Border, lineWidth: 1)
            )
        }
    }
}

struct SettingsRow: View {
    var title: String
    var subtitle: String?
    var trailingContent: AnyView?
    var action: (() -> Void)? = nil
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                rowContent
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            rowContent
        }
    }
    
    private var rowContent: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appRegular(16))
                    .foregroundColor(.neutralMain700)
                
                if subtitle ?? "" != ""{
                    Text(subtitle ?? "")
                        .font(.appRegular(14))
                        .foregroundColor(.neutral500)
                }
            }
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            if let trailing = trailingContent {
                trailing
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: subtitle ?? "" != "" ? 70 : 52)
        .background(Color.white)
    }
}

#Preview {
    SettingsView()
}
