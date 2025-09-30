//
//  NotificationManager.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 12/09/25.
//

import SwiftUI
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @Published var deviceToken: String? = nil
    @Published var permissionGranted: Bool = false
    
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
