//
//  PaywallPageView.swift
//  HairStyle
//
//  Created by adam on 25/03/2025.
//


import SwiftUI
import StoreKit

struct PaywallPageView: View {
    /// We get the subscription manager from the environment
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    /// This is your old @AppStorage property that indicates premium status
    @Binding var isPremium: Bool
    
    /// Called when user finishes this screen (either purchase or “Not Now”)
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Upgrade to Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Unlock unlimited image edits. Choose your plan below:")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if subscriptionManager.subscriptions.isEmpty {
                // If the products haven't loaded yet, show a spinner
                ProgressView("Loading subscriptions...")
                    .padding()
            } else {
                // Show each subscription product
                ForEach(subscriptionManager.subscriptions) { product in
                    Button {
                        Task {
                            do {
                                // Attempt to purchase
                                let transaction = try await subscriptionManager.purchase(product)
                                if transaction != nil {
                                    // Purchase successful
                                    isPremium = true
                                    onComplete()
                                }
                            } catch {
                                print("Purchase failed: \(error)")
                            }
                        }
                    } label: {
                        // Display the product’s name and price from StoreKit
                        Text("\(product.displayName) – \(product.displayPrice)")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            
            Button(action: {
                // "Not Now" – continue as freemium (limited to 3 generations)
                onComplete()
            }) {
                Text("Not Now")
                    .underline()
                    .foregroundColor(.gray)
            }
            Button(action: {
                if let url = URL(string: "https://example.com/terms") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Terms of Service")
                    .underline()
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}
