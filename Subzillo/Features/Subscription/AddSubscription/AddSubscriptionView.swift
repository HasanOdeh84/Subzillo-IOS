//
//  AddSubscriptionView.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 11/09/25.
//

import SwiftUI

struct AddSubscriptionView: View {
    let serviceName: String
    let planName: String
    let price: Double
    let billingCycle: String
    @StateObject var addSubscriptionVM = AddSubscriptionViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Service: \(serviceName)")
            Text("Plan: \(planName)")
            Text("Price: \(Int(price))")
            Text("Cycle: \(billingCycle)")
            Button("Add subscription"){
                let input = AddSubscriptionRequest(userId           : Constants.getUserId(),
                                                   serviceName      : serviceName,
                                                   email            : "alekhya@krify.com",
                                                   subscriptionType : planName,
                                                   amount           : price,
                                                   currency         : "$",
                                                   billingCycle     : billingCycle,
                                                   nextPaymentDate  : "2025-01-01T00:00:00.000Z",
                                                   paymentMethod    : "sample",
                                                   category         : "sample",
                                                   source           : "sample")
                addSubscriptionVM.addSubscription(input: input)
            }
        }
        .navigationTitle("Add Subscription")
        .padding()
    }
}
