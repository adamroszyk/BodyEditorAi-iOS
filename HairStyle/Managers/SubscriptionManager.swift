//
//  SubscriptionManager.swift
//  HairStyle
//
//  Created by adam on 25/03/2025.
//


import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    /// The subscription products fetched from StoreKit configuration
    @Published var subscriptions: [Product] = []
    
    /// Keep track of purchased product identifiers
    @Published var purchasedIdentifiers = Set<String>()
    
    /// Task to listen for any subscription updates
    private var updates: Task<Void, Never>?
    
    /// Define your product IDs exactly as they appear in your StoreKit config
    private let productIDs = [
        "wbweek",  // replace with your actual weekly ID
        "wbyear"   // replace with your actual annual ID
    ]
    
    init() {
        // Start listening for transaction updates
        updates = listenForTransactions()
        
        // Immediately fetch products and update purchased info
        Task {
            await requestProducts()
            await updatePurchasedIdentifiers()
        }
    }
    
    /// Request products from StoreKit
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            subscriptions = storeProducts
        } catch {
            print("Failed to request products: \(error)")
        }
    }
    
    /// Listen for any transaction updates (e.g., renewals, cancellations)
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            guard let self = self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    // If transaction is verified, apply changes
                    await self.updatePurchasedIdentifiers()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    /// Update purchased identifiers from current entitlements
    private func updatePurchasedIdentifiers() async {
        purchasedIdentifiers.removeAll()
        for await verificationResult in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(verificationResult)
                purchasedIdentifiers.insert(transaction.productID)
            } catch {
                // Not verified
            }
        }
    }
    
    /// Purchase a specific product
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedIdentifiers()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    /// Verify the transaction with StoreKit
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    enum StoreError: Error {
        case failedVerification
    }
}
