import SwiftUI

@main
struct HairStyleApp: App {
    /// Marks whether the user has seen the forced demo
    @AppStorage("hasSeenDemo") private var hasSeenDemo: Bool = false

    @StateObject private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
                CatalogView()
                    .environmentObject(subscriptionManager)
        }
    }
}
