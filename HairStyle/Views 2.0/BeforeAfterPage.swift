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
                    .blur(radius: 15)
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
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3, x: 0, y: 2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)

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
                                radius: isPhone ? 2 : 0
                            )
                    }
                    .frame(maxWidth: .infinity,
                           minHeight: 48, maxHeight: 48)
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                    )
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
                    .opacity(hasInteracted ? 1 : 0.3)          // fades whole pill
                    .onTapGesture { if hasInteracted { onContinue() } }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.35), radius: 14, y: 7)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
    }
}

// ──────────────────────────────────────────────────────────────────
//  Custom Animated Toggle – inspired by the example
// ──────────────────────────────────────────────────────────────────
struct WideSegmentedToggle: View {
    @Binding var isAfter: Bool
    var isPhone: Bool
    private let height: CGFloat = 48
    private let width: CGFloat = 200

    var body: some View {
        ZStack {
            // Main background capsule
            Capsule()
                .fill(.ultraThinMaterial)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: width, height: height)
                .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
            
            // Animated slider that moves between Before and After
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: width/2 - 4, height: height - 6)
                .offset(x: isAfter ? width/4 : -width/4)
                .animation(.easeOut(duration: 0.3), value: isAfter)
            
            // Text labels
            HStack(spacing: 0) {
                Text("Before")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2)
                    .frame(width: width/2, height: height)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isAfter = false
                        }
                    }
                
                Text("After")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2)
                    .frame(width: width/2, height: height)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isAfter = true
                        }
                    }
            }
        }
        .frame(width: width, height: height)
    }
}
