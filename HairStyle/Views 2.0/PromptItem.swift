import SwiftUI

// MARK: - Prompt model --------------------------------------------------------
struct PromptItem: Identifiable {
    let id = UUID()
    let name: String    // Emoji‑prefixed label shown in the pill
    let prompt: String  // Full prompt passed to GenView
}

// MARK: - Two‑row, horizontally scrolling prompt panel -----------------------
struct HorizontalPromptScroll: View {
    let items: [PromptItem]

    // Two fixed‑height rows stacked vertically inside a horizontally scrolling grid
    private let rows = [
        GridItem(.fixed(48), spacing: 12),
        GridItem(.fixed(48))
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, alignment: .center, spacing: 16) {
                ForEach(items) { item in
                    NavigationLink(destination: GenView(section: item.prompt)) {
                        PromptTag(text: item.name)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.clear)
    }
}

// MARK: - Single prompt pill --------------------------------------------------
private struct PromptTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.55))
            )
    }
}
