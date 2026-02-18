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
    
    private var updates: Task<Void, Never>? = nil

    private init() {
        // Observe transaction updates as they happen
        updates = Task.detached {
            for await result in Transaction.updates {
                await self.handle(transactionVerification: result)
            }
        }
    }

    deinit {
        updates?.cancel()
    }

    // MARK: - Fetch Products
    func fetchProducts(productIDs: Set<String>) async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
            print("Successfully fetched \(self.products.count) products from StoreKit 2")
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Transaction? {
        purchaseState = .loading
        
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                purchaseState = .idle
                return transaction
            case .userCancelled:
                purchaseState = .failed("User cancelled the payment process.")
                return nil
            case .pending:
                purchaseState = .loading
                return nil
            @unknown default:
                purchaseState = .failed("An unexpected error occurred.")
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

        // CurrentEntitlements contains all active subscriptions and non-consumables
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedIDs.insert(transaction.productID)
            }
        }

        self.purchasedProductIDs = purchasedIDs
    }

    // MARK: - Restore Purchases
    func restorePurchases() async throws {
        purchaseState = .loading
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            purchaseState = .idle
        } catch {
            purchaseState = .failed(error.localizedDescription)
            throw error
        }
    }

    // MARK: - Helper Methods
    private func handle(transactionVerification result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            await updatePurchasedProducts()
            await transaction.finish()
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
}
