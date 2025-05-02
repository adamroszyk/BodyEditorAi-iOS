import SwiftUI

/// The enhancement panel shows a scroll of options and a bottom bar.
/// It pre-selects the first option automatically.
import SwiftUI

struct BottomBar: View {
    let iconAssetName: String?
    let onCancel: () -> Void
    let onApply: () -> Void
    let canApply: Bool

    @State private var shineApply = false

    var body: some View {
        HStack {
            // Cancel
            Button(action: onCancel) {
                Label("Cancel", systemImage: "xmark")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
            }

            Spacer()

            // Icon
            if let asset = iconAssetName {
                Image(asset)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // Apply with shimmer when canApply
            Button(action: onApply) {
                Label("Apply", systemImage: "checkmark")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        // use the mask & moving gradient
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.clear)
                            .overlay(
                                Group {
                                    if canApply {
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.black.opacity(0.1),
                                                        Color.black.opacity(0.3),
                                                        Color.black.opacity(0.1)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .rotationEffect(.degrees(30))
                                            .offset(x: shineApply ? 200 : -200)
                                            .mask(RoundedRectangle(cornerRadius: 24))
                                            .animation(
                                                Animation
                                                    .linear(duration: 2.5)
                                                    .repeatForever(autoreverses: false),
                                                value: shineApply
                                            )
                                    }
                                }
                            )
                    )
            }
            .onAppear {
                // kick it off if we're already allowed
                if canApply {
                    shineApply = true
                }
            }
            .onChange(of: canApply) { newValue in
                // whenever we flip to true, reset & start the shimmer
                if newValue {
                    shineApply = false
                    shineApply = true
                } else {
                    shineApply = false
                }
            }
        }
        .padding(.horizontal, 7)
        .padding(.bottom, 20)
    }
}

// EnhancementPanelView itself
struct EnhancementPanelView: View {
    let section: String
    let options: [EnhancementOption]
    @Binding var selectedOption: EnhancementOption?
    let applyAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            PillsScroll(options: options, selectedOption: $selectedOption)
            Divider().background(Color.white.opacity(0.5))
            BottomBar(
                iconAssetName: sectionIconName,
                onCancel: cancelAction,
                onApply: applyAction,
                canApply: selectedOption != nil
            )
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .padding(.top, 12)
        .onAppear {
            // Pre-select first option
            if selectedOption == nil, let first = options.first {
                selectedOption = first
            }
        }
    }

    private var sectionIconName: String {
        section.replacingOccurrences(of: " ", with: "")
    }
}




// MARK: — Pills Scroll
private struct PillsScroll: View {
    let options: [EnhancementOption]
    @Binding var selectedOption: EnhancementOption?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(options) { opt in
                    OptionPill(
                        option: opt,
                        isSelected: opt.id == selectedOption?.id
                    )
                    .onTapGesture { selectedOption = opt }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .padding(.top, 12)
        }
    }
}

// MARK: — Single Pill
private struct OptionPill: View {
    let option: EnhancementOption
    let isSelected: Bool

    private var iconName: String {
        switch option.id {
        case "round":        return "circle"
        case "heart_shaped": return "heart.fill"
        case "superlift":    return "flame.fill"
        default:             return "sparkles"
        }
    }

    private var titleColor: AnyShapeStyle {
        if isSelected {
            AnyShapeStyle(
                LinearGradient(
                    colors: [Color.pink, Color.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        } else {
            AnyShapeStyle(Color.white.opacity(0.9))
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            Text(option.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(titleColor)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(isSelected ? Color.black.opacity(0.85) : Color.black.opacity(0.6))
        .cornerRadius(24)
        .overlay(
            Group {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .offset(x: 8, y: -8)
                }
            }, alignment: .topTrailing
        )
    }
}
