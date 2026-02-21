//
//  OnboardingPaywallView.swift
//  HairStyle
//

import SwiftUI
import StoreKit

struct OnboardingPaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Binding var isPremium: Bool
    let onComplete: () -> Void

    @State private var buttonScale: CGFloat = 1
    @State private var notNowLocked = true
    @State private var animateBenefits = false

    // Detect iPad once, reuse
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad

    // MARK: – StoreKit
    private var weeklyProduct: Product? {
        subscriptionManager.subscriptions.first { $0.id == "weeksub" }
        ?? subscriptionManager.subscriptions.first
    }

    // MARK: – Gary Vee Style Benefits
    private let benefits: [(String, String, String)] = [
        ("🚀", "STOP BEING AVERAGE", "Stop settling for mediocre photos. Your social media deserves to be FIRE."),
        ("💪", "BUILD UNSTOPPABLE CONFIDENCE", "When you look your best, you feel your best. Period."),
        ("🔥", "BECOME THE MAIN CHARACTER", "Stop being a background player in your own life story."),
        ("⚡", "INSTANT RESULTS, ZERO EXCUSES", "No more waiting, no more procrastination. Transform yourself NOW."),
        ("💎", "PREMIUM QUALITY, PREMIUM YOU", "You're not basic, so why settle for basic editing tools?")
    ]

    // MARK: – Body
    var body: some View {
        ZStack {
            // ─── Background ─────────────────
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: isPad ? 40 : 28) {
                    Spacer().frame(height: isPad ? 80 : 60)

                    // ─── HEADLINE ─────────────────
                    VStack(spacing: 16) {
                        Text("WAKE UP CALL")
                            .font(.system(size: isPad ? 48 : 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 3, x: 0, y: 2)
                        
                        Text("Your Photos Are Holding You Back")
                            .font(.system(size: isPad ? 24 : 18, weight: .bold))
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black, radius: 2)
                    }
                    .padding(.horizontal, 32)

                    // ─── BENEFITS SECTION ─────────────────
                    VStack(spacing: isPad ? 24 : 16) {
                        ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                            BenefitCard(
                                icon: benefit.0,
                                title: benefit.1,
                                description: benefit.2,
                                isPad: isPad,
                                delay: Double(index) * 0.2
                            )
                            .opacity(animateBenefits ? 1 : 0)
                            .offset(y: animateBenefits ? 0 : 50)
                        }
                    }
                    .padding(.horizontal, 32)

                    // ─── SOCIAL PROOF ─────────────────
                    VStack(spacing: 12) {
                        Text("🔥 50,000+ PEOPLE ALREADY TRANSFORMED")
                            .font(.system(size: isPad ? 18 : 14, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                        
                        Text("Join the movement. Stop being average.")
                            .font(.system(size: isPad ? 16 : 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 32)

                    Spacer().frame(height: 40)

                    // ─── BOTTOM PANEL ─────────────────
                    bottomPanel
                        .frame(maxWidth: isPad ? 600 : .infinity)
                        .padding(.horizontal, isPad ? 0 : 32)
                        .padding(.bottom, isPad ? 60 : 40)
                }
            }
        }
        .onAppear {
            schedulePulse()
            animateBenefitsIn()
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation { notNowLocked = false }
            }
        }
    }
}

// MARK: – Benefit Card
struct BenefitCard: View {
    let icon: String
    let title: String
    let description: String
    let isPad: Bool
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            Text(icon)
                .font(.system(size: isPad ? 32 : 24))
                .frame(width: isPad ? 50 : 40, height: isPad ? 50 : 40)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                        )
                )
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: isPad ? 18 : 14, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1)
                
                Text(description)
                    .font(.system(size: isPad ? 16 : 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(isPad ? 20 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                isVisible = true
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
    }
}

// MARK: – Bottom panel
private extension OnboardingPaywallView {

    var bottomPanel: some View {
        VStack(spacing: isPad ? 22 : 16) {

            // ─── CTA BUTTON ─────────────────
            Button(action: purchase) {
                VStack(spacing: 8) {
                    Text("UNLOCK PREMIUM NOW")
                        .font(.system(size: isPad ? 20 : 16, weight: .black))
                        .foregroundColor(.white)
                    
                    Text("3-Day FREE Trial • Cancel Anytime")
                        .font(.system(size: isPad ? 14 : 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .frame(height: isPad ? 70 : 60)
                .background(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(isPad ? 35 : 30)
                .shadow(color: .orange.opacity(0.5), radius: 15, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(weeklyProduct == nil)
            .scaleEffect(buttonScale)

            // ─── PRICE INFO ─────────────────
            if let price = weeklyProduct?.displayPrice {
                VStack(spacing: 4) {
                    Text("Then just \(price) per week")
                        .font(.system(size: isPad ? 16 : 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Less than a coffee per week for unlimited confidence")
                        .font(.system(size: isPad ? 12 : 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }

            // ─── LINKS ─────────────────
            HStack {
                Button("Terms") { openURL("https://active-outcome.vercel.app/BodyEditorAi#terms-of-use") }
                Spacer()
                Button("Restore") { Task { await restore() } }
                Spacer()
                Button("Privacy") { openURL("https://active-outcome.vercel.app/BodyEditorAi#privacy-policy") }
            }
            .font(.system(size: isPad ? 14 : 12, weight: .medium))
            .foregroundColor(.white.opacity(0.8))

            // ─── NOT NOW BUTTON ─────────────────
            Button("Maybe Later", action: onComplete)
                .font(.system(size: isPad ? 16 : 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .opacity(notNowLocked ? 0.3 : 1)
                .disabled(notNowLocked)
        }
        .padding(isPad ? 28 : 20)
        .background(
            RoundedRectangle(cornerRadius: isPad ? 32 : 28)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: isPad ? 32 : 28)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
    }
}

// MARK: – Logic
private extension OnboardingPaywallView {

    func schedulePulse() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation(.easeInOut(duration: 0.4)) { buttonScale = 1.05 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.4)) { buttonScale = 1.0 }
            }
        }
    }

    func animateBenefitsIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                animateBenefits = true
            }
        }
    }

    func purchase() {
        guard let product = weeklyProduct else { return }
        Task {
            if let _ = try? await subscriptionManager.purchase(product) {
                isPremium = true
                onComplete()
            }
        }
    }

    func restore() async {
        for await ent in Transaction.currentEntitlements {
            if case let .verified(t) = ent, t.productID == weeklyProduct?.id {
                isPremium = true
                onComplete()
                break
            }
        }
    }

    func openURL(_ s: String) {
        guard let url = URL(string: s) else { return }
        UIApplication.shared.open(url)
    }
} 