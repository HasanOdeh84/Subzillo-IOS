//
//  AddSubscriptionIntent.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 11/09/25.
//

import SwiftUI
import AppIntents

struct AddSubscriptionIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Subscription"
    static var description = IntentDescription("Add a subscription by specifying name, plan, price, and billing cycle.")
    static var openAppWhenRun: Bool = true
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add subscription for \(\.$serviceName) with \(\.$planName) at \(\.$price) billed \(\.$billingCycle)")
    }
    
    static var suggestedInvocationPhrases: [LocalizedStringResource] {
        [
            "Add subscription",
            "Create subscription",
            "Add subscription in Subzillo",
            "Create subscription in Subzillo",
            "Add subscription for Netflix in Subzillo",
            "Add prime subscription in Subzillo",
            "Add a subscription in Subzillo for Netflix basic plan at 499rs monthly",
            "Create a Prime subscription in Subzillo with yearly billing at 1499rs"
        ]
    }
    
    // 👇 This makes it appear in Siri without a manual Shortcut
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: AddSubscriptionIntent(),
                phrases: ["Add subscription in \(.applicationName)",
                          //                          "Track subscription in \(.applicationName)",
                          "Create subscription in \(.applicationName)"]
            )
        ]
    }
    
    @Parameter(title: "Service Name") var serviceName: String
    @Parameter(title: "Plan Name") var planName: String
    @Parameter(title: "Price") var price: Double
    @Parameter(title: "Billing Cycle") var billingCycle: String
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Save into router (instead of deep link)
        AppIntentRouter.shared.pendingRoute = .addSubscription(
            serviceName: serviceName,
            planName: planName,
            price: price,
            billingCycle: billingCycle
        )
        return .result()
    }
}

struct SubzilloShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddSubscriptionIntent(),
            phrases: [
                "Add subscription in \(.applicationName)",
                //                "Track subscription in \(.applicationName)",
                "Create subscription in \(.applicationName)",
                //                "Add \(\.$serviceName) subscription in \(.applicationName)",
                //                "In \(.applicationName), add subscription for \(\.$serviceName)"
            ],
            shortTitle: "Add Subscription",
            systemImageName: "plus.circle"
        )
    }
}
