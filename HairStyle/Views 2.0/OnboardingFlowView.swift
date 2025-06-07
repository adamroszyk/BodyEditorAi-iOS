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
    /// Convenience: number of Before→After screens
    private var extraStart: Int { onboardingTransformations.count }
    
    var body: some View {
        TabView(selection: $page) {
            // ── Before / After pages ───────────────────────────
            ForEach(0..<onboardingTransformations.count, id: \.self) { idx in
                BeforeAfterPage(
                    transformation: onboardingTransformations[idx]
                ) { page += 1 }
                    .tag(idx)               // 0,1,2,…
            }

            ReviewPage { page += 1 }        // tag N
                .tag(extraStart)

            BudgetPage { page += 1 }        // tag N+1
                .tag(extraStart + 1)

            // SkillPage *no longer* finishes the flow – it just advances
            SkillPage {  done = true }        // call finish() afterwards
                     // tag N+2
                .tag(extraStart + 2)


            /*// 🔑 NEW – Paywall right after the skill page
              PaywallPageView(
                  isPremium: $premium,        // bind to @AppStorage
                  onComplete: finish          // call finish() afterwards
              )
              .tag(extraStart + 3)
             */
            // Optional: uncomment NotifyPage if you still need it
            // NotifyPage { finish() }
            //     .tag(extraStart + 4)
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

/// A reusable dark mesh-gradient background that you can
/// overlay with any content.
struct DarkMeshGradient<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            // --- Mesh: 3×3 grid, 9 control points --------------
            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        .init(0.00, 0.00), .init(0.50, 0.00), .init(1.00, 0.00),
                        .init(0.00, 0.50), .init(0.50, 0.50), .init(1.00, 0.50),
                        .init(0.00, 1.00), .init(0.50, 1.00), .init(1.00, 1.00)
                    ],
                    
                    // Subtle dark palette –- corners almost black,
                    // mid-tones get a touch of indigo / teal.
                    colors: [
                        .black,                     Color(hex: 0x10121A),       .black,
                        Color(hex: 0x06070C),       Color(hex: 0x1A1C27),       Color(hex: 0x0E1119),
                        .black,                     Color(hex: 0x121726),       .black
                    ]
                )
                // A big blur softens the colour transitions so you
                // don’t see obvious “patches” from the mesh cells.
                .blur(radius: 80)
            } else {
                // Fallback on earlier versions
            }
            
            // Faint angular sweep = a hint of depth / vignette.
            AngularGradient(
                colors: [.clear, .white.opacity(0.05), .clear],
                center: .center
            )
            .blendMode(.overlay)
        }
        .ignoresSafeArea()
        .overlay(content())          // your foreground
    }
}

// MARK: - Small colour helper
extension Color {
    /// Initialise `Color` with 24-bit hex, e.g. `0x1A2B3C`
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >>  8) & 0xff) / 255,
                  blue:  Double( hex        & 0xff) / 255,
                  opacity: opacity)
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
// MARK: – Page – Usage volume
private struct BudgetPage: View {
    let onContinue: () -> Void
    @State private var selection: String?
    
    /// Options deliberately steer frequent editors to Premium
    private let opts: [(String,String)] = [
        ("📷", "1–2 photos / week "),
        ("⚡️", "Up to 15 edits / week "),
        ("💎", "Unlimited edits")
    ]
    
    var body: some View {
        DarkMeshGradient {
            VStack(spacing: 42) {
                Spacer().frame(height: 60)
                
                Text("How many photos\nwill you **perfect** every week?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 22) {
                    ForEach(opts, id:\.1) { em, txt in
                        Button { selection = txt } label: {
                            Pill(title: "\(em)  \(txt)")
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(Color.yellow.opacity(selection == txt ? 0.8 : 0),
                                                lineWidth: 2)
                                )
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onContinue) {
                    Text(selection?.contains("Premium") == true
                         ? "Unlock AI Power →"
                         : "Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(32)
                }
                .padding(.horizontal, 40)
                .opacity(selection == nil ? 0.3 : 1)
                .disabled(selection == nil)
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal)
        }
    }
}


// MARK: – Page – Editing power level
private struct SkillPage: View {
    let onContinue: () -> Void
    @State private var selection: String?
    
    private let opts: [(String,String)] = [
        ("🙂", "Basic smoothing"),
        ("💪", "Shape & Slim"),
        ("🔥", "Full Body Makeover"),
        ("❤️", "4K full picture edits")
    ]
    
    var body: some View {
        DarkMeshGradient {
            VStack(spacing: 42) {
                Spacer().frame(height: 60)
                
                Text("Choose your\nediting **power level**")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 22) {
                    ForEach(opts, id:\.1) { em, txt in
                        Button { selection = txt } label: {
                            Pill(title: "\(em)  \(txt)")
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(Color.yellow.opacity(selection == txt ? 0.8 : 0),
                                                lineWidth: 2)
                                )
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onContinue) {
                    Text(selection?.contains("Premium") == true
                         ? "Continue →"
                         : "Finish")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(32)
                }
                .padding(.horizontal, 40)
                .opacity(selection == nil ? 0.3 : 1)
                .disabled(selection == nil)
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal)
        }
    }
}


private struct ReviewPage: View {
    let onContinue: () -> Void
    
    var body: some View {
        DarkMeshGradient {        // ⬅️ new gradient
            VStack(spacing: 36) {
                Spacer().frame(height: 60)
                
                Text("Enjoying HairStyle?")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Keep stunning looks coming – a quick **5-star** rating helps us add more styles for you!")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.yellow)
                        }
                    }
                    Text("5 / 5")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.yellow)
                }
                .shadow(radius: 4)
                
                Spacer()
                
                Button {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                    onContinue()
                } label: {
                    Text("Rate 5 Stars ⭐️")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(32)
                }
                .padding(.horizontal, 40)
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal)
        }
    }
}


// MARK: – Page – Notification permission (FINISH)
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
