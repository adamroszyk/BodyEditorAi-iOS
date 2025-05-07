import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

/// A forced, GenView-style demo on a hard-coded sample image.
@available(iOS 17.0, *)
struct DemoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ImageEditingViewModel()

    // Keep as optional so binding matches PhotoContainerView
    @State private var inputImage: UIImage? = UIImage(named: "model1") ?? UIImage(systemName: "photo")
    @State private var thumbs: [ThumbItem] = []
    @State private var currentIdx: Int? = nil
    @State private var selectedOption: EnhancementOption? = nil

    // True while any thumbnail slot is loading
    private var isGenerating: Bool { thumbs.contains { !$0.isOriginal && $0.isLoading } }
    private var hasThumbs: Bool { !thumbs.isEmpty }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                PhotoContainerView(
                    inputImage: $inputImage,
                    isGenerating: isGenerating,
                    editedImage: mainDisplayedImage,
                    depthMapImage: viewModel.depthMapImage,
                    sliderPosition: .constant(0.5),
                    showSlider: .constant(false),
                    onAddTap: {}, onReplaceTap: {}, onSaveTap: {}
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea()

                // Close button
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.top, 44).padding(.horizontal)
                    Spacer()
                }

                // Bottom panel: dynamic EnhancementPanel or ThumbnailsStrip
                VStack {
                    Spacer()
                    if hasThumbs {
                        ThumbnailsStrip(
                            thumbs: thumbs,
                            onSelect: { idx in currentIdx = idx == 0 ? 0 : idx },
                            onRetry: runDemo
                        )
                    } else {
                        EnhancementPanelView(
                            section: "Demo",
                            options: demoOptions,
                            selectedOption: $selectedOption,
                            applyAction: runDemo,
                            cancelAction: { dismiss() }
                        )
                    }
                }
                .frame(width: geo.size.width)
            }
            .onAppear {
                // Always pick the first demo option so runDemo() never aborts
                if selectedOption == nil {
                    selectedOption = demoOptions.first
                }
            }

            // Full-screen overlay spinner
            if isGenerating {
                Color.black.opacity(0.35).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
    }

    private var mainDisplayedImage: UIImage? {
        guard let idx = currentIdx, thumbs.indices.contains(idx) else {
            return inputImage
        }
        return thumbs[idx].image
    }

    /// Four hard-coded “combo” filters
    private var demoOptions: [EnhancementOption] = [
        EnhancementOption(id: "demo_hair",  title: "Improve Hair",    subtitle: nil, prompt: "Enhance hair detail and volume",           isFree: true),
        EnhancementOption(id: "demo_smile", title: "Improve Smile",   subtitle: nil, prompt: "Brighten and enhance the smile naturally", isFree: true),
        EnhancementOption(id: "demo_chest", title: "Improve Chest",   subtitle: nil, prompt: "Sculpt and subtly lift chest contours",    isFree: true),
        EnhancementOption(id: "demo_butt",  title: "Improve Buttock", subtitle: nil, prompt: "Lift and sculpt glute shape",               isFree: true)
    ]

    /// Simulate the GenView “parallel” generation workflow with strong visual change
    private func runDemo() {
        guard let filter = selectedOption, let base = inputImage else {
            print("⚠️ runDemo aborted: selectedOption=\(String(describing: selectedOption)), inputImage=\(String(describing: inputImage))")
            return
        }
        print("▶️ running demo for \(filter.id)")
        // original + 4 loading slots
        thumbs = [ThumbItem(id: -1, image: base, isLoading: false)] +
                 (0..<4).map { ThumbItem(id: $0, image: base, isLoading: true) }
        currentIdx = 1

        for idx in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx + 1) * 0.5) {
                // Apply a full color inversion for dramatic effect
                let generated = base.invertedImage() ?? base
                thumbs[idx + 1].image = generated
                thumbs[idx + 1].isLoading = false

                // After the last thumbnail, finalize the demo swap
                if idx == 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        inputImage = generated
                        thumbs.removeAll()
                        currentIdx = nil
                    }
                }
            }
        }
    }
}

// MARK: – UIImage inversion extension for demo
private extension UIImage {
    func invertedImage() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let filter = CIFilter.colorInvert()
        filter.inputImage = ciImage
        let context = CIContext()
        guard let output = filter.outputImage,
              let cgimg = context.createCGImage(output, from: output.extent)
        else { return nil }
        return UIImage(cgImage: cgimg, scale: scale, orientation: imageOrientation)
    }
}
