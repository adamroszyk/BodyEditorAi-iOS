import SwiftUI

struct CatalogView: View {
    // MARK: — Prompt definitions shown in the horizontal panel
    private let promptItems: [PromptItem] = [
        .init(name: "🧹 Remove Objects",
              prompt: "Remove the unwanted objects from the background keeping the subject intact"),
        .init(name: "🎨 Clear Background",
              prompt: "Replace the background with a plain, neutral colour"),
        .init(name: "🎞️ Blur Background",
              prompt: "Blur the background softly to emphasise the subject"),
        .init(name: "🌈 Vibrant Colours",
              prompt: "Enhance all colours for a vivid, saturated look while preserving skin tones"),
        .init(name: "🪄 Magic Retouch",
              prompt: "Subtly smooth skin and reduce blemishes for a polished finish"),
        .init(name: "✨ Highlight Pop",
              prompt: "Increase highlights and contrast to make the subject stand out")
    ]

    // MARK: — Data for grid sections
    private let bodyShapeItems: [(title: String, icon: String)] = [
        ("Chest Curve",   "Chest"),
        ("Flat Abs",      "Belly"),
        ("Buttocks+",     "Buttock"),
        ("Slim Waist",    "Waist"),
        ("Legs",          "Legs"),
        ("Muscles",       "Muscle")
    ]

    private let facialItems: [(title: String, icon: String)] = [
        ("Face",          "Face"),
        ("Eyes",          "Eyes"),
        ("Nose",          "Nose"),
        ("Lips",          "Lips"),
        ("Skin",          "Skin")
    ]

    private let hairAccessoryItems: [(title: String, icon: String)] = [
        ("Hair",          "Hair"),
        ("Jewellery",     "jewellery"),
        ("Eyewear",       "Eyewear")
    ]

    // Three flexible columns
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 16),
        count: 3
    )

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // MARK: — Header
                    HStack {
                        Text("BodyEditor Ai")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.pink, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Spacer()
                    }
                    .padding(.horizontal)

                    // MARK: — Prompt Panel
                    HorizontalPromptScroll(items: promptItems)
                        .padding(.top, 4)

                    // MARK: — Body Shape Section
                    SectionGrid(
                        title: "Body Shape",
                        items: bodyShapeItems,
                        columns: columns
                    )

                    // MARK: — Facial Section
                    SectionGrid(
                        title: "Facial",
                        items: facialItems,
                        columns: columns
                    )

                    // MARK: — Hair & Accessories Section
                    SectionGrid(
                        title: "Hair & Accessories",
                        items: hairAccessoryItems,
                        columns: columns
                    )
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.14, green: 0.13, blue: 0.13).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

// MARK: — Section Grid (unchanged)
private struct SectionGrid: View {
    let title: String
    let items: [(title: String, icon: String)]
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                ForEach(items, id: \ .title) { item in
                    NavigationLink(
                        destination: GenView(section: item.icon)
                    ) {
                        VStack(spacing: 8) {
                            // Circular icon background
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 70, height: 70)
                                    .shadow(color: Color.white.opacity(0.2),
                                            radius: 6,
                                            x: 0,
                                            y: 0)

                                Image(item.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            }

                            Text(item.title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
            .preferredColorScheme(.dark)
    }
}
