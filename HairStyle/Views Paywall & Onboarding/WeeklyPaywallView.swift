import SwiftUI
import StoreKit

struct WeeklyPaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let thumbs: [ThumbItem]
    let onUnlock: () -> Void
    let onClose: () -> Void

    @State private var closeDisabled = true
    @State private var currentPage = 0

    private var weeklyProduct: Product? {
        subscriptionManager.subscriptions.first { $0.id == "weeksub" }
    }
    private var imageSize: CGFloat { UIScreen.main.bounds.width * 0.7 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // MARK: — Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red:1, green:0.95, blue:0.96),
                    Color(red:1, green:0.87, blue:0.90)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // MARK: — Close Button
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .opacity(closeDisabled ? 0.3 : 0.6)
                    .padding(24)
            }
            .disabled(closeDisabled)
            .contentShape(Rectangle())
            .zIndex(1)

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

                TabView(selection: $currentPage) {
                    ForEach(thumbs.indices, id: \.self) { idx in
                        if let ui = thumbs[idx].image {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageSize, height: imageSize)
                                .blur(radius: 7)
                                .mask(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 4)
                                )
                                .tag(idx)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: imageSize)

                HStack(spacing: 8) {
                    ForEach(0..<thumbs.count, id: \.self) { dot in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(dot == currentPage ? .black : .gray)
                    }
                }

                Text("1,000,000+ beauty upgrades created")
                    .font(.caption)
                    .foregroundColor(.gray)

                // MARK: — Unlock Button (white pill)
                Button(action: purchaseWeekly) {
                    Text("Unlock Now")
                        .font(.title3).bold()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 32)
                .disabled(weeklyProduct == nil)

                // MARK: — Renewal Info
                Text("Renews Weekly at \(weeklyProduct?.displayPrice ?? "–")")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()

                // MARK: — Footer Links
                HStack {
                    Button("Terms of Use")     { openURL("https://active-outcome.vercel.app/beautyCam") }
                    Spacer()
                    Button("Restore Purchase"){ Task { await restore() } }
                    Spacer()
                    Button("Privacy Policy")   { openURL("https://active-outcome.vercel.app/beautyCam") }
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.horizontal, 32)

                Spacer().frame(height: 20)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                withAnimation { closeDisabled = false }
            }
        }
    }

    private func purchaseWeekly() {
        guard let p = weeklyProduct else { return }
        Task {
            if (try? await subscriptionManager.purchase(p)) != nil {
                onUnlock()
            }
        }
    }

    private func restore() async {
        for await verification in Transaction.currentEntitlements {
            if case .verified(let t) = verification, t.productID == "weeksub" {
                onUnlock()
                break
            }
        }
    }

    private func openURL(_ s: String) {
        if let url = URL(string: s) {
            UIApplication.shared.open(url)
        }
    }
}
