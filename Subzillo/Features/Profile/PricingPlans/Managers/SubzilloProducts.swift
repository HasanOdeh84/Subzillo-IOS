

import Foundation

public struct SubzilloProducts {
    
    public static let silverMonthly = "com.subzillo.silver.monthly"
    public static let silverYearly  = "com.subzillo.silver.yearly"
    public static let goldMonthly   = "com.subzillo.gold.monthly"
    public static let goldYearly    = "com.subzillo.gold.yearly"
    
    public static let productIdentifiers: Set<ProductIdentifier> = [
        SubzilloProducts.silverMonthly,
        SubzilloProducts.silverYearly,
        SubzilloProducts.goldMonthly,
        SubzilloProducts.goldYearly
    ]
    
    public static let store = IAPHelper(productIds: SubzilloProducts.productIdentifiers)

}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
