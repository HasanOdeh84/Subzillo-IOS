//
//  AddSubscriptionIntent.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 11/09/25.
//

import SwiftUI
import AppIntents

var siriData : [String:Any]!

struct AddSubscriptionIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Add Subscription"
    static var description = IntentDescription("Add a subscription by specifying name, category, plan, price, currency and billing cycle.")
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
    @Parameter(title: "Category") var category: String
    @Parameter(title: "Plan Type") var planName: String
    @Parameter(title: "Amount") var price: Double
    @Parameter(title: "Currency") var currency: String
    @Parameter(title: "Billing Cycle") var billingCycle: String
    @Parameter(
        title: "Next Charge Date",
        requestValueDialog: "When is the next charge date?"
    )
    var nextChargeDate: Date
    
    @MainActor
    func perform() async throws -> some IntentResult {
        //    func perform() async throws -> some IntentResult & ProvidesDialog{
        var currencyCode    = ""
        var currencySymbol  = ""
        if let currency = Constants.shared.getCurrencyDetails(from: currency) {
            print(currency.code)
            print(currency.symbol)
            currencyCode    = currency.code
            currencySymbol  = currency.symbol
        }
        
        siriData = ["serviceName":serviceName,"planName":planName,"price":price,"billingCycle":billingCycle,"category":category,"currencyCode":currencyCode, "currencySymbol": currencySymbol, "nextChargeDate": nextChargeDate]
        if AppState.shared.isLoggedIn{
            NotificationCenter.default.post(name: .closeAllBottomSheets, object: nil)
            AppIntentRouter.shared.navigatingRoute = .manualEntry(isFromEdit: false)
        }
        
        return .result()
        //        return .result(
        //            dialog: "Opening Subzillo to add your Netflix Basic subscription."
        //        )
    }
    
    /*
     do {
     let success =  await CommonAPIViewModel().getCurrencies1()
     
     if success {
     return .result(dialog: "Subscription added successfully!")
     } else {
     return .result(dialog: "Failed to add subscription.")
     }
     
     } catch {
     return .result(dialog: "Something went wrong while adding your subscription.")
     }
     */
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
