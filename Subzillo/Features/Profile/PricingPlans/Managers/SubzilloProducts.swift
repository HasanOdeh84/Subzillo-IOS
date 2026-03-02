//
//  SubzilloProducts.swift
//  Subzillo
//
//  Created by Antigravity on 06/02/26.
//

import Foundation

public struct SubzilloProducts {
    
    public static let silverMonthly = "com.subzillo.silver.monthly"
    public static let silverYearly  = "com.subzillo.silver.yearly"
    public static let goldMonthly   = "com.subzillo.gold.monthly"
    public static let goldYearly    = "com.subzillo.gold.yearly"
    
    public static let productIdentifiers: Set<String> = [
        SubzilloProducts.silverMonthly,
        SubzilloProducts.silverYearly,
        SubzilloProducts.goldMonthly,
        SubzilloProducts.goldYearly
    ]
    
    static func productId(for planName: String, segment: Segment?) -> String? {
        let name = planName.lowercased()
        let isYearly = segment == .second
        if name.contains("silver") {
            return isYearly ? silverYearly : silverMonthly
        } else if name.contains("gold") {
            return isYearly ? goldYearly : goldMonthly
        }
        return nil // Free plan has no IAP product
    }
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
