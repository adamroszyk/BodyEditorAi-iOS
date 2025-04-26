import SwiftUI

/// A zoomable & pannable container that shows either
/// • a comparison slider between an original & edited image
/// • a single edited image
/// • or an empty-state prompt when no image is loaded.
///
/// **Key fixes (v3):**
/// • Added a tiny `CGSize` `+` helper so the file *actually* compiles – Xcode
///   doesn’t ship an overload for adding two `CGSize`s. Nothing else about
///   the gesture logic changes.
///
/// (Icon-layout & animation-suppression tweaks from v2 remain.)
struct PhotoWithRefreshOverlay: View {
    // MARK: – Inputs
    let originalImage: UIImage?
    let editedImage: UIImage?
    let depthMapImage: UIImage?

    @Binding var sliderPosition: CGFloat
    @Binding var showSlider: Bool

    let onReplaceTap: () -> Void
    let onAddTap: () -> Void
    let onSaveTap: () -> Void

    // MARK: – Persistent transform state
    @State private var accumulatedScale: CGFloat = 1.0
    @State private var accumulatedOffset: CGSize = .zero

    // MARK: – Transient gesture state (cleared every frame)
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero

    // MARK: – Constants
    @ScaledMetric private var iconSide: CGFloat = 24
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 5

    var body: some View {
        ZStack {
            contentView
                .scaleEffect(currentScale)
                .offset(currentOffset)
                .animation(.none, value: currentScale)
                .animation(.none, value: currentOffset)
                .gesture(transformGesture)
                .transaction { $0.disablesAnimations = true }

          /*  if editedImage != nil {
                actionButtons
                    .padding([.top, .horizontal], 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .zIndex(1)
            }*/
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: – Computed helpers
    private var currentScale: CGFloat { accumulatedScale * gestureScale }

    private var currentOffset: CGSize {
        CGSize(width: accumulatedOffset.width + gestureOffset.width,
               height: accumulatedOffset.height + gestureOffset.height)
    }

    // MARK: – Sub-views
    @ViewBuilder
    private var contentView: some View {
        if let orig = originalImage, let edit = editedImage {
            AspectLimitedComparisonView(
                originalImage: orig,
                modifiedImage: edit,
                depthMapImage: depthMapImage,
                sliderPosition: $sliderPosition,
                showSlider: $showSlider
            )
            .id(depthMapImage)
        } else if let edit = editedImage {
            AspectLimitedSingleImageView(image: edit, showSlider: $showSlider)
        } else {
            EmptyStateView(onAddTap: onAddTap)
        }
    }

    private var actionButtons: some View {
        HStack {
            Button(action: onReplaceTap) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .modifier(ActionIcon(side: iconSide))
            }
            Spacer()
            Button(action: saveTapped) {
                Image(systemName: "square.and.arrow.down")
                    .modifier(ActionIcon(side: iconSide))
            }
        }
    }

    private func saveTapped() {
        if let img = editedImage {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }
        onSaveTap()
    }

    // MARK: – Gestures
    private var transformGesture: some Gesture {
        SimultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($gestureOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    accumulatedOffset = clamped(offset: accumulatedOffset + value.translation)
                },
            MagnificationGesture()
                .updating($gestureScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    let newScale = accumulatedScale * value
                    accumulatedScale = min(max(newScale, minScale), maxScale)
                }
        )
    }

    private func clamped(offset: CGSize) -> CGSize {
        CGSize(width: max(min(offset.width, 2_000), -2_000),
               height: max(min(offset.height, 2_000), -2_000))
    }
}

// MARK: – `CGSize` arithmetic helper
private extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

// MARK: – Style helpers & stubs
private struct ActionIcon: ViewModifier {
    let side: CGFloat
    func body(content: Content) -> some View {
        content
            .font(.system(size: side * 0.45, weight: .medium))
            .foregroundColor(.white)
            .frame(width: side, height: side)
            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
    }
}

struct EmptyStateView: View {
    let onAddTap: () -> Void
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                VStack {
                    Spacer()
                    Button(action: onAddTap) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                                .font(.system(size: 40))
                            Text("Add Image +")
                                .font(.headline)
                        }
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                    Spacer()
                }
                .frame(height: 600)
            )
    }
}
