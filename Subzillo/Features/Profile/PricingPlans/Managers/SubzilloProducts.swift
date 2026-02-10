//
//  SubzilloProducts.swift
//  Subzillo
//
//  Created by Antigravity on 06/02/26.
//

import Foundation

public struct SubzilloProducts {
    
    // User requested "Premium Plan" and "Family Plan"
    // Assuming Monthly and Yearly for each based on the UI Toggle "Monthly / Annually"
    
    // TODO: Replace these with actual Product IDs from App Store Connect
    public static let premiumMonthly = "com.subzillo.premium.monthly"
    public static let premiumYearly  = "com.subzillo.premium.yearly"
    
    public static let familyMonthly  = "com.subzillo.family.monthly"
    public static let familyYearly   = "com.subzillo.family.yearly"
    
    // Add all product IDs to this set
    private static let productIdentifiers: Set<ProductIdentifier> = [
        SubzilloProducts.premiumMonthly,
        SubzilloProducts.premiumYearly,
        SubzilloProducts.familyMonthly,
        SubzilloProducts.familyYearly
    ]
    
    public static let store = IAPHelper(productIds: SubzilloProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
