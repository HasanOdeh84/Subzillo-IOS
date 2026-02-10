//
//  BranchManager.swift
//  Subzillo
//
//  Created by Branch.io Integration
//

import Foundation
import BranchSDK

class BranchManager: ObservableObject {
    static let shared = BranchManager()
    
    @Published var branchParams: [String: Any]?
    @Published var deepLinkData: DeepLinkData?
    
    private init() {}
    
    // MARK: - Initialize Branch Session
    func initSession(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.getInstance().initSession(launchOptions: launchOptions) { [weak self] params, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Branch initialization error: \(error.localizedDescription)")
                return
            }
            
            guard let params = params as? [String: Any] else {
                print("⚠️ No Branch params received")
                return
            }
            
            print("✅ Branch initialized with params: \(params)")
            
            DispatchQueue.main.async {
                self.branchParams = params
                self.handleDeepLink(params: params)
            }
        }
    }
    
    // MARK: - Handle Deep Link
    private func handleDeepLink(params: [String: Any]) {
        // Check if this is a real deep link (not just app open)
        guard params.count > 2 else {
            print("ℹ️ Branch: Regular app open, no deep link data")
            return
        }
        
        // Check if link was clicked
        guard let clicked = params["+clicked_branch_link"] as? Bool, clicked else {
            print("ℹ️ Branch: Link not clicked")
            return
        }
        
        print("🔗 Branch Deep Link Detected")
        
        // Extract deep link data
        let subscriptionId = params["subscriptionId"] as? String
        let userId = params["userId"] as? String
        let referralCode = params["referralCode"] as? String
        let feature = params["~feature"] as? String
        let campaign = params["~campaign"] as? String
        
        // Create deep link data object
        let deepLinkData = DeepLinkData(
            subscriptionId: subscriptionId,
            userId: userId,
            referralCode: referralCode,
            feature: feature,
            campaign: campaign,
            allParams: params
        )
        
        self.deepLinkData = deepLinkData
        
        // Handle navigation based on deep link
        handleNavigation(deepLinkData: deepLinkData)
    }
    
    // MARK: - Handle Navigation
    private func handleNavigation(deepLinkData: DeepLinkData) {
        // Check if user is logged in
        let isLoggedIn = AppState.shared.isLoggedIn
        
        if !isLoggedIn {
            // Save deep link data for later use after login
            saveDeepLinkForLater(deepLinkData)
            print("💾 Deep link saved for after login")
            return
        }
        
        // Navigate based on deep link type
        if let subscriptionId = deepLinkData.subscriptionId {
            // Navigate to subscription details
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppIntentRouter.shared.navigate(to: .subscriptionMatchView(fromList: true, subscriptionId: subscriptionId))
            }
        } else if let referralCode = deepLinkData.referralCode {
            // Handle referral code
            handleReferralCode(referralCode)
        }
    }
    
    // MARK: - Save Deep Link for Later
    private func saveDeepLinkForLater(_ deepLinkData: DeepLinkData) {
        if let subscriptionId = deepLinkData.subscriptionId {
            Constants.saveDefaults(value: subscriptionId, key: "pending_subscription_id")
        }
        if let referralCode = deepLinkData.referralCode {
            Constants.saveDefaults(value: referralCode, key: "pending_referral_code")
        }
    }
    
    // MARK: - Process Pending Deep Links
    func processPendingDeepLinks() {
        // Call this after user logs in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppIntentRouter.shared.navigate(to: .subscriptionMatchView(fromList: true, subscriptionId: Constants.getUserDefaultsValue(for: "pending_subscription_id")))
        }
        Constants.removeDefaults(key: "pending_subscription_id")
        
        handleReferralCode(Constants.getUserDefaultsValue(for: "pending_referral_code"))
        Constants.removeDefaults(key: "pending_referral_code")
    }
    
    // MARK: - Handle Referral Code
    private func handleReferralCode(_ referralCode: String) {
        print("🎁 Referral code received: \(referralCode)")
        // Implement your referral code logic here
        // For example, save it and apply during signup or show a special offer
        Constants.saveDefaults(value: referralCode, key: "referral_code")
    }
    
    // MARK: - Create Share Link
    func createShareLink(
        subscriptionId: String? = nil,
        userId: String? = nil,
        feature: String = "subscription_share",
        completion: @escaping (String?, Error?) -> Void
    ) {
        let buo = BranchUniversalObject(canonicalIdentifier: "subscription/\(subscriptionId ?? UUID().uuidString)")
        
        // Set metadata
        buo.title = "Check out this subscription on Subzillo"
        buo.contentDescription = "I'm sharing a subscription with you on Subzillo"
        buo.imageUrl = "https://your-app-icon-url.com/icon.png" // Replace with your app icon URL
        
        // Add custom metadata
        if let subscriptionId = subscriptionId {
            buo.contentMetadata.customMetadata["subscriptionId"] = subscriptionId
        }
        if let userId = userId {
            buo.contentMetadata.customMetadata["userId"] = userId
        }
        
        // Create link properties
        let lp = BranchLinkProperties()
        lp.feature = feature
        lp.channel = "app_share"
        lp.campaign = "subscription_sharing"
        
        // Generate short URL
        buo.getShortUrl(with: lp) { url, error in
            if let error = error {
                print("❌ Branch link creation error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let url = url {
                print("✅ Branch link created: \(url)")
                completion(url, nil)
            }
        }
    }
    
    // MARK: - Show Share Sheet
    func showShareSheet(
        subscriptionId: String? = nil,
        userId: String? = nil,
        feature: String = "subscription_share"
    ) {
        createShareLink(subscriptionId: subscriptionId, userId: userId, feature: feature) { url, error in
            guard let url = url else {
                print("❌ Failed to create share link")
                return
            }
            
            DispatchQueue.main.async {
                let shareText = "Check out this subscription on Subzillo: \(url)"
                let activityVC = UIActivityViewController(
                    activityItems: [shareText],
                    applicationActivities: nil
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    // For iPad
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = rootViewController.view
                        popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                   y: rootViewController.view.bounds.midY,
                                                   width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    rootViewController.present(activityVC, animated: true)
                }
            }
        }
    }
    
    // MARK: - Track Events
    func trackEvent(_ eventName: String, metadata: [String: Any]? = nil) {
        let event = BranchEvent.customEvent(withName: eventName)
        
        if let metadata = metadata {
            for (key, value) in metadata {
                event.customData[key] = value as? String ?? "\(value)"
            }
        }
        
        event.logEvent()
        print("📊 Branch event tracked: \(eventName)")
    }
    
    // MARK: - Set User Identity
    func setUserIdentity(userId: String) {
        Branch.getInstance().setIdentity(userId)
        print("👤 Branch user identity set: \(userId)")
    }
    
    // MARK: - Logout
    func logout() {
        Branch.getInstance().logout()
        print("👋 Branch user logged out")
    }
}

// MARK: - Deep Link Data Model
struct DeepLinkData {
    let subscriptionId: String?
    let userId: String?
    let referralCode: String?
    let feature: String?
    let campaign: String?
    let allParams: [String: Any]
}
