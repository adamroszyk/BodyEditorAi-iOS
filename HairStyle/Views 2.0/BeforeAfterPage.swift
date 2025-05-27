//
//  BeforeAfterPage.swift
//  HairStyle
//

import SwiftUI

struct BeforeAfterPage: View {
    let transformation: Transformation
    let onContinue: () -> Void

    @State private var showAfter     = false
    @State private var hasInteracted = false

    // device check once
    private let isPhone = UIDevice.current.userInterfaceIdiom == .phone

    var body: some View {
        ZStack {
            // blurred background
            GeometryReader { proxy in
                Image(showAfter ? transformation.afterImageName
                                : transformation.beforeImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width,
                           height: proxy.size.height)
                    .clipped()
                    .blur(radius: 30)
            }

            // foreground image
            Image(showAfter ? transformation.afterImageName
                            : transformation.beforeImageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // caption + controls
            VStack {
                Spacer()

                Text(transformation.caption)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)                  // white caption everywhere
                    .shadow(color: .black, radius: 1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                VStack(spacing: 16) {
                    WideSegmentedToggle(isAfter: $showAfter, isPhone: isPhone)
                        .onChange(of: showAfter) { _ in
                            if !hasInteracted { hasInteracted = true }
                        }

                    // Continue pill
                    ZStack {
                        Color.clear.frame(height: 48)
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(
                                isPhone ? .white : Color.black.opacity(0.9)
                            )
                            .shadow(
                                color: isPhone ? .black : .clear,
                                radius: isPhone ? 1 : 0
                            )
                    }
                    .frame(maxWidth: .infinity,
                           minHeight: 48, maxHeight: 48)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                    .opacity(hasInteracted ? 1 : 0.3)          // fades whole pill
                    .onTapGesture { if hasInteracted { onContinue() } }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
    }
}

// ──────────────────────────────────────────────────────────────────
//  Toggle – receives `isPhone` to colour labels appropriately
// ──────────────────────────────────────────────────────────────────
struct WideSegmentedToggle: View {
    @Binding var isAfter: Bool
    var isPhone: Bool
    private let height: CGFloat = 48

    var body: some View {
        HStack(spacing: 0) {
            segment("Before", active: !isAfter) { isAfter = false }
            segment("After",  active:  isAfter) { isAfter = true  }
        }
        .frame(height: height)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: height / 2,
                                    style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        .animation(.easeInOut, value: isAfter)
    }

    private func segment(
        _ label: String,
        active: Bool,
        action: @escaping () -> Void
    ) -> some View {
        ZStack {
            Color.clear
            Text(label)
                .font(.headline.weight(.semibold))
                .foregroundColor(
                    isPhone ? .white : Color.black.opacity(0.9)
                )
                .opacity(isPhone && !active ? 0.6 : 1)        // 60 % on iPhone when inactive
                .shadow(
                    color: isPhone ? .black : .clear,
                    radius: isPhone ? 1 : 0
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: height / 2,
                             style: .continuous)
                .fill(active ? .regularMaterial : .ultraThinMaterial)
                .opacity(active ? 1 : 0.6)
        )
        .onTapGesture { withAnimation(.easeInOut) { action() } }
    }
}
