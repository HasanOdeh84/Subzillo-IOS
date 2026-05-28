//
//  SettingsView.swift
//  Subzillo
//
//  Created by Antigravity on 27/01/26.
//

import SwiftUI
import UserNotifications
import LocalAuthentication

struct SettingsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var isEmailConnectionEnabled     = true
    @State private var renewalRemindersEnabled      = true
    @State private var priceChangesEnabled          = false
    @State private var biometricEnabled             = true
    @State var appVersion                           = "1.2.3"
    @StateObject var settingsVM                     = SettingsViewModel()
    @EnvironmentObject var commonApiVM              : CommonAPIViewModel
    @State var showDeletePopup                      : Bool = false
    @State private var deleteSheetHeight            : CGFloat = .zero
    @State var showPermissionPopup                  : Bool = false
    @State var showEmailSyncBottomSheet             : Bool = false
    @State var accountDeleteDescription             : String = ""
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var context                  = LAContext()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Settings")
                        .font(.geistBold(16))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                }
                
                Spacer()
                
                // MARK: - Empty Space
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal,20)
            .padding(.top, 56)
            .padding(.bottom, 24)
            
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
              
                    
                    //MARK: Privacy & Data Section
                    SettingsSection(title: "Privacy & Data") {
                        
                        SettingsRow(
                            title: "Auto Email Sync",
                            subtitle: "Automatically syncs data via email", image: "email_purple",
                            trailingContent: AnyView(
                                Image("backGrayright")
                                    .renderingMode(.template)
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.36)
                                    )
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
                        
                        
                        SettingsRow(
                            title: "Export My Data",
                            subtitle: "Download all subscription data", image: "chart",
                            trailingContent: AnyView(
                                Image("backGrayright")
                                    .renderingMode(.template)
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.36)
                                    )
                            ),
                            action: {
                                settingsVM.exportSubscriptionData(input: ExportSubscriptionDataRequest(userId: Constants.getUserId()))
                            }
                        )
                        
                        
                        SettingsRow(
                            title           : "Biometric login",
                            subtitle        : "Face ID required to open app", image: "cardName",
                            trailingContent : AnyView(
                                
                                Button {
                                            
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        biometricEnabled.toggle()
                                    }
                                            
                                } label: {
                                    ZStack(alignment: biometricEnabled ? .trailing : .leading) {
                                        
                                        RoundedRectangle(cornerRadius: 999)
                                            .fill(
                                                biometricEnabled
                                                ? themeManager.accentGradient
                                                : LinearGradient(
                                                    colors: [
                                                        themeManager.black_white.opacity(0.08)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: 44, height: 26)
                                            .shadow(
                                                color: biometricEnabled
                                                ? themeManager.selectedAccent.senColor
                                                    .opacity(0.55)
                                                : .clear,
                                                radius: 10
                                            )
                                        
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 20, height: 20)
                                            .padding(3)
                                            .shadow(
                                                color: themeManager.black_white.opacity(0.3),
                                                radius: 3,
                                                y: 1
                                            )
                                    }
                                }
                                .onChange(of: biometricEnabled) { newValue in
                                    if biometricEnabled == true
                                    {
                                        authenticate()
                                    }
                                    else{
                                        var usersBioData = Constants.getUserDetails(for: "BiometricUsers")

                                        usersBioData.removeAll {
                                            $0["userId"] == Constants.getUserId()
                                        }

                                        Constants.saveDefaults(
                                            value: usersBioData,
                                            key: "BiometricUsers"
                                        )
                                    }
                                }
                            )
                        )
                        
                        /*SettingsRow(
                            title: "Delete Account",
                            subtitle: "Permanently delete all data",
                            action: {
                                Task {
                                        accountDeleteDescription = "Are you sure you want to delete account?"
                                    showDeletePopup = true
                                }
                            }
                        )*/
                    }
                    .padding(.top, 3)
                    
                    //MARK: Notifications Section
                    SettingsSection(title: "Notifications") {
                        SettingsRow(
                            title           : "Push Notifications",
                            subtitle        : "All alerts and reminders", image: "notification-03",
                            trailingContent : AnyView(
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        renewalRemindersEnabled.toggle()
                                    }
                                } label: {
                                    ZStack(alignment: renewalRemindersEnabled ? .trailing : .leading) {
                                        RoundedRectangle(cornerRadius: 999)
                                            .fill(
                                                renewalRemindersEnabled
                                                ? themeManager.accentGradient
                                                : LinearGradient(
                                                    colors: [
                                                        themeManager.black_white.opacity(0.08)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: 44, height: 26)
                                            .shadow(
                                                color: renewalRemindersEnabled
                                                ? themeManager.selectedAccent.senColor
                                                    .opacity(0.55)
                                                : .clear,
                                                radius: 10
                                            )
                                        
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 20, height: 20)
                                            .padding(3)
                                            .shadow(
                                                color: themeManager.black_white.opacity(0.3),
                                                radius: 3,
                                                y: 1
                                            )
                                    }
                                }
                                .onChange(of: renewalRemindersEnabled) { newValue in
                                    if newValue {
                                        checkNotificationPermission { granted in
                                            if granted {
                                                if newValue != (commonApiVM.userInfoResponse?.renewalReminders ?? false) {
                                                    settingsVM.toggleReminders(input: ToggleRemindersRequest(userId: Constants.getUserId(), type: 3, status: newValue))
                                                }
                                            } else {
                                                showPermissionPopup = true
                                                renewalRemindersEnabled = false
                                            }
                                        }
                                    } else {
                                        if newValue != (commonApiVM.userInfoResponse?.renewalReminders ?? false) {
                                            settingsVM.toggleReminders(input: ToggleRemindersRequest(userId: Constants.getUserId(), type: 3, status: newValue))
                                        }
                                    }
                                }
                            )
                        )

                    }
                    
                    //MARK: Privacy & Data Section
                    SettingsSection(title: "Support & legal") {
                        SettingsRow(
                            title: "Privacy Policy",
                            subtitle: "How we protect your data", image: "hugeicons_google-doc",
                            trailingContent: AnyView(
                                Image("backGrayright")
                                    .renderingMode(.template)
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.36)
                                    )
                            ),
                            action: {
                                settingsVM.navigate(to: .termsAndPrivacy(isTerm: false))
                            }
                        )
                        
                        SettingsRow(
                            title: "Terms of Service",
                            subtitle: "Usage terms and conditions", image: "hugeicons_google-doc",
                            trailingContent: AnyView(
                                Image("backGrayright")
                                    .renderingMode(.template)
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.36)
                                    )
                            ),
                            action: {
                                settingsVM.navigate(to: .termsAndPrivacy(isTerm: true))
                            }
                        )
                        
                        SettingsRow(
                            title: "Contact Support",
                            subtitle: "Get help with your account", image: "hugeicons_contact-01",
                            trailingContent: AnyView(
                                Image("backGrayright")
                                    .renderingMode(.template)
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.36)
                                    )
                            ),
                            action: {
                                settingsVM.navigate(to: .contactUs)
                            }
                        )
                        
                        SettingsRow(
                            title: "App Version",
                            subtitle: "Subzillo v\(appVersion)", image: "system-uicons_version",
                            trailingContent: nil
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Danger zone")
                            .font(.jetBrainsMedium(10))
                            .tracking(1.4)
                            .textCase(.uppercase)
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                            .padding(.horizontal, 2)
                            .padding(.bottom, 10)
                        
                        Button {
                            accountDeleteDescription = "Are you sure you want to delete account?"
                            showDeletePopup = true
                        } label: {
                            HStack(spacing: 14) {
                                
                                // Icon
                                ZStack {
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            Color.dangerE43C5CFF5A7A.opacity(0.13)
                                        )
                                    
                                    Image("crossicon")
                                        .frame(width: 13, height: 13)
                                }
                                .frame(width: 32, height: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    // Title
                                    Text("Delete Account")
                                        .font(.geistMedium(14))
                                        .foregroundStyle(
                                            Color.dangerE43C5CFF5A7A
                                        )
                                    
                                    // Subtitle
                                    Text("This cannot be undone")
                                        .font(.geistRegular(12))
                                        .foregroundStyle(
                                            Color.textPrimary0E101AF4F1FB
                                                .opacity(0.6)
                                        )
                                }
                                
                                Spacer()
                                
                                // Arrow
                                Image("backGrayright")
                                    .renderingMode(.template)
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.36)
                                    )
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(themeManager.white_white4)
                            )
                            .overlay {
                                
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.08),
                                        lineWidth: 1
                                    )
                            }
                        }
                                           
                    }
                    .padding(.bottom,30)
                    
                    //MARK: Reset to default button
                    GradientBgButton(
                        title       : "Reset to default",
                        isSolid     : true,
                        showChevron : false
                    ) {
                        settingsVM.toggleReminders(input: ToggleRemindersRequest(userId         : Constants.getUserId(),
                                                                                 type           : 3,
                                                                                 status         : true))
                    }
                    .padding(.bottom,120)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .applyAppBackground()
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            
            let usersBioData = Constants.getUserDetails(for: "BiometricUsers")
            let userExists = usersBioData.contains {
                $0["userId"] == Constants.getUserId()
            }
            biometricEnabled = userExists
            setupBiometrics()
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
                isCancelButtonVisible   : true,
                isImageVisible          : false
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
                //AppIntentRouter.shared.pop()
            }, title: "We need notification access to recieve notifications",
                            type            : "notifications",
                            value           : "Tap Notifications",
                            hideManualBtn   : true)
            .id(UUID())
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(500)])
        }
    }
    //MARK: - Biometric methods
    func setupBiometrics() {
        
        context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: nil
        )
        
    }
    
    func authenticate() {
        
        
        context = LAContext()
        context.localizedCancelTitle = ""//Enter OTP"
        
        var error: NSError?
        
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) else {
            
            print(error?.localizedDescription ?? "Can't evaluate policy")
            return
        }
        
        Task {
            
            do {
                
                try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: "Log in to your account"
                )
                
                await MainActor.run {
                    
                    let usersData = Constants.getUserDetails(for: "loginedUsersData")
                    let filteredUser = usersData.first {
                           $0["userId"] == Constants.getUserId()
                       }
                    
                    if filteredUser != nil
                    {
                        var usersBioData = Constants.getUserDetails(for: "BiometricUsers")
                        let userExists = usersBioData.contains {
                            $0["userId"] == Constants.getUserId()
                        }
                        
                        if userExists == false
                        {
                            usersBioData.append(filteredUser!)
                            Constants.saveDefaults(value:usersBioData, key: "BiometricUsers")
                        }
                    }
                    
                    
                    biometricEnabled = true
                    
                }
                
            } catch {
                
                guard let authError = error as? LAError else {
                    print(error.localizedDescription)
                    return
                }
                
                switch authError.code {
                    
                case .userFallback:
                    
                    // User tapped "Enter OTP"
                    biometricEnabled = false
                    
                case .userCancel:
                    
                    // User tapped "Enter OTP"
                    biometricEnabled = false
                    
                case .biometryLockout:
                    
                    print("Biometry locked")
                    
                default:
                    
                    print(authError.localizedDescription)
                }
            }
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
            Text(title)
                .font(.jetBrainsMedium(10))
                .tracking(1.4)
                .textCase(.uppercase)
                .foregroundStyle(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.6)
                )
                .padding(.horizontal, 2)
                .padding(.bottom, 5)
            
            VStack(spacing: 6) {
                content
            }
        }
    }
}

struct SettingsRow: View {
    var title: String
    var subtitle: String?
    var image: String
    var trailingContent: AnyView?
    var action: (() -> Void)? = nil
    @EnvironmentObject var themeManager: ThemeManager
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
        
        HStack(spacing: 14) {
            
            // Icon
            ZStack {
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        Color.calenderF1F2F7FFFFFF
                    )
                
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundStyle(
                        themeManager.selectedAccent.senColor
                    )
            }
            .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                // Title
                Text(title)
                    .font(.geistMedium(14))
                    .foregroundStyle(
                        Color.textPrimary0E101AF4F1FB
                    )
                
                
                // Subtitle
                if let subtitle = subtitle {
                    
                    Text(subtitle)
                        .font(.geistRegular(12))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.6)
                        )
                }
            }
            Spacer()
            // Arrow
            if let trailing = trailingContent {
                trailing
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(themeManager.white_white4)
        )
        .overlay {
            
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.08),
                    lineWidth: 1
                )
        }
    }
    private var rowContentold: some View {
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
