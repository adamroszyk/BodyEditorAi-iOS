import SwiftUI

/// Grid picker that shows the bundled persona shots.
struct AvatarPickerView: View {
    let avatars: [UIImage]
    let onSelect: (UIImage) -> Void
    let onCancel: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 20)]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(avatars.indices, id: \.self) { idx in
                        Image(uiImage: avatars[idx])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(12)
                            .onTapGesture { onSelect(avatars[idx]) }
                    }
                }
                .padding()
            }
            .navigationTitle("Select AI Avatar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}
