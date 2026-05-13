//
//  SubzilloApp.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI
import UserNotifications
import UIKit
import Firebase
import MSAL
import Combine

class AppDelegate: NSObject, ObservableObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @Published var deviceToken          : String? = nil
    @Published var permissionGranted    : Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    // Called when app launches
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        //        sleep(1)
        UNUserNotificationCenter.current().delegate = self
        
        //Configure ULink synchronously to handle early access/listeners
        let ulinkConfig = ULinkConfig(
            apiKey: "ulk_e7ceb2717958baacfd613045f27abc945273b947cec90cbd",
            debug: false,
            enableDeepLinkIntegration: true
        )
        ULink.configure(config: ulinkConfig)
        
        //        Set up stream listeners
        setupLinkListeners()
        
        return true
    }
    
    // Ask for notification permission
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.permissionGranted = granted
            }
            
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("User denied notifications")
            }
        }
    }
    
    // MARK: APNs callbacks
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        // Ensure UI updates (if observed) happen on main thread
        DispatchQueue.main.async {
            self.deviceToken = token
            NotificationCenter.default.post(name: NSNotification.Name("DeviceTokenUpdated"), object: nil)
        }
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error.localizedDescription)")
    }
    
    // MARK: Foreground notification handling
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Push payload: \(userInfo)")
        
        // Handle foreground refresh for Connected Emails
        let typeValue = userInfo["type"]
        
        var emailValue: String?
        var integrationIdValue: String?
        
        if let data = userInfo["data"] as? [String: Any] {
            emailValue = data["email"] as? String
            integrationIdValue = data["integrationId"] as? String
        }
        
        let type = (typeValue as? Int) ?? Int(typeValue as? String ?? "")
        if type == 1 {
            //            NotificationCenter.default.post(name: NSNotification.Name("RefreshConnectedEmails"), object: nil)
            NotificationCenter.default.post(
                name    : NSNotification.Name("RefreshConnectedEmails"),
                object  : nil,
                userInfo: ["email": emailValue ?? "",
                           "integrationId": integrationIdValue ?? ""]
            )
        }
        
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Push payload: \(userInfo)")
        
        let subscriptionId = userInfo["subscriptionId"] as? String ?? ""
        let typeValue = userInfo["type"]
        let type = (typeValue as? Int) ?? Int(typeValue as? String ?? "")
        
        let targetRoute: NavigationRoute = {
            switch type {
            case 1:  return .connectEmail
            case 2:  return .subscriptionMatchView(fromList: true, fromPush: true, subscriptionId: subscriptionId)
            case 3:  return .pricingPlans() //removed as now, we don't have this type
            case 4:  return .inviteFriends()
            case 5:  return .home
            default: return .notifications
            }
        }()
        
        // Add a small delay to ensure the app is fully active and
        // NavigationStack is ready for a structural change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !AppIntentRouter.shared.isAppWarm {
                AppIntentRouter.shared.pendingNotification = targetRoute
            } else {
                AppIntentRouter.shared.resetStack(to: [.home, targetRoute])
            }
        }
        completionHandler()
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("AppDelegate: open URL called with \(url.absoluteString)")
        // Handle MSAL authentication
        let msalHandled = MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[.sourceApplication] as? String)
        
        return msalHandled
    }
    
    // MARK: - Universal Links (for Branch)
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("AppDelegate: continue userActivity called")
        return false
    }
    
    func setupLinkListeners() {
        // Listen for dynamic links
        ULink.shared.dynamicLinkStream
            .sink { [weak self] resolved in
                self?.handleDynamicLink(resolved)
            }
            .store(in: &cancellables)
        
        // Listen for unified links
        ULink.shared.unifiedLinkStream
            .sink { [weak self] resolved in
                self?.handleUnifiedLink(resolved)
            }
            .store(in: &cancellables)
    }
    
    func handleDynamicLink(_ data: ULinkResolvedData) {
        print("🔗 [ULink] Resolved Dynamic Link: \(data.slug ?? "N/A")")
        if let params = data.parameters {
            print("📦 [ULink] Parameters: \(params)")
        }
        
        if let referrerId = data.parameters?["referrerId"] as? String {
            print("💎 [Referral] Found Referrer ID: \(referrerId)")
            Constants.saveDefaults(value: referrerId, key: Constants.referrerId)
        }
    }
    
    func handleUnifiedLink(_ data: ULinkResolvedData) {
        print("🔗 [ULink] Resolved Unified Link: \(data.slug ?? "N/A")")
        if let params = data.parameters {
            print("📦 [ULink] Parameters: \(params)")
        }
    }
}

@main
struct SubzilloApp: App {
    
    init() {
        let item = UITextField.appearance().inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        FirebaseApp.configure()
        
        // ULink initialization
        let config = ULinkConfig(
            apiKey: "ulk_e7ceb2717958baacfd613045f27abc945273b947cec90cbd",
            debug: false,
            enableDeepLinkIntegration: true
        )
        
        Task {
            do {
                try await ULink.initialize(config: config)
            } catch {
                print("SubzilloApp: Failed to initialize ULink: \(error)")
            }
        }
        
    }
    
