//
//  SubscriptionManager.swift
//  HairStyle
//

import StoreKit
import SwiftUI

@MainActor
final class SubscriptionManager: ObservableObject {

    // MARK: – Published & constants -----------------------------------------
    @Published var subscriptions: [Product]          = []
    @Published var purchasedIdentifiers: Set<String> = []

    let previewThumbs: [ThumbItem] = []           // optional pay-wall preview

    // -------- Free-tier soft quota (persists) ------------------------------
    @Published private(set) var freeGenerationsUsed: Int {
        didSet {
            UserDefaults.standard.set(freeGenerationsUsed,
                                      forKey: "freeGenerationsUsed")
        }
    }
    let freeGenerationLimit = 1      // set to 0 if you want no free runs at all

    // -------- Throttle limits (all tiers) ----------------------------------
    private let perMinuteLimit = 2
    private let perHourLimit   = 10
    private let perDayLimit    = 50
    private let perWeekLimit   = 200

    // MARK: – Private state --------------------------------------------------
    /// Rolling log of completed generations (kept ≤7 days).
    private var generationLog: [Date] = []

    private let productIDs = ["weeksub"]
    private var updateTask: Task<Void, Never>?

    // MARK: – Init -----------------------------------------------------------
    init() {
        freeGenerationsUsed = UserDefaults.standard
            .integer(forKey: "freeGenerationsUsed")

        updateTask = listenForTransactions()
        Task {
            await requestProducts()
            await refreshEntitlements()
        }
    }

    // MARK: – Computed helpers ----------------------------------------------
    var isSubscribed: Bool {
        purchasedIdentifiers.contains("weeksub")
    }

    /// **true** if one more generation may start *right now*.
    var canGenerate: Bool {
        pruneLog()
        let now = Date()

        let perMinute = generationLog.filter { now.timeIntervalSince($0) <   60 }.count
        let perHour   = generationLog.filter { now.timeIntervalSince($0) < 3600 }.count
        let perDay    = generationLog.filter { now.timeIntervalSince($0) < 86_400 }.count
        let perWeek   = generationLog.count      // only last 7 days kept

        let underThrottle =
              perMinute < perMinuteLimit
          &&  perHour   < perHourLimit
          &&  perDay    < perDayLimit
          &&  perWeek   < perWeekLimit

        let underQuota =
              isSubscribed || freeGenerationsUsed < freeGenerationLimit

        return underThrottle && underQuota
    }

    /// Seconds until the *earliest* window frees up. `nil` ⇒ already allowed.
    var waitInterval: TimeInterval? {
        pruneLog()
        guard !canGenerate else { return nil }

        let now = Date()
        var waits: [TimeInterval] = []

        if generationLog.filter({ now.timeIntervalSince($0) <   60 }).count >= perMinuteLimit,
           let oldest = generationLog.min(by: { now.timeIntervalSince($0) < now.timeIntervalSince($1) }) {
            waits.append(max(0,   60 - now.timeIntervalSince(oldest)))
        }
        if generationLog.filter({ now.timeIntervalSince($0) < 3600 }).count >= perHourLimit,
           let oldest = generationLog.filter({ now.timeIntervalSince($0) < 3600 }).min() {
            waits.append(max(0, 3600 - now.timeIntervalSince(oldest)))
        }
        if generationLog.filter({ now.timeIntervalSince($0) < 86_400 }).count >= perDayLimit,
           let oldest = generationLog.filter({ now.timeIntervalSince($0) < 86_400 }).min() {
            waits.append(max(0, 86_400 - now.timeIntervalSince(oldest)))
        }
        if generationLog.count >= perWeekLimit,
           let oldest = generationLog.min() {
            waits.append(max(0, 604_800 - now.timeIntervalSince(oldest)))
        }
        return waits.min()
    }

    // MARK: – Public API -----------------------------------------------------
    /// Call **once** after each successful generation.
    func markGenerationUsed() {
        generationLog.append(Date())
        pruneLog()

        if !isSubscribed {
            freeGenerationsUsed += 1
        }
    }

    // MARK: – Log maintenance ------------------------------------------------
    private func pruneLog() {
        let cutoff = Date().addingTimeInterval(-604_800)   // 7 days
        generationLog.removeAll { $0 < cutoff }
    }

    // =======================================================================
    //  StoreKit plumbing (unchanged)
    // =======================================================================
    private func requestProducts() async {
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
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    // Verified helper
    private func verified<T>(_ vr: VerificationResult<T>) throws -> T {
        switch vr {
        case .verified(let val): return val
        case .unverified:        throw StoreError.failedVerification
        }
    }

    enum StoreError: Error { case failedVerification }
}
