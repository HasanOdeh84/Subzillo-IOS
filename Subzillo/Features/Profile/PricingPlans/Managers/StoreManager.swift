//
//  StoreManager.swift
//  Subzillo
//
//  Created by Antigravity on 17/02/26.
//

import Foundation
import StoreKit

enum StorePurchaseState: Equatable {
    case idle
    case loading
    case failed(String)
}

@MainActor
class StoreManager: ObservableObject {
    
    static let shared = StoreManager()
    
    @Published var purchaseState: StorePurchaseState = .idle
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published private(set) var currentActiveProductID: String?
    
    private var updates: Task<Void, Never>? = nil
    
    private init() {
        updates = Task {
            for await result in Transaction.updates {
                await handle(transactionVerification: result)
            }
        }
        
        Task {
            await updatePurchasedProducts()
            await sweepUnfinishedTransactions()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Fetch Products
    func fetchProducts(productIDs: Set<String>) async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            //            self.products = fetchedProducts.sorted(by: { $0.price < $1.price }) //Price sorting sometimes wrong hierarchy create chesthundi if yearly cheaper per month.
            self.products = fetchedProducts
            print("Successfully fetched \(self.products.count) products from StoreKit 2")
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Transaction? {
        print("StoreManager: purchase(_:) called for \(product.id)")
        purchaseState = .loading
        do {
            print("StoreManager: Executing product.purchase()...")
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                purchaseState = .idle
                return transaction
            case .userCancelled:
                purchaseState = .idle
                return nil
            case .pending:
                purchaseState = .loading
                return nil
            @unknown default:
                purchaseState = .idle
                return nil
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()
        var activeID: String?
        var latestExpiration: Date?
        
        for await result in Transaction.currentEntitlements {
            
            if case .verified(let transaction) = result {
                
                purchasedIDs.insert(transaction.productID)
                
                if transaction.productType == .autoRenewable &&
                    transaction.revocationDate == nil {
                    
                    if let expiration = transaction.expirationDate,
                       expiration > Date() {
                        
                        if latestExpiration == nil || expiration > latestExpiration! {
                            latestExpiration = expiration
                            activeID = transaction.productID
                        }
                    }
                }
            }
        }
        self.purchasedProductIDs = purchasedIDs
        self.currentActiveProductID = activeID
    }
    
    // MARK: - Restore Purchases
    func restorePurchases(
        onRestoredTransactions: ([(productID: String, transactionId: String, transaction: Transaction)]) -> Void = { _ in }
    ) async throws {
        purchaseState = .loading
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            purchaseState = .idle
            
            // Collect all currently active verified entitlements
            var restoredEntitlements: [(productID: String, transactionId: String, transaction: Transaction)] = []
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    restoredEntitlements.append((
                        productID     : transaction.productID,
                        transactionId : String(transaction.id),
                        transaction   : transaction
                    ))
                }
            }
            if !restoredEntitlements.isEmpty {
                onRestoredTransactions(restoredEntitlements)
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - Transaction Sweep
    /// Proactively finishes any verified transactions that might be stuck in the unfinished queue.
    /// This is a "safety net" to clear blockers like the one skipping the payment sheet.
    func sweepUnfinishedTransactions() async {
        var sweepCount = 0
        for await result in Transaction.unfinished {
            if case .verified(let transaction) = result {
                await transaction.finish()
                sweepCount += 1
            }
        }
        if sweepCount > 0 {
            await updatePurchasedProducts()
        }
    }
    
    // MARK: - Helper Methods
    private func handle(transactionVerification result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            // Transctions are now finished in PricingPlansViewModel after back-end sync success.
            // This ensures we don't finish the transaction if the back-end hasn't registered the purchase.
            // await transaction.finish()
            await updatePurchasedProducts()
        case .unverified:
            // Handle unverified transaction (e.g., skip or show error)
            break
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    func checkActiveSubscription() async -> Bool {
        //        await updatePurchasedProducts()
        return currentActiveProductID != nil
    }
    
    func refreshEntitlementsFromAppStore() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    func initializeStore() {
        Task {
            await updatePurchasedProducts()
        }
    }
}

