//
//  OnboardingFlowView.swift
//  HairStyle
//

import SwiftUI
import StoreKit
import UserNotifications

// ────────── Root onboarding flow ──────────
struct OnboardingFlowView: View {
    @AppStorage("hasCompletedOnboarding") private var done     = false
    @AppStorage("isPremium")              private var premium  = false
    
    @EnvironmentObject private var manager: SubscriptionManager
    @State private var page = 0
    // Convenience: number of Before→After screens
    private var extraStart: Int { onboardingTransformations.count }
    
    var body: some View {
        TabView(selection: $page) {
            
            // ── Before / After pages ───────────────────────────────
            ForEach(0..<onboardingTransformations.count, id: \.self) { idx in
                BeforeAfterPage(
                    transformation: onboardingTransformations[idx]
                ) { page += 1 }
                    .tag(idx)                    // 0,1,2,…
            }
            
            // ── Budget & Skill pages ───────────────────────────────
            BudgetPage { page += 1 }
                .tag(extraStart)             // N
            SkillPage  { page += 1 }
                .tag(extraStart + 1)         // N+1
            
            // ── Review page finishes the flow ─────────────────────
            ReviewPage { finish() }          // ← here!
                .tag(extraStart + 2)         // N+2
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
    
    private func finish() { done = true }
}

// MARK: – Gradient helper
 struct PinkGradient<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        LinearGradient(
            colors: [Color(red: 1, green: 0.95, blue: 0.96),
                     Color(red: 1, green: 0.87, blue: 0.90)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(content())
    }
}

// MARK: – Pill helper
private struct Pill: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.headline.weight(.semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .background(Color.white)
            .cornerRadius(26)
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: – Page 1 – Budget
private struct BudgetPage: View {
    let onContinue: () -> Void
    @State private var selection: String?

    private let opts: [(String,String)] = [("✨","Light"),("💄","Affordable"),("💰","High-end"),("🛍️","Elite")]

    var body: some View {
        PinkGradient {
            VStack(spacing: 40) {
                Spacer().frame(height: 60)

                Text("What's your\nbudget?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                VStack(spacing: 20) {
                    ForEach(opts, id:\.1) { em,txt in
                        Button {
                            selection = txt
                        } label: {
                            Pill(title: "\(em) \(txt)")
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(Color.black.opacity(selection == txt ? 0.4 : 0),
                                                lineWidth: 2)
                                )
                        }
                    }
                }

                Spacer()

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,18)
                        .background(Color.white)
                        .cornerRadius(32)
                }
                .padding(.horizontal,40)
                .opacity(selection == nil ? 0.3 : 1)
                .disabled(selection == nil)

                Spacer(minLength: 30)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: – Page 2 – Skills
private struct SkillPage: View {
    let onContinue: () -> Void
    @State private var selection: String?
    private let opts: [(String,String)] = [("🍃","Beginner"),("✨","Intermediate"),
                                           ("💄","Expert"),("🎨","Pro")]

    var body: some View {
        PinkGradient {
            VStack(spacing: 40) {
                Spacer().frame(height: 60)

                Text("How would you rate\nyour makeup skills?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                VStack(spacing:20) {
                    ForEach(opts, id:\.1) { em,txt in
                        Button { selection = txt } label: {
                            Pill(title:"\(em) \(txt)")
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(Color.black.opacity(selection == txt ? 0.4 : 0), lineWidth: 2)
                                )
                        }
                    }
                }

                Spacer()
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,18)
                        .background(Color.white)
                        .cornerRadius(32)
                }
                .padding(.horizontal,40)
                .opacity(selection == nil ? 0.3 : 1)
                .disabled(selection == nil)
                Spacer(minLength:30)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: – Page 3 – Social proof + Review
private struct ReviewPage: View {
    let onContinue: () -> Void
    var body: some View {
        PinkGradient {
            VStack(spacing:32) {
                Spacer().frame(height:60)

                Text("Trusted by Over\n1 Million People!")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Image(systemName:"kiss.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width:200)
                    .foregroundColor(.pink)
                    .padding(.vertical,10)

                HStack(spacing:4) { ForEach(0..<5){_ in Image(systemName:"star.fill")} }
                    .font(.largeTitle)
                    .foregroundColor(.yellow)

                Spacer()
                Button {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                    onContinue()
                } label: {
                    Text("Leave a Review! 🥰")
                        .font(.headline)
                        .frame(maxWidth:.infinity)
                        .padding(.vertical,18)
                        .background(Color.white)
                        .cornerRadius(32)
                }
                .padding(.horizontal,40)
                Spacer(minLength:30)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: – Page 4 – Notification permission
private struct NotifyPage: View {
    let onContinue: () -> Void
    @State private var requesting = false

    var body: some View {
        PinkGradient {
            VStack(spacing:32) {
                Spacer().frame(height:60)

                Text("Allow Notifications")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Image(systemName:"app.badge.fill")
                    .resizable().scaledToFit()
                    .frame(width:180)
                    .foregroundColor(.pink)

                Spacer()
                Button {
                    requesting = true
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert,.sound,.badge]) { _,_ in
                            DispatchQueue.main.async {
                                requesting = false
                                onContinue()
                            }
                        }
                } label: {
                    Text("Enable notifications! 🥰")
                        .font(.headline)
                        .frame(maxWidth:.infinity)
                        .padding(.vertical,18)
                        .background(Color.white)
                        .cornerRadius(32)
                }
                .padding(.horizontal,40)
                .opacity(requesting ? 0.5 : 1)
                .disabled(requesting)
                Spacer(minLength:30)
            }
            .padding(.horizontal)
        }
    }
}
