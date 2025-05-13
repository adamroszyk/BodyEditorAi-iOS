//
//  BeforeAfterPage.swift
//  HairStyle
//
//  Created by adam on 12/05/2025.
//


//
//  BeforeAfterPage.swift
//

import SwiftUI

struct BeforeAfterPage: View {
    let transformation: Transformation
    let onContinue: () -> Void
    
    @State private var showAfter      = false
    @State private var hasInteracted  = false   // ← NEW

    var body: some View {
        PinkGradient {
            VStack {
                Spacer()

                Image(showAfter ? transformation.afterImageName
                                : transformation.beforeImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut, value: showAfter)
                    .transition(.opacity)

                Text(transformation.caption)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .shadow(radius: 2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal)

                // --- toggle ---------------------------------------------------
                WideSegmentedToggle(isAfter: $showAfter)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
                    // mark as “interacted” the first time it flips
                    .onChange(of: showAfter) { _ in
                        if !hasInteracted { hasInteracted = true }
                    }

                // --- continue -------------------------------------------------
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(32)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 40)
                .padding(.top, 12)
                .opacity(hasInteracted ? 1 : 0.3)   // ← uses hasInteracted
                .disabled(!hasInteracted)           // ← uses hasInteracted

                Spacer(minLength: 30)
            }
            .padding(.horizontal)
        }
    }
}

/// A white-on-white segmented control with black text + outline
struct WideSegmentedToggle: View {
    @Binding var isAfter: Bool           // true → “After” selected
    private let height: CGFloat = 48     // tweak to taste
    
    var body: some View {
        HStack(spacing: 0) {
            segment("Before", active: !isAfter)
                .onTapGesture { isAfter = false }
            segment("After",  active:  isAfter)
                .onTapGesture { isAfter = true }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: height/2, style: .continuous))
        
    }
}

private func segment(_ label: String, active: Bool) -> some View {
       Text(label)
           .font(.headline.weight(.semibold))
           .foregroundColor(.black)              // always black
           .frame(maxWidth: .infinity,
                  minHeight: 48)
           .background(                          // subtle highlight when active
               active ? Color.black.opacity(0.06) : Color.white
           )
   }

