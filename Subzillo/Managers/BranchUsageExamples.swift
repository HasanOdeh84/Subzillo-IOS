//
//  BranchUsageExamples.swift
//  Subzillo
//
//  Example usage of Branch.io integration
//  This file shows how to use BranchManager in your views
//

import SwiftUI

// MARK: - Example 1: Share Subscription Button
struct SubscriptionShareButtonExample: View {
    let subscriptionId: String
    let userId: String
    
    var body: some View {
        Button(action: {
            // Simple share with system share sheet
            BranchManager.shared.showShareSheet(
                subscriptionId: subscriptionId,
                userId: userId,
                feature: "subscription_share"
            )
        }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share Subscription")
            }
        }
    }
}

// MARK: - Example 2: Custom Share Link Creation
struct CustomShareLinkExample: View {
    let subscriptionId: String
    @State private var shareURL: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Creating share link...")
            } else if let url = shareURL {
                VStack(spacing: 12) {
                    Text("Share Link Created!")
                        .font(.headline)
                    
                    Text(url)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    Button("Copy Link") {
                        UIPasteboard.general.string = url
                    }
                }
            } else {
                Button("Create Share Link") {
                    createShareLink()
                }
            }
        }
    }
    
    private func createShareLink() {
        isLoading = true
        
        BranchManager.shared.createShareLink(
            subscriptionId: subscriptionId,
            userId: Constants.getUserId(),
            feature: "custom_share"
        ) { url, error in
            isLoading = false
            
            if let error = error {
                print("Error creating link: \(error)")
                return
            }
            
            shareURL = url
        }
    }
}

// MARK: - Example 3: Referral Link Generator
struct ReferralLinkExample: View {
    @State private var referralURL: String?
    @State private var isGenerating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Invite Friends")
                .font(.title2)
                .bold()
            
            Text("Share your referral link and get rewards!")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let url = referralURL {
                VStack(spacing: 12) {
                    Text(url)
                        .font(.caption)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    HStack(spacing: 16) {
                        Button("Copy") {
                            UIPasteboard.general.string = url
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Share") {
                            shareReferralLink(url)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else {
                Button("Generate Referral Link") {
                    generateReferralLink()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)
            }
        }
        .padding()
        .onAppear {
            generateReferralLink()
        }
    }
    
    private func generateReferralLink() {
        isGenerating = true
        
        BranchManager.shared.createShareLink(
            userId: Constants.getUserId(),
            feature: "referral"
        ) { url, error in
            isGenerating = false
            referralURL = url
        }
    }
    
    private func shareReferralLink(_ url: String) {
        let text = "Join me on Subzillo and manage your subscriptions! Use my referral link: \(url)"
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Example 4: Track Events
struct EventTrackingExample {
    
    // Track when user views a subscription
    static func trackSubscriptionView(subscriptionId: String, category: String) {
        BranchManager.shared.trackEvent("subscription_viewed", metadata: [
            "subscriptionId": subscriptionId,
            "category": category,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // Track when user adds a subscription
    static func trackSubscriptionAdded(
        subscriptionId: String,
        amount: Double,
        currency: String,
        category: String
    ) {
        BranchManager.shared.trackEvent("subscription_added", metadata: [
            "subscriptionId": subscriptionId,
            "amount": String(amount),
            "currency": currency,
            "category": category
        ])
    }
    
    // Track when user shares a subscription
    static func trackSubscriptionShared(subscriptionId: String, method: String) {
        BranchManager.shared.trackEvent("subscription_shared", metadata: [
            "subscriptionId": subscriptionId,
            "shareMethod": method
        ])
    }
    
    // Track when user completes onboarding
    static func trackOnboardingComplete() {
        BranchManager.shared.trackEvent("onboarding_complete")
    }
    
    // Track when user upgrades to premium
    static func trackPremiumUpgrade(plan: String, price: String) {
        BranchManager.shared.trackEvent("premium_upgrade", metadata: [
            "plan": plan,
            "price": price
        ])
    }
}

// MARK: - Example 5: Login/Logout Integration
struct LoginExample {
    
    // Call this after successful login
    static func handleLogin(userId: String) {
        // Set Branch user identity
        BranchManager.shared.setUserIdentity(userId: userId)
        
        // Process any pending deep links
        BranchManager.shared.processPendingDeepLinks()
        
        // Track login event
        BranchManager.shared.trackEvent("user_login")
    }
    
    // Call this on logout
    static func handleLogout() {
        // Clear Branch user identity
        BranchManager.shared.logout()
        
        // Track logout event
        BranchManager.shared.trackEvent("user_logout")
    }
}

// MARK: - Example 6: Deep Link Handling in View
struct DeepLinkAwareView: View {
    @StateObject private var branchManager = BranchManager.shared
    @State private var showAlert = false
    @State private var deepLinkMessage = ""
    
    var body: some View {
        VStack {
            Text("Deep Link Demo")
                .font(.title)
            
            if let deepLink = branchManager.deepLinkData {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deep Link Received!")
                        .font(.headline)
                    
                    if let subId = deepLink.subscriptionId {
                        Text("Subscription ID: \(subId)")
                    }
                    
                    if let userId = deepLink.userId {
                        Text("User ID: \(userId)")
                    }
                    
                    if let referral = deepLink.referralCode {
                        Text("Referral Code: \(referral)")
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

// MARK: - Example 7: Integration in Subscription Detail View
extension SubscriptionMatchView {
    
    // Add this method to your SubscriptionMatchView
    func shareSubscription() {
        // Track the share event
        EventTrackingExample.trackSubscriptionShared(
            subscriptionId: subscriptionId ?? "",
            method: "branch_link"
        )
        
        // Show share sheet
        BranchManager.shared.showShareSheet(
            subscriptionId: subscriptionId,
            userId: Constants.getUserId(),
            feature: "subscription_detail_share"
        )
    }
}

// MARK: - Example 8: Integration in Settings View
extension SettingsView {
    
    // Add this to your settings view for referral section
    var referralSection: some View {
        Section("Invite Friends") {
            Button(action: {
                generateAndShareReferralLink()
            }) {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Share Referral Link")
                            .font(.headline)
                        Text("Invite friends and earn rewards")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func generateAndShareReferralLink() {
        BranchManager.shared.createShareLink(
            userId: Constants.getUserId(),
            feature: "settings_referral"
        ) { url, error in
            guard let url = url else { return }
            
            let shareText = "Join me on Subzillo! Use my referral link: \(url)"
            let activityVC = UIActivityViewController(
                activityItems: [shareText],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }
}

// MARK: - Usage Notes
/*
 
 HOW TO USE THESE EXAMPLES:
 
 1. SHARING A SUBSCRIPTION:
    - Add a share button to your subscription detail view
    - Call: BranchManager.shared.showShareSheet(subscriptionId: id, userId: userId)
 
 2. REFERRAL PROGRAM:
    - Add a referral section in settings or profile
    - Generate unique links for each user
    - Track referral conversions in Branch Dashboard
 
 3. TRACKING EVENTS:
    - Track important user actions
    - View analytics in Branch Dashboard
    - Use for attribution and optimization
 
 4. LOGIN/LOGOUT:
    - Call setUserIdentity() after login
    - Call logout() when user logs out
    - Process pending deep links after login
 
 5. DEEP LINK HANDLING:
    - BranchManager automatically handles navigation
    - Customize handleNavigation() in BranchManager for your needs
    - Save deep links if user is not logged in
 
 */
