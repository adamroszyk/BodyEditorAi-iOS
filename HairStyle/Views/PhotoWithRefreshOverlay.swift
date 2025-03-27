import SwiftUI
import PhotosUI
import Vision

struct PhotoWithRefreshOverlay: View {
    let originalImage: UIImage?
    let editedImage: UIImage?
    // Depth map image is still provided here.
    let depthMapImage: UIImage?
    
    @Binding var sliderPosition: CGFloat
    @Binding var showSlider: Bool
    
    // Closure for "replace image", "add image", and "save" actions.
    let onReplaceTap: () -> Void
    let onAddTap: () -> Void
    let onSaveTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let orig = originalImage, let edit = editedImage {
                // Pass the depthMapImage to the comparison view.
                AspectLimitedComparisonView(
                    originalImage: orig,
                    modifiedImage: edit,
                    depthMapImage: depthMapImage,
                    sliderPosition: $sliderPosition,
                    showSlider: $showSlider
                )
                .id(depthMapImage)
            } else if let edit = editedImage {
                // Show single edited image view (implement your own).
                AspectLimitedSingleImageView(
                    image: edit,
                    showSlider: $showSlider
                )
            } else {
                // Show empty state when there is no image.
                EmptyStateView(onAddTap: onAddTap)
            }
            
            // Only show the buttons if there is an edited image available.
            if editedImage != nil {
                HStack {
                    // "Replace" button
                    Button(action: onReplaceTap) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // "Save" button
                    Button(action: {
                        if let imageToSave = editedImage {
                            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
                        }
                        onSaveTap()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
        .padding(.horizontal, 16)
    }
}
