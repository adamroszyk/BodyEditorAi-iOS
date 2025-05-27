//
//  WeeklyPaywallView.swift
//  HairStyle
//

import SwiftUI
import StoreKit

struct WeeklyPaywallView: View {
    
    // MARK: – Dependencies
    @EnvironmentObject private var manager: SubscriptionManager
    
    // MARK: – Inputs
    var thumbs: [ThumbItem] = []            // OPTIONAL – default empty
    let onUnlock: () -> Void
    let onClose:  () -> Void
    
    // MARK: – Local state
    @State private var closeDisabled = true
    @State private var currentPage   = 0
    @State private var bounceOffset: CGFloat  = 0
    @State private var hasBounced    = false
    @State private var buttonScale:  CGFloat  = 1
    
    // MARK: – Derived
    private var weeklyProduct: Product? {
        manager.subscriptions.first { $0.id == "weeksub" }
    }
    private var imageSize: CGFloat { UIScreen.main.bounds.width * 0.7 }
    
    // MARK: – Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            background
            closeButton
            content
        }
        .onAppear(perform: configureAnimations)
    }
}

// MARK: - Sub-views
private extension WeeklyPaywallView {
    
    var background: some View {
        LinearGradient(
            colors: [
                Color(red: 1, green: 0.95, blue: 0.96),
                Color(red: 1, green: 0.87, blue: 0.90)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black)
                .opacity(closeDisabled ? 0.3 : 0.6)
                .padding(24)
        }
        .disabled(closeDisabled)
    }
    
    var content: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 60)
            
            // MARK: — Headline (no truncation)
            Text("GET YOUR DREAM APPEARANCE!")
                .font(.largeTitle).bold()
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("Proven to help you transform your beauty routine.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 32)

            // MARK: — Carousel & Dots
            Text("Reveal what you'll look like 👀")
                .font(.headline)
                .foregroundColor(.black)
            
            if !thumbs.isEmpty { carouselSection }
            
            Text("1,000,000+ beauty upgrades created")
                .font(.caption)
                .foregroundColor(.gray)
            
            unlockButton
                .padding(.horizontal, 32)
            
            renewalInfo
            
            Spacer()
            
            footer
                .padding(.horizontal, 32)
            
            Spacer(minLength: 20)
        }
    }
    
    // ---------- optional carousel ----------
    @ViewBuilder
    var carouselSection: some View {
        
        TabView(selection: $currentPage) {
            ForEach(thumbs.indices, id: \.self) { idx in
                if let ui = thumbs[idx].image {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .blur(radius: 6.5)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.6), lineWidth: 4)
                        )
                        .offset(x: idx == 0 ? bounceOffset : 0)
                        .tag(idx)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: imageSize)
        
        HStack(spacing: 8) {
            ForEach(0..<thumbs.count, id: \.self) { d in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(d == currentPage ? .black : .gray)
            }
        }
    }
    
    // ---------- CTA ----------
    var unlockButton: some View {
        Button(action: purchase) {
            Text("Unlock Now")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(30)
                .foregroundColor(.black)              // always black
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .disabled(weeklyProduct == nil)
        .scaleEffect(buttonScale)
    }
    
    var renewalInfo: some View {
        (Text("Renews Weekly at ")
         + Text(weeklyProduct?.displayPrice ?? "–")
            .bold()
            .foregroundColor(.black))
        .font(.callout)
        .foregroundColor(.gray)
    }
    
    var footer: some View {
        HStack {
            Button("Terms of Use") { openURL("https://active-outcome.vercel.app/BodyEditorAi#terms-of-use") }
            Spacer()
            Button("Restore Purchase") { Task { await restore() } }
            Spacer()
            Button("Privacy Policy") { openURL("https://active-outcome.vercel.app/BodyEditorAi#privacy-policy") }
        }
        .font(.footnote)
        .foregroundColor(.gray)
    }
}

// MARK: - Logic
private extension WeeklyPaywallView {
    
    func configureAnimations() {
        // unlock × after 9 s
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
            withAnimation { closeDisabled = false }
        }
        
        // carousel nudge
        if !thumbs.isEmpty && !hasBounced {
            hasBounced = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.28)) { bounceOffset = -16 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                    withAnimation(.interpolatingSpring(stiffness: 220, damping: 18)) { bounceOffset = 0 }
                }
            }
        }
        
        // CTA pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            withAnimation(.easeInOut(duration: 0.4)) { buttonScale = 1.1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.4)) { buttonScale = 1.0 }
            }
        }
    }
    
    func purchase() {
        guard let p = weeklyProduct else { return }
        Task {
            if (try? await manager.purchase(p)) != nil { onUnlock() }
        }
    }
    
    func restore() async {
        for await v in Transaction.currentEntitlements {
            if case let .verified(t) = v, t.productID == "weeksub" { onUnlock(); break }
        }
    }
    
    func openURL(_ s: String) {
        guard let url = URL(string: s) else { return }
        UIApplication.shared.open(url)
    }
}
