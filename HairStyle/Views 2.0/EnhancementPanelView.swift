import SwiftUI

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
                onApply: applyAction
            )
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .padding(.top, 12)
    }
    
    private var sectionIconName: String {
        // e.g. "Slim Waist" → "SlimWaist"
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

    // map id → SF symbol
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
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.pink, Color.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        } else {
            return AnyShapeStyle(Color.white.opacity(0.9))
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
        // ↑ bump horizontal padding from 16 → 20, vertical from 8 → 12
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(isSelected
                    ? Color.black.opacity(0.85)
                    : Color.black.opacity(0.6))
        .cornerRadius(24)  // slightly larger radius
        .overlay(
                    Group {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)            // slightly larger
                                .foregroundColor(.white)  // white+
                                .offset(x: 8, y: -8)

                        }
                    },
                    alignment: .topTrailing
                )    }
    @ViewBuilder
    private var checkmarkOverlay: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
                .offset(x: 12, y: -12)
        }
    }
}
