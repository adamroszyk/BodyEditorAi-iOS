import SwiftUI
import UIKit
import StoreKit

// MARK: – Thumbnail item model -------------------------------------------------
struct ThumbItem: Identifiable {
    /// id == -1 → original; 0…3 → generated slots
    let id: Int
    var image: UIImage? = nil
    var isLoading: Bool = false
    var isOriginal: Bool { id == -1 }
}

// MARK: – GenView --------------------------------------------------------------
struct GenView: View {
    // MARK: Inputs
    let section: String

    // MARK: View-model
    @StateObject private var viewModel = ImageEditingViewModel()

    // MARK: UI state
    @State private var selectedOption: EnhancementOption?
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var sliderPosition: CGFloat = 0.5
    @State private var showSlider = false
    @State private var showSaveSuccessAlert = false

    // thumbnails: original + generated
    @State private var thumbs: [ThumbItem] = []
    @State private var currentIdx: Int? = nil

    // paywall modal flag
    @State private var showPaywallModal = false

    // MARK: Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    // Derived
    private var isGenerating: Bool { thumbs.contains { !$0.isOriginal && $0.isLoading } }
    private var hasThumbs: Bool { !thumbs.isEmpty }
    private var shouldShowPaywall: Bool {
        !subscriptionManager.purchasedIdentifiers.contains("weeksub")
        && thumbs.count >= 5
        && thumbs.dropFirst().allSatisfy { !$0.isLoading }
    }

