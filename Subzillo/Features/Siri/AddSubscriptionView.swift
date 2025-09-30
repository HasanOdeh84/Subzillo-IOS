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

    var body: some View {
        VStack(spacing: 16) {
            Text("Service: \(serviceName)")
            Text("Plan: \(planName)")
            Text("Price: \(Int(price))")
            Text("Cycle: \(billingCycle)")
        }
        .navigationTitle("Add Subscription")
        .padding()
    }
}
