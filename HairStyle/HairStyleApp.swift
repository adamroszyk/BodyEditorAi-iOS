//
//  HairStyleApp.swift
//  HairStyle
//
//  Created by Adam Roszyk on 3/19/25.
import SwiftUI

@main
struct HairStyleApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = true
    
    /// Create a single instance of SubscriptionManager
    @StateObject var subscriptionManager = SubscriptionManager()
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                CatalogView()
                    .environmentObject(subscriptionManager)
            } else {
                OnboardingView()
                    .environmentObject(subscriptionManager)
            }
        }
    }
}