    @StateObject private var router             = AppIntentRouter.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var networkMonitor     = NetworkMonitor()
    @StateObject private var toastManager       = ToastManager()
    @StateObject private var bottomToastManager = BottomToastManager()
    @StateObject var mediaPicker                = MediaPickerManager.shared
    @StateObject private var themeManager       = ThemeManager()
    @StateObject private var sharedViewModel    = CommonAPIViewModel()
    @StateObject private var sessionManager     = SessionManager()
    let persistenceController                   = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(appDelegate)
                .environmentObject(networkMonitor)
                .environmentObject(toastManager)
                .environmentObject(bottomToastManager)
                .environmentObject(mediaPicker)
                .environmentObject(themeManager)
                .environmentObject(sharedViewModel)
                .environmentObject(sessionManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .buttonStyle(InteractiveButtonStyle())
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkAndUpdateDeviceToken()
            }
        }
    }
    
    func checkAndUpdateDeviceToken() {
        guard let token = appDelegate.deviceToken, !token.isEmpty else {
            print("Device token is nil or empty")
            return
        }
        let storedToken = Constants.getUserDefaultsValue(for: "device_token")
        let isLoggedIn = AppState.shared.isLoggedIn
        if storedToken != token && isLoggedIn {
            if Constants.FeatureConfig.isS4Enabled {
                sharedViewModel.updateDeviceId(input: UpdateDeviceIdRequest(
                    userId: Constants.getUserId(),
                    deviceId: token,
                    uniqueId: UUID().uuidString
                ))
                Constants.saveDefaults(value: token, key: "device_token")
            }
            print(" Device token API called and saved to defaults")
        } else if storedToken != token {
            print("Device token changed but user not logged in. Waiting for login to sync.")
        } else {
            print("Device token is already up to date.")
        }
    }
}


struct RootView: View {
    @StateObject var appState       = AppState.shared
    @EnvironmentObject var router   : AppIntentRouter
    @StateObject var sheetManager   = SheetManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemScheme
    @State private var upgradeNowSheetHeight    : CGFloat = .zero
    