    // MARK: Body ----------------------------------------------------------------
    var body: some View {
        ZStack {
            GeometryReader { geo in
                PhotoContainerView(
                    inputImage: $inputImage,
                    isGenerating: isGenerating,
                    editedImage: mainDisplayedImage,
                    depthMapImage: viewModel.depthMapImage,
                    sliderPosition: $sliderPosition,
                    showSlider: $showSlider,
                    onAddTap: handleReplacePhoto,
                    onReplaceTap: handleReplacePhoto,
                    onSaveTap: saveImage
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea()

                if inputImage != nil {
                    TopButtons(
                        onBack: { dismiss() },
                        onReplace: handleReplacePhoto,
                        onShare: shareImage,
                        onSave: saveImage,
                        topInset: -20
                    )
                    .padding(.horizontal, 16)
                }

                VStack {
                    Spacer()
                    if hasThumbs {
                        ThumbnailsStrip(
                            thumbs: thumbs,
                            onSelect: { currentIdx = $0 },
                            onRetry: beginParallelGeneration
                        )
                    } else {
                        EnhancementPanelView(
                            section: section,
                            options: enhancementOptions,
                            selectedOption: $selectedOption,
                            applyAction: beginParallelGeneration,
                            cancelAction: { dismiss() }
                        )
                    }
                }
                .frame(width: geo.size.width)
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if isGenerating {
                Color.black.opacity(0.35).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .alert("Saved", isPresented: $showSaveSuccessAlert) {
            Button("OK", role: .cancel) {}
        } message: { Text("Image saved to Photos") }
        .onChange(of: shouldShowPaywall) { if $0 { showPaywallModal = true } }
        .fullScreenCover(isPresented: $showPaywallModal) {
            WeeklyPaywallView(
                thumbs: thumbs,
                onUnlock: { showPaywallModal = false },
                onClose: {
                    showPaywallModal = false
                    dismiss()
                }
            )
            .environmentObject(subscriptionManager)
        }
    }

    // MARK: Helpers ------------------------------------------------------------
    private var mainDisplayedImage: UIImage? {
        guard let idx = currentIdx, thumbs.indices.contains(idx) else {
            return viewModel.editedImage
        }
        return idx == 0 ? inputImage : thumbs[idx].image
    }

    // MARK: Generation ----------------------------------------------------------
    private func beginParallelGeneration() {
        guard let base = inputImage, let prompt = selectedOption?.prompt else { return }
        thumbs = [ThumbItem(id: -1, image: base, isLoading: false)] +
                 (0..<4).map { ThumbItem(id: $0, isLoading: true) }
        currentIdx = 1
        Task.detached(priority: .userInitiated) {
            await withTaskGroup(of: (Int, UIImage?).self) { group in
                for idx in 0..<4 {
                    group.addTask { (idx, await ImageEditingWorker.generate(input: base, prompt: prompt)) }
                }
                for await (idx, img) in group {
                    await MainActor.run {
                        thumbs[idx + 1].image = img
                        thumbs[idx + 1].isLoading = false
                    }
                }
            }
        }
    }

    // MARK: UI actions ---------------------------------------------------------
    private func handleReplacePhoto() { showingImagePicker = true }
    private func loadImage() {
        guard let img = inputImage else { return }
        viewModel.editedImage = img
        thumbs.removeAll()
        currentIdx = nil
    }
    private func saveImage() {
        guard let img = mainDisplayedImage else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        showSaveSuccessAlert = true
    }
    private func shareImage() {
        guard let img = mainDisplayedImage else { return }
        let av = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }

    // MARK: Enhancement options -----------------------------------------------
    private var enhancementOptions: [EnhancementOption] {
        switch section {
        case "Chest":    return BodyEnhancementPrompts.breast
        case "Belly":    return BodyEnhancementPrompts.belly
        case "Buttock":  return BodyEnhancementPrompts.buttock
        case "Muscle":   return BodyEnhancementPrompts.muscle
        case "Hair":     return BodyEnhancementPrompts.hair
        case "Nose":     return BodyEnhancementPrompts.nose
        case "Eyes":     return BodyEnhancementPrompts.eyes
        case "Skin":     return BodyEnhancementPrompts.skin
        case "Face":     return BodyEnhancementPrompts.face
        case "Lips":     return BodyEnhancementPrompts.lips
        case "Waist":    return BodyEnhancementPrompts.waist
        case "Legs":     return BodyEnhancementPrompts.leg
        case "jewellery":return BodyEnhancementPrompts.jewellery
        case "Eyewear":  return BodyEnhancementPrompts.eyewear
        default:          return []
        }
    }
}

 struct ThumbnailsStrip: View {
    let thumbs: [ThumbItem]
    let onSelect: (Int) -> Void
    let onRetry: () -> Void
    var isGenerating: Bool { thumbs.contains { !$0.isOriginal && $0.isLoading } }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(thumbs) { thumb in
                    ZStack {
                        // image or placeholder
                        Group {
                            if let ui = thumb.image {
                                Image(uiImage: ui)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Color.gray.opacity(0.3)
                            }
                        }
                        .frame(width: 70, height: 70)
                        .clipped()
                        .cornerRadius(12)

                        // centered spinner
                        if thumb.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }

                        // bottom “ORIGINAL” badge
                        if thumb.isOriginal {
                            VStack {
                                Spacer()
                                Text("ORIGINAL")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.6))
                            }
                        }
                    }
                    .frame(width: 70, height: 70)
                    .onTapGesture { onSelect(thumb.id == -1 ? 0 : thumb.id + 1) }
                }

                // retry button…
                Button(action: onRetry) {
                    ZStack {
                        Color.black.opacity(0.6)
                        Image(systemName: "arrow.clockwise")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 70, height: 70)
                    .cornerRadius(12)
                    .overlay(isGenerating ? Color.black.opacity(0.4).cornerRadius(12) : nil)
                }
                .disabled(isGenerating)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}


private struct TopButtons: View {
    let onBack, onReplace, onShare, onSave: () -> Void
    let topInset: CGFloat
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack)    { Image(systemName: "chevron.left").modifier(circleIcon) }
            Button(action: onReplace) { Image(systemName: "arrow.triangle.2.circlepath").modifier(circleIcon) }
            Spacer()
            HStack(spacing: 12) {
                Button(action: onShare) { Image(systemName: "paperplane.fill").modifier(circleIcon) }
                Button(action: onSave)  { Image(systemName: "square.and.arrow.down").modifier(circleIcon) }
            }
        }
        .padding(.top, topInset + 20)
    }
    private var circleIcon: some ViewModifier { CircleIcon() }
}
private struct CircleIcon: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
    }
}
