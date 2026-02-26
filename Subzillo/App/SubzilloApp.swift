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
import BranchSDK
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
        
        // Initialize Branch.io
        //        BranchManager.shared.initSession(launchOptions: launchOptions)
        
        //Configure ULink synchronously to handle early access/listeners
        let ulinkConfig = ULinkConfig(
            apiKey: "ulk_e7ceb2717958baacfd613045f27abc945273b947cec90cbd",
            debug: true,
            enableDeepLinkIntegration: true
        )
        ULink.configure(config: ulinkConfig)
        
        //Set up stream listeners
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
        let type = (typeValue as? Int) ?? Int(typeValue as? String ?? "")
        if type == 1 {
            NotificationCenter.default.post(name: NSNotification.Name("RefreshConnectedEmails"), object: nil)
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
        
        if let type = type {
            let target: NavigationRoute? = {
                switch type {
                case 1:  return .connectedEmailsList(isIntegrations: false)
                case 2:  return .subscriptionMatchView(fromList: true, fromPush: true, subscriptionId: subscriptionId)
                case 3:  return .pricingPlans
                default: return nil
                }
            }()
            
            if let targetRoute = target {
                // Add a small delay to ensure the app is fully active and
                // NavigationStack is ready for a structural change
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if !AppIntentRouter.shared.isAppWarm {
                        AppIntentRouter.shared.pendingNotification = targetRoute
                    } else {
                        AppIntentRouter.shared.resetStackTo = [.home, targetRoute]
                    }
                }
            }
        }
        completionHandler()
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("AppDelegate: open URL called with \(url.absoluteString)")
        // Handle Branch deep links
        let branchHandled = Branch.getInstance().application(app, open: url, options: options)
        
        // Handle MSAL authentication
        let msalHandled = MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[.sourceApplication] as? String)
        
        return branchHandled || msalHandled
    }
    
    // MARK: - Universal Links (for Branch)
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("AppDelegate: continue userActivity called")
        // Handle Branch universal links
        //        return Branch.getInstance().continue(userActivity)
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
        print("Received dynamic link:")
        print("  Slug: \(data.slug ?? "N/A")")
        print("  Parameters: \(data.parameters ?? [:])")
        if let referrerId = data.parameters?["referrerId"] as? String {
            print("AppDelegate: Storing Referrer ID: \(referrerId)")
            Constants.saveDefaults(value: referrerId, key: Constants.referrerId)
        }
    }
    
    func handleUnifiedLink(_ data: ULinkResolvedData) {
        print("Received unified link:")
        print("  Slug: \(data.slug ?? "N/A")")
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
            debug: true,
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
            //                .preferredColorScheme(
            //                    themeManager.userChangedTheme
            //                    ? (themeManager.isDarkMode ? .dark : .light)
            //                    : nil // nil = follow system theme
            //                )
                .withLoader()
                .withAlert()
                .withToast()
                .withBottomToast()
                .onAppear {
                    sharedViewModel.getCurrencies()
                    sharedViewModel.getCountries()
                }
                .onOpenURL { url in
                    print("SubzilloApp: onOpenURL received: \(url.absoluteString)")
                    
                    ULink.shared.handleIncomingURL(url)
                    
                    if url.scheme == "subzillo" && url.host == "share" {
                        if AppState.shared.isLoggedIn {
                            SharedImageManager.shared.checkSharedImage()
                            if SharedImageManager.shared.sharedImage != nil {
                                NotificationCenter.default.post(name: .closeAllBottomSheets, object: nil)
                                AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
                            }
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DeviceTokenUpdated"))) { _ in
                    print("🔔 Received DeviceTokenUpdated notification")
                    checkAndUpdateDeviceToken()
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                //                print("✅ App is in Foreground (Active)")
                appDelegate.requestAuthorization()
                checkAndUpdateDeviceToken()
            case .inactive:
                print("⚠️ App is Inactive (e.g., transitioning)")
            case .background:
                print("🌙 App is in Background")
            }
        }
        .onChange(of: appDelegate.deviceToken) { _ in
            checkAndUpdateDeviceToken()
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
            //            sharedViewModel.updateDeviceId(input: UpdateDeviceIdRequest(
            //                userId: Constants.getUserId(),
            //                deviceId: token,
            //                uniqueId: UUID().uuidString
            //            ))
            //            Constants.saveDefaults(value: token, key: "device_token")
            print("✅ Device token API called and saved to defaults")
        } else if storedToken != token {
            print("ℹ️ Device token changed but user not logged in. Waiting for login to sync.")
        } else {
            print("ℹ️ Device token is already up to date.")
        }
    }
}