    var body: some View {
        ZStack(alignment: .bottom) {
//            // Global Dynamic Gradient Background
//            DynamicBackgroundView()
            
            ZStack {
                if let currentRoute = router.path.last {
                    // Main Content Swap (Full Screen)
                    destinationView(for: currentRoute)
                        .id(currentRoute) // Forces a fresh animation on every screen change
                        .applyGlobalTransition()
                } else {
                    // Initial Splash View
                    SplashView()
                        .applyGlobalTransition()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showTabBar {
                CurvedTabBar(
                    selectedTab: $router.selectedTab,
                    selectedSegment: $router.selectedSegment
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.customScreenAnimation, value: router.path)
        .animation(.customScreenAnimation, value: showTabBar)
        .environmentObject(appState)
        .onAppear {
            router.isAppWarm = true
        }
        .sheet(isPresented: $sheetManager.isOfflineSheetVisible) {
            OfflineSheet()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(540)])
        }
        .sheet(isPresented: $sheetManager.isUpgradeSheetVisible) {
            InfoAlertSheet(
                onDelegate: {
                    router.navigate(to: .pricingPlans())
                }, title                : "Upgrade Required",
                subTitle                : "You've reached your current plan limit. Upgrade to continue managing your subscriptions",
                buttonTitle             : "Upgrade Now",
                imageSize               : 70,
                isCancelButtonVisible   : true
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    upgradeNowSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(upgradeNowSheetHeight)])
        }
        .sheet(isPresented: $sheetManager.isFamilyMemberLimitSheetVisible) {
            SubscriptionAlertSheet(
                onDelegate: {
                    
                }, title                : "Family Member Limit Reached",
                subTitle                : "You’ve reached the maximum number of family members allowed.",
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
        .preferredColorScheme(themeManager.currentAppearance.colorScheme)
    }
    
    private var showTabBar: Bool {
        guard let current = router.path.last else { return false }
        switch current {
        case .splash, .login, .signup, .onboarding, .welcome, .verifyOtp, .SuccessView, .termsAndPrivacy:
            return false
        default:
            return true
        }
    }
    
    @ViewBuilder
    private func destinationView(for screen: NavigationRoute) -> some View {
        switch screen {
        case .emailIntegration:
            Text("Test")
        case .bankStatement:
            Text("Test")
        case .smartAssistantAI:
            SmartAIAssistantView()
        case .appearance:
            Text("Test")
        case .notifications:
            NotificationsView()
        case .home:
            RootTabBar()
        case .signup(let fromSocialLogin):
            RegistrationView(fromSocialLogin: fromSocialLogin)
        case .login:
            LoginView()
        case .onboarding:
            if Constants.getUserDefaultsBooleanValue(for: "isSyncing"){
                
            }else{
                OnboardingView()
            }
        case .verifyOtp(let fromLogin, let verifyMergeType):
            OtpVerifyView(fromLogin:fromLogin, verifyMergeType:verifyMergeType)
        case .termsAndPrivacy(isTerm: let isTerm):
            TermsAndPrivacyView(isTerm:isTerm ?? false)
        case .SuccessView(isOtp: let isOtp,let isMobile):
            SuccessView(isOtp:isOtp ?? false,isMobile:isMobile)
        case .welcome:
            WelcomeHomeView()
        case .manualEntry(let isFromEdit, let isFromListEdit, let isRenew, let subscriptionId, let familyMemberId, let isFromEmail, let fromEmailSync):
            ManualEntryView(isFromEdit: isFromEdit, isFromListEdit: isFromListEdit, isRenew: isRenew, subscriptionId: subscriptionId, familyMemberId: familyMemberId, isFromEmail: isFromEmail, fromEmailSync: fromEmailSync)
        case .voiceCommandView:
            VoiceCommandView()
        case .subscriptionPreviewView(let subscriptionsData, let content, let isFromImage, let isFromEmail, let audioUrl, let fromEmailSync, let isRenew):
            SubscriptionPreviewView(isFromImage:isFromImage, isFromEmail: isFromEmail, subscriptionsData: subscriptionsData, content: content, audioURL: audioUrl, fromEmailSync: fromEmailSync, isRenew: isRenew)
        case .subscriptionMatchView(let subscriptionData, let fromList, let fromPush, let subscriptionId):
            SubscriptionMatchView(subscriptionData: subscriptionData, subscriptionId: subscriptionId, fromList: fromList, fromPush: fromPush)
        case .pasteTextView:
            PasteTextView()
        case .duplicateSubscriptionsView(let duplicateSubsList, let fromFamily, let isFromEmail):
            DuplicateSubscriptionsView(duplicateSubsList: duplicateSubsList, fromFamily: fromFamily, isFromEmail: isFromEmail)
        case .duplicateUpdateView(let duplicateSubsList, let selectedIndex, let fromFamily, let isFromEmail):
            DuplicateUpdateView(duplicateSubsList: duplicateSubsList, selectedIndex: selectedIndex, fromFamily: fromFamily, isFromEmail: isFromEmail)
        case .addSubscriptionsView:
            RootTabBar(selectedTab: .addSubscription)
        case .duplicateSubDetailsView(let subscriptionData):
            DuplicateSubDetailsView(subscriptionData: subscriptionData)
        case .subscriptionsListView(let selectedSegment):
            RootTabBar(selectedTab: .subscriptions, selectedSegment: selectedSegment)
        case .myCards:
            MyCardsView()
        case .familyMembersView:
            FamilyMembersView()
        case .connectEmail:
            ConnectEmailView()
        case .connectedEmailsList(let isIntegrations):
            ConnectedEmailsListView(isIntegrations: isIntegrations)
        case .settings:
            SettingsView()
        case .contactUs:
            ContactUsView()
        case .pricingPlans(let fromPreview, let selectedTab):
            PricingPlansView(fromPreview: fromPreview, selectedTab: selectedTab)
        case .inviteFriends(let uLink):
            InviteFriendsView(uLink: uLink)
        case .emailSyncProgress(let logId):
            EmailSyncProgressView(logId: logId)
        case .extractedSubscriptions(let subscriptions, let fromEmailSync, let integrationId):
            ExtractedSubscriptionsView(subscriptions: subscriptions, fromEmailSyncScreen: fromEmailSync, integrationId: integrationId)
        case .connectICloudView:
            ConnectICloudView()
        case .AgentChatView:
            AgentChatView()
        case .splash:
            SplashView()
        }
    }
}

final class AppIntentRouter: ObservableObject {
    static let shared = AppIntentRouter()
    private init() {}
    
    @Published var selectedTab              : Tab = .home
    @Published var selectedSegment          : Segment? = .first
    @Published var pendingNotification      : NavigationRoute? = nil
    @Published var isAppWarm                : Bool = false
    @Published var hasNavigatedFromSplash   : Bool = false
    @Published var path                     : [NavigationRoute] = [] // Single Source of Truth
    var currentRoute                        : NavigationRoute? { path.last }
}

extension AppIntentRouter {
    func navigate(to route: NavigationRoute) {
        withAnimation(.customScreenAnimation) {
            path.append(route)
        }
    }
    
    func navigateAndReplace(to route: NavigationRoute) {
        withAnimation(.customScreenAnimation) {
            if !path.isEmpty {
                path.removeLast()
            }
            path.append(route)
        }
    }
    
    func pop(count: Int = 1) {
        withAnimation(.customScreenAnimation) {
            if path.count >= count {
                path.removeLast(count)
            } else {
                path.removeAll()
            }
        }
    }
    
    func resetStack(to newStack: [NavigationRoute]) {
        withAnimation(.customScreenAnimation) {
            path = newStack
            hasNavigatedFromSplash = true
        }
    }
}
