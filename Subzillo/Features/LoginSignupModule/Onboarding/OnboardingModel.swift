//
//  OnboardingModel.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 08/11/25.
//

import Foundation

public struct UpdateOnboardingRequest: Codable {
    let userId                  : String
    let preferredCurrency       : String
    let preferredCurrencySymbol : String
    let noofSubscriptions       : Int
    let averageMonthlySpend     : Int
    let isoCountryCode          : String
}
