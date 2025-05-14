import SwiftUI

struct BeforeAfterPage: View {
    let transformation: Transformation
    let onContinue: () -> Void

    @State private var showAfter     = false
    @State private var hasInteracted = false

    var body: some View {
        ZStack {
            // 1) blurred fill-to-screen bg
            GeometryReader { proxy in
                Image(showAfter
                        ? transformation.afterImageName
                        : transformation.beforeImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width,
                           height: proxy.size.height)
                    .clipped()
                    .blur(radius: 30)
            }

            // 2) crisp before/after image on top
            Image(showAfter
                    ? transformation.afterImageName
                    : transformation.beforeImageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)

            // 3) caption + controls
            VStack {
                Spacer()

                Text(transformation.caption)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .shadow(radius: 5)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                VStack(spacing: 16) {
                    WideSegmentedToggle(isAfter: $showAfter)
                        .onChange(of: showAfter) { _ in
                            if !hasInteracted { hasInteracted = true }
                        }

                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.25),
                            radius: 8, x: 0, y: 4)
                    .opacity(hasInteracted ? 1 : 0.3)
                    .disabled(!hasInteracted)
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.25),
                        radius: 12, x: 0, y: 6)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()    // ← ensures your blurred bg shows under the home-indicator too
    }
}


/// A pill‐shaped toggle whose selected segment
/// uses a stronger material + higher opacity.
struct WideSegmentedToggle: View {
    @Binding var isAfter: Bool
    private let height: CGFloat = 48

    var body: some View {
        HStack(spacing: 0) {
            segment("Before", active: !isAfter) {
                withAnimation(.easeInOut) { isAfter = false }
            }
            segment("After",  active:  isAfter) {
                withAnimation(.easeInOut) { isAfter = true }
            }
        }
        .frame(height: height)
        .background(.ultraThinMaterial)  // parent track
        .clipShape(RoundedRectangle(
            cornerRadius: height/2,
            style: .continuous
        ))
        .shadow(color: .black.opacity(0.25),
                radius: 8, x: 0, y: 4)
        .animation(.easeInOut, value: isAfter)
    }

    private func segment(
        _ label: String,
        active: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: height)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: height/2,
                             style: .continuous)
                // use a stronger material when selected…
                .fill(active ? .regularMaterial : .ultraThinMaterial)
                // …and bump opacity for extra pop
                .opacity(active ? 1.0 : 0.6)
        )
        .animation(.easeInOut, value: active)
    }
}