struct RootView: View {
    @StateObject var appState       = AppState.shared
    @State private var path         : [NavigationRoute] = []
    @EnvironmentObject var router   : AppIntentRouter
    @StateObject var sheetManager   = SheetManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemScheme
    @State private var upgradeNowSheetHeight    : CGFloat = .zero
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                SplashView()
            }
            .navigationDestination(for: NavigationRoute.self) { screen in
                switch screen {
                case .emailIntegration:
                    Text("Test")
                case .bankStatement:
                    Text("Test")
                case .chat:
                    Text("Test")
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
                    //                        .onAppear {
                    //                            if !path.isEmpty {
                    //                                path.removeLast(path.count) // reset stack on login view
                    //                            }
                    //                        }
                case .onboarding:
                    OnboardingView()
                case .verifyOtp(let fromLogin, let verifyMergeType):
                    OtpVerifyView(fromLogin:fromLogin, verifyMergeType:verifyMergeType)
                case .termsAndPrivacy(isTerm: let isTerm):
                    TermsAndPrivacyView(isTerm:isTerm ?? false)
                case .SuccessView(isOtp: let isOtp,let isMobile):
                    SuccessView(isOtp:isOtp ?? false,isMobile:isMobile)
                case .welcome:
                    WelcomeHomeView()
                case .manualEntry(let isFromEdit, let isFromListEdit, let isRenew, let subscriptionId, let familyMemberId, let isFromEmail):
                    ManualEntryView(isFromEdit: isFromEdit, isFromListEdit: isFromListEdit, isRenew: isRenew, subscriptionId: subscriptionId, familyMemberId: familyMemberId, isFromEmail: isFromEmail)
                case .voiceCommandView:
                    VoiceCommandView()
                case .subscriptionPreviewView(let subscriptionsData, let content, let isFromImage, let isFromEmail, let audioUrl):
                    SubscriptionPreviewView(isFromImage:isFromImage, isFromEmail: isFromEmail, subscriptionsData: subscriptionsData, content: content, audioURL: audioUrl)
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
                case .pricingPlans:
                    PricingPlansView()
                case .inviteFriends:
                    InviteFriendsView()
                }
            }
        }
        .environmentObject(appState)
        .onAppear {
            router.isAppWarm = true
        }
        .onChange(of: router.navigatingRoute) { new in
            //            guard let new = new else { return }
            //            let alreadyOnTarget = path.last?.isSameRoute(as: new) ?? false
            //            if new == .home {
            //                path = [.home]
            //            } else if alreadyOnTarget {
            //                NotificationCenter.default.post(
            //                    name    : NSNotification.Name("RefreshScreenData"),
            //                    object  : nil,
            //                    userInfo: ["subscriptionId": new.subId ?? ""]
            //                )
            //            } else {
            //                path.append(new)
            //            }
            //            router.hasNavigatedFromSplash = true
            guard let new = new else { return }
            path.append(new)
            router.navigatingRoute = nil
        }
        .onChange(of: router.resetStackTo) { newStack in
            guard let newStack = newStack else { return }
            let currentTop = path.last
            let targetTop = newStack.last
            let alreadyOnTarget = currentTop != nil && targetTop != nil && currentTop!.isSameRoute(as: targetTop!)
            if alreadyOnTarget {
                // Determine if the underlying stack structure (the 'Back' path) is actually different.
                let isStackDifferent = path.count != newStack.count ||
                (path.first != nil && newStack.first != nil && !path.first!.isSameRoute(as: newStack.first!))
                if isStackDifferent {
                    // Update the path to correct the Back button flow.
                    // Use a transaction to disable the "swipe" animation since the top screen is functionally same.
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        path = newStack
                    }
                } else {
                    // If the path is identical, we must post a notification to refresh the existing view.
                    NotificationCenter.default.post(
                        name    : NSNotification.Name("RefreshScreenData"),
                        object  : nil,
                        userInfo: ["subscriptionId": targetTop?.subId ?? ""]
                    )
                }
            } else {
                path = newStack
            }
            router.hasNavigatedFromSplash = true
            router.resetStackTo = nil
        }
        .onChange(of: router.popCount) { count in
            if count > 0 {
                if path.count >= count {
                    path.removeLast(count)
                } else {
                    path.removeLast(path.count)
                }
                router.popCount = 0
            }
        }
        .sheet(isPresented: $sheetManager.isOfflineSheetVisible) {
            OfflineSheet()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(540)])
        }
        .sheet(isPresented: $sheetManager.isUpgradeSheetVisible) {
            InfoAlertSheet(
                onDelegate: {
                    router.navigate(to: .pricingPlans)
                }, title                : "Upgrade Required",
                subTitle                : "You've reached your current plan limit. Upgrade to continue adding more.",
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
        .preferredColorScheme(
            themeManager.userChangedTheme
            ? (themeManager.isDarkMode ? .dark : .light)
            : nil
        )
        .onChange(of: systemScheme) { newScheme in
            themeManager.applySystemTheme(newScheme == .dark)
        }
    }
}

final class AppIntentRouter: ObservableObject {
    static let shared = AppIntentRouter()
    private init() {}
    
    @Published var navigatingRoute    : NavigationRoute? = nil
    @Published var popCount           : Int = 0
    @Published var pendingNotification: NavigationRoute? = nil
    @Published var resetStackTo       : [NavigationRoute]? = nil
    @Published var isAppWarm          : Bool = false
    @Published var hasNavigatedFromSplash: Bool = false
}

extension AppIntentRouter {
    func navigate(to route: NavigationRoute) {
        navigatingRoute = route
    }
    
    func pop(count: Int = 1) {
        popCount = count
    }
}
