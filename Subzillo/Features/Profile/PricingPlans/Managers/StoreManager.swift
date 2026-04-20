import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let IAPHelperRestoreNotification = Notification.Name("IAPHelperRestoreNotification")
    static let IAPHelperNoRestorablePurchasesNotification = Notification.Name("IAPHelperNoRestorablePurchasesNotification")
}
open class IAPHelper: NSObject  {
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var restoredTransactions: [SKPaymentTransaction] = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
}
// MARK: - StoreKit API
extension IAPHelper {
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        restoredTransactions.removeAll()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
// MARK: - SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}
// MARK: - SKPaymentTransactionObserver
extension IAPHelper: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        //        print(transaction.transactionIdentifier!)
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier, transaction:transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore collected... \(productIdentifier)")
        restoredTransactions.append(transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    //    private func fail(transaction: SKPaymentTransaction) {
    //        print("fail...")
    //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelbuying"), object: nil)
    //        if let transactionError = transaction.error as NSError?,
    //           let localizedDescription = transaction.error?.localizedDescription,
    //           transactionError.code != SKError.paymentCancelled.rawValue {
    //            print("Transaction Error: \(localizedDescription)")
    //        }
    //        SKPaymentQueue.default().finishTransaction(transaction)
    //    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError? {
            // Check for manual cancellation from the sheet
            if transactionError.code == SKError.paymentCancelled.rawValue || transactionError.code == SKError.paymentInvalid.rawValue || transactionError.code == SKError.paymentNotAllowed.rawValue{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelbuying"), object: nil)
            }else if transactionError.code == SKError.unknown.rawValue {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "alreadySubscribed"), object: nil)
            }
            else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelbuying"), object: nil)
            }
            print("Transaction Error: \(transactionError.localizedDescription)")
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelbuying"), object: nil)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?,transaction: SKPaymentTransaction) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: transaction)
    }
    
    private func deliverRestoreNotificationFor(identifier: String?,transaction: SKPaymentTransaction) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperRestoreNotification, object: transaction)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoredTransactions.removeAll()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelbuying"), object: nil)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if restoredTransactions.isEmpty {
            NotificationCenter.default.post(name: .IAPHelperNoRestorablePurchasesNotification, object: nil)
        }
        else {
            // Find the one SINGLE transaction with the most recent date across ALL products
            if let latestTransaction = restoredTransactions.max(by: { ($0.transactionDate ?? Date.distantPast) < ($1.transactionDate ?? Date.distantPast) }) {
                
                let identifier = latestTransaction.payment.productIdentifier
                print("The absolute latest transaction found is \(identifier)")
                
                // Only deliver the ONE latest plan
                deliverRestoreNotificationFor(identifier: identifier, transaction: latestTransaction)
            }
        }
//        else {
//            // Group the collected transactions by product ID
//            let grouped = Dictionary(grouping: restoredTransactions, by: { $0.payment.productIdentifier })
//            
//            // For each group, find the transaction with the most recent date
//            let uniqueLatest = grouped.compactMap { (_, transactions) in
//                transactions.max(by: { ($0.transactionDate ?? Date.distantPast) < ($1.transactionDate ?? Date.distantPast) })
//            }
//            
//            print("Successfully filtered \(restoredTransactions.count) transactions down to \(uniqueLatest.count) active products.")
//            
//            for transaction in uniqueLatest {
//                let identifier = transaction.payment.productIdentifier
//                print("Delivering latest restored transaction for \(identifier)")
//                deliverRestoreNotificationFor(identifier: identifier, transaction: transaction)
//            }
//        }
        restoredTransactions.removeAll()
    }
}
