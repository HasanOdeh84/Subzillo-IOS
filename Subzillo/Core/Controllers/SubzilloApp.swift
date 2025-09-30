//
//  SubzilloApp.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 17/09/25.
//

import SwiftUI

@main
struct SubzilloApp: App {
    
    @StateObject private var router         = AppIntentRouter.shared
    @UIApplicationDelegateAdaptor(NotificationManager.self) var notificationManager
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var audioManager   = AudioRecorderManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var toastManager   = ToastManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(notificationManager)
                .environmentObject(networkMonitor)
                .environmentObject(toastManager)
                .withLoader()
                .withAlert()
                .withToast()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
//                print("✅ App is in Foreground (Active)")
                notificationManager.requestAuthorization()
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
