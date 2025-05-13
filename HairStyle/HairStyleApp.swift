import SwiftUI
@main
struct HairStyleApp: App {
    @AppStorage("hasSeenDemo")            private var hasSeenDemo            = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                CatalogView()
                    .environmentObject(subscriptionManager)
            } else {
                OnboardingFlowView()          // ← new flow
                    .environmentObject(subscriptionManager)
            }
        }
    }
}
