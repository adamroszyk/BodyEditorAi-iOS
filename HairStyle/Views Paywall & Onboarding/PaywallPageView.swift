//
//  PaywallPageView.swift
//  HairStyle
//

import SwiftUI
import StoreKit

struct PaywallPageView: View {

    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Binding var isPremium: Bool
    let onComplete: () -> Void

    @State private var buttonScale: CGFloat = 1
    @State private var notNowLocked     = true

    // Detect iPad once, reuse
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad

    // MARK: – StoreKit
    private var weeklyProduct: Product? {
        subscriptionManager.subscriptions.first { $0.id == "weeksub" }
        ?? subscriptionManager.subscriptions.first
    }

    // MARK: – Copy
    private let perks: [(String,String)] = [
        ("🤳", "AI Photo Retake – perfect every snap"),
        ("🔥", "Body Tuner for true confidence"),
        ("✨", "Instant Skin Retouch & Glow"),
        ("🧽", "Erase unwanted objects"),
        ("💎", "4 K HD exports, watermark-free")
    ]

    // MARK: – Body
    var body: some View {
        ZStack {
            // ─── Background (darker on iPad) ─────────────────
            LinearGradient(
                colors: isPad
                    ? [Color(red:0.66, green:0.13, blue:0.32),   // much deeper top
                       Color(red:0.49, green:0.06, blue:0.24)]   // deeper bottom
                    : [Color(red:1,green:0.95,blue:0.96),
                       Color(red:1,green:0.87,blue:0.90)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // ─── Main stack ─────────────────────────────────
            VStack(spacing: isPad ? 40 : 28) {

                Spacer().frame(height: isPad ? 120 : 72)

                // Headline
                Text("Unlock Your Best Look\nToday")
                    .font(isPad ? .system(size:60, weight:.heavy)
                                 : .largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black, radius: 2)

                // Perks card
                VStack(alignment:.leading, spacing:isPad ? 18 : 12) {
                    ForEach(perks, id:\.1) { em, txt in
                        HStack(spacing:12) { Text(em); Text(txt) }
                    }
                }
                .font(isPad ? .title3.weight(.semibold)
                            : .callout.weight(.semibold))
                .foregroundColor(.white)
                .padding(isPad ? 30 : 20)
                .background(.black.opacity(0.3))
                .cornerRadius(24)
                .frame(maxWidth: isPad ? 520 : .infinity)
                .padding(.horizontal,isPad ? 0 : 32)

                // Free-trial badge
                Text("3-Day **FREE** Trial – cancel anytime")
                    .font(isPad ? .callout.weight(.medium) : .footnote.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal,24)
                    .padding(.vertical,8)
                    .background(Color.white.opacity(0.18))
                    .cornerRadius(16)

                Spacer()

                // Bottom panel
                bottomPanel
                    .frame(maxWidth: isPad ? 600 : .infinity)
                    .padding(.horizontal,isPad ? 0 : 32)
                    .padding(.bottom,isPad ? 60 : 40)
            }
        }
        .onAppear {
            schedulePulse()
            DispatchQueue.main.asyncAfter(deadline: .now()+12) {
                withAnimation { notNowLocked = false }
            }
        }
    }
}

// MARK: – Bottom panel
private extension PaywallPageView {

    var bottomPanel: some View {
        VStack(spacing:isPad ? 22 : 16) {

            // CTA
            Button(action: purchase) {
                Text("Start Free Trial")
                    .font(isPad ? .title3.weight(.semibold) : .headline)
                    .frame(maxWidth:.infinity)
                    .frame(height:isPad ? 56 : 48)
                    .background(
                        isPad ? AnyShapeStyle(Color.white)
                              : AnyShapeStyle(.ultraThinMaterial)
                    )
                    .foregroundColor(isPad ? .black : .white)
                    .cornerRadius(isPad ? 28 : 24)
            }
            .buttonStyle(.plain)
            .background(.ultraThinMaterial)
            .cornerRadius(isPad ? 28 : 24)
            .shadow(color:.black.opacity(0.3), radius:10, y:5)
            .disabled(weeklyProduct == nil)
            .scaleEffect(buttonScale)

            // Renewal price
            if let price = weeklyProduct?.displayPrice {
                (Text("Then ") + Text(price).bold() + Text(" / week, cancel anytime"))
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
            }

            // Links
            HStack {
                Button("Terms")   { openURL("https://active-outcome.vercel.app/BodyEditorAi#terms-of-use") }
                Spacer()
                Button("Restore") { Task { await restore() } }
                Spacer()
                Button("Privacy") { openURL("https://active-outcome.vercel.app/BodyEditorAi#privacy-policy") }
            }
            .font(.footnote)
            .foregroundColor(.white.opacity(0.85))

            // Not-now
            Button("Not Now", action: onComplete)
                .font(.footnote)
                .foregroundColor(.white)
                .opacity(notNowLocked ? 0.3 : 1)
                .disabled(notNowLocked)
        }
        .padding(isPad ? 28 : 20)
        .background(
            isPad
                ? Color.black.opacity(0.45)      // dark, contrasty
            : .clear               // iPhone unchanged
        )
        .cornerRadius(isPad ? 32 : 28)
        .shadow(color:.black.opacity(0.35), radius:14, y:6)
    }
}

// MARK: – Logic
private extension PaywallPageView {

    func schedulePulse() {
        DispatchQueue.main.asyncAfter(deadline:.now()+7) {
            withAnimation(.easeInOut(duration:0.4)) { buttonScale = 1.1 }
            DispatchQueue.main.asyncAfter(deadline:.now()+0.4) {
                withAnimation(.easeInOut(duration:0.4)) { buttonScale = 1.0 }
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

    func openURL(_ s:String) {
        guard let url = URL(string:s) else { return }
        UIApplication.shared.open(url)
    }
}
