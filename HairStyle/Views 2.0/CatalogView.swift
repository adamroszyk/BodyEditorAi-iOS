import SwiftUI

struct CatalogView: View {
    // MARK: — Data
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
                        Text("PicUp ✨")
                            .font(.largeTitle).fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.pink, Color.orange]),
                                    startPoint: .center,
                                    endPoint: .trailing
                                )
                            )
                        Spacer()
                    }
                    .padding(.horizontal)

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
                ForEach(items, id: \.title) { item in
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
