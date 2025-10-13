//
//  SubzilloApp.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI
import UserNotifications
import UIKit

class AppDelegate: NSObject, ObservableObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @Published var deviceToken          : String? = nil
    @Published var permissionGranted    : Bool = false
    static let shared                   = AppDelegate()
    
    // Called when app launches
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        sleep(3)
        UNUserNotificationCenter.current().delegate = self
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
        DispatchQueue.main.async {
            self.deviceToken = token
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
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Push payload: \(userInfo)")
        
        if let type = userInfo["type"] as? String {
            DispatchQueue.main.async {
                switch type {
                case "email":  AppIntentRouter.shared.pendingRoute = .emailIntegration
                case "bank":   AppIntentRouter.shared.pendingRoute = .bankStatement
                case "chat":   AppIntentRouter.shared.pendingRoute = .chat
                case "appearance": AppIntentRouter.shared.pendingRoute = .appearance
                case "notifications": AppIntentRouter.shared.pendingRoute = .notifications
                default: break
                }
            }
        }
        completionHandler()
    }
}

@main
struct SubzilloApp: App {
    
    @StateObject private var router         = AppIntentRouter.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var audioManager   = AudioRecorderManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var toastManager   = ToastManager()
    @StateObject var mediaPicker            = MediaPickerManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(appDelegate)
                .environmentObject(networkMonitor)
                .environmentObject(toastManager)
                .environmentObject(mediaPicker)
                .withLoader()
                .withAlert()
                .withToast()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
//                print("✅ App is in Foreground (Active)")
                appDelegate.requestAuthorization()
            case .inactive:
//                print("⚠️ App is Inactive (e.g., transitioning)")
                audioManager.clearAll()
            case .background:
//                print("🌙 App is in Background")
                audioManager.clearAll()
            default:
                break
            }
        }
    }
}

struct RootView: View {
    @StateObject var appState   = AppState.shared
    @State private var path     = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if appState.isLoggedIn {
                    RootTabBar(path: $path)
                } else {
                    LoginView(path: $path)
                        .onAppear {
                            if !path.isEmpty {
                                path.removeLast(path.count) // reset stack on login view
                            }
                        }
                }
            }
            .navigationDestination(for: PendingRoute.self) { screen in
                switch screen {
                case .addSubscription(let service, let plan, let price, let cycle):
                    AddSubscriptionView(
                        serviceName: service,
                        planName: plan,
                        price: price,
                        billingCycle: cycle
                    )
                case .emailIntegration:
                    AddSubscriptionView(
                        serviceName: "service",
                        planName: "plan",
                        price: 990,
                        billingCycle: "cycle"
                    )
                case .bankStatement:
                    Text("Test")
                case .chat:
                    Text("Test")
                case .appearance:
                    Text("Test")
                case .notifications:
                    Text("Test")
                case .home:
                    RootTabBar(path: $path)
                case .forgot:
                    ForgotPasswordView(path:$path)
                case .signup:
                    RegistrationView(path: $path)
                case .login:
                    LoginView(path: $path)
                        .onAppear {
                            if !path.isEmpty {
                                path.removeLast(path.count) // reset stack on login view
                            }
                        }
                case .onboarding:
                    OnboardingView()
                case .verifyOtp(let emailId, let from, let username):
                    OtpVerifyView(path:$path, email:emailId ?? "", username:username ?? "", from:from)
                case .resetPassword(let username):
                    ResetPasswordView(username:username ?? "", path:$path)
                }
            }
        }
        .environmentObject(appState)
    }
}
