//
//  SubscriptionManager.swift
//  HairStyle
//

import StoreKit
import SwiftUI

@MainActor
final class SubscriptionManager: ObservableObject {
    
    // MARK:  Published
    @Published var subscriptions: [Product]          = []
    @Published var purchasedIdentifiers: Set<String> = []
    
    /// Optional thumbnails the paywall can show on first launch.
    /// `ThumbItem` is already declared in **GenView.swift**, so we just
    /// reference it here—no second definition!
    let previewThumbs: [ThumbItem] = []          // ← keep empty or fill later
    
    // MARK:  Private
    private let productIDs = ["weeksub"]
    private var updateTask: Task<Void, Never>?
    
    // MARK:  Init
    init() {
        updateTask = listenForTransactions()
        Task {
            await requestProducts()
            await refreshEntitlements()
        }
    }
}

// MARK: – StoreKit helpers
extension SubscriptionManager {
    
    func requestProducts() async {
        do {
            subscriptions = try await Product.products(for: productIDs)
        } catch {
            print("❌ StoreKit product request failed:", error)
        }
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            guard let self else { return }
            for await update in Transaction.updates {
                if let tx = try? await self.verified(update) {
                    await self.refreshEntitlements()
                    await tx.finish()
                }
            }
        }
    }
    
    private func refreshEntitlements() async {
        purchasedIdentifiers.removeAll()
        for await vr in Transaction.currentEntitlements {
            if let tx = try? verified(vr) {
                purchasedIdentifiers.insert(tx.productID)
            }
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        switch try await product.purchase() {
        case .success(let vr):
            let tx = try verified(vr)
            await tx.finish()
            await refreshEntitlements()
            return tx
        case .userCancelled, .pending: return nil
        @unknown default:              return nil
        }
    }
    
    // Helper to unwrap verified transactions / results
    private func verified<T>(_ vr: VerificationResult<T>) throws -> T {
        switch vr {
        case .verified(let val): return val
        case .unverified:        throw StoreError.failedVerification
        }
    }
    
    enum StoreError: Error { case failedVerification }
}
