import SwiftUI

/// The bottom action bar for the enhancement panel.
/// Now displays the currently selected option’s icon in the center.
struct BottomBar: View {
    /// The name of the asset to show between Cancel and Apply.
    let iconAssetName: String?
    let onCancel: () -> Void
    let onApply: () -> Void

    var body: some View {
        HStack {
            // Cancel button
            Button(action: onCancel) {
                Label("Cancel", systemImage: "xmark")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
            }

            Spacer()

            // Center icon for the selected enhancement
            if let asset = iconAssetName {
                Image(asset)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // Apply button
            Button(action: onApply) {
                Label("Apply", systemImage: "checkmark")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 18)
            }
        }
        .padding(.horizontal, 7)
        .padding(.bottom, 20)
    }
}
