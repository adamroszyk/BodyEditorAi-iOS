//
//  GenView.swift
//  HairStyle
//

import SwiftUI
import UIKit
import StoreKit

// MARK: – Thumbnail-strip item ----------------------------------------------
struct ThumbItem: Identifiable {
    /// id == -1 → original; 0…5 → generated slots
    let id: Int
    var image: UIImage? = nil
    var isLoading: Bool = false
    var isOriginal: Bool { id == -1 }
}

// MARK: – GenView ------------------------------------------------------------
struct GenView: View {

    // MARK:  Inputs
    let section: String
    init(section: String) { self.section = section }

    // MARK:  View-model
    @StateObject private var viewModel = ImageEditingViewModel()

    // MARK:  UI state
    @State private var selectedOption: EnhancementOption?
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingAvatarPicker = false
    @State private var sliderPosition: CGFloat = 0.5
    @State private var showSlider  = false
    @State private var showSaveSuccessAlert = false
    @State private var showRateLimitAlert   = false      // ← NEW

    // thumbnails: original + generated
    @State private var thumbs: [ThumbItem] = []
    @State private var currentIdx: Int?     = nil

    // Pay-wall modal
    @State private var showPaywallModal = false

    // MARK:  Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    // MARK:  Derived helpers
    private var isGenerating: Bool { thumbs.contains { !$0.isOriginal && $0.isLoading } }
    private var hasThumbs:   Bool { !thumbs.isEmpty }
    private var shouldShowPaywall: Bool {
        !subscriptionManager.isSubscribed &&
        thumbs.count >= 5 &&
        thumbs.dropFirst().allSatisfy { !$0.isLoading }
    }

    // Pre-bundled demo avatars
    private var builtInAvatars: [UIImage] = {
        (1...10).compactMap { UIImage(named: String(format: "Persona%02d", $0)) }
    }()

    // MARK:  Body ------------------------------------------------------------
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
                    onAvatarTap: { showingAvatarPicker = true },
                    onSaveTap: saveImage
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea()

                if inputImage != nil {
                    TopButtons(
                        onBack:    { dismiss() },
                        onReplace: handleReplacePhoto,
                        onShare:   shareImage,
                        onSave:    saveImage,
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
                            onRetry:  beginParallelGeneration
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
        .overlay { overlayGenerating }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .sheet(isPresented: $showingAvatarPicker) {
            AvatarPickerView(
                avatars: builtInAvatars,
                onSelect: { ui in
                    inputImage = ui
                    loadImage()
                    showingAvatarPicker = false
                },
                onCancel: { showingAvatarPicker = false }
            )
        }
        // ───────────── Alerts & modals ──────────────────────────────────────
        .alert("Saved", isPresented: $showSaveSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Image saved to Photos")
        }
        .alert("Slow down 🙂",                             // ← NEW
               isPresented: $showRateLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let sec = subscriptionManager.waitInterval {
                Text("You can create again in \(Int(sec.rounded())) s.")
            } else {
                Text("Please wait a moment before trying again.")
            }
        }
        .onChange(of: shouldShowPaywall) { if $0 { showPaywallModal = true } }
        .fullScreenCover(isPresented: $showPaywallModal) { paywall }
    }

    // MARK: – Sub-views & helpers -------------------------------------------
    private var overlayGenerating: some View {
        Group {
            if isGenerating {
                Color.black.opacity(0.35).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            }
        }
    }

    private var paywall: some View {
        WeeklyPaywallView(
            thumbs: thumbs,
            onUnlock: { showPaywallModal = false },
            onClose:  {
                showPaywallModal = false
                dismiss()
            }
        )
        .environmentObject(subscriptionManager)
    }

    private var mainDisplayedImage: UIImage? {
        guard let idx = currentIdx, thumbs.indices.contains(idx) else {
            return viewModel.editedImage
        }
        return idx == 0 ? inputImage : thumbs[idx].image
    }

    // =======================================================================
    //  Generation ------------------------------------------------------------
    // =======================================================================
    private func beginParallelGeneration() {

        // 0️⃣  Throttle check – applies to *all* users -----------------------
        if subscriptionManager.waitInterval != nil {
            showRateLimitAlert = true
            return
        }

        guard let base   = inputImage,
              let prompt = selectedOption?.prompt else { return }

        // 1️⃣  Free quota still available OR user is subscribed --------------
        if subscriptionManager.canGenerate {
            thumbs = [ThumbItem(id: -1, image: base)] +
                     (0..<6).map { ThumbItem(id: $0, isLoading: true) }
            currentIdx = 1

            Task.detached(priority: .userInitiated) {
                await withTaskGroup(of: (Int, UIImage?).self) { group in
                    for idx in 0..<6 {
                        group.addTask {
                            (idx, await ImageEditingWorker.generate(
                                        input: base, prompt: prompt))
                        }
                    }
                    for await (idx, img) in group {
                        await MainActor.run {
                            thumbs[idx + 1].image     = img
                            thumbs[idx + 1].isLoading = false
                        }
                    }
                }
                await MainActor.run {
                    subscriptionManager.markGenerationUsed()     // ← important
                }
            }
            return
        }

        // 2️⃣  Free quota exhausted – local blurred placeholders -------------
        let previous = mainDisplayedImage ?? base        // best frame we have
        thumbs = [ThumbItem(id: -1, image: base)] +
                 (0..<6).map { ThumbItem(id: $0, isLoading: true) }
        currentIdx = 1

        Task.detached(priority: .userInitiated) {
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)  // 5 s spinner

            let radii: [Double] = [26, 28, 30, 32, 24, 16]
            let variants: [UIImage?] = radii.map { previous.blurred(radius: $0) }

            await MainActor.run {
                for (idx, ui) in variants.enumerated() {
                    thumbs[idx + 1].image     = ui
                    thumbs[idx + 1].isLoading = false
                }
                currentIdx = 1
                subscriptionManager.markGenerationUsed()
            }
        }
    }

    // MARK:  UI actions ------------------------------------------------------
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
        let av = UIActivityViewController(
            activityItems: [img], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?
            .present(av, animated: true)
    }

    // MARK:  Enhancement options --------------------------------------------
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
        default:
            return [
                EnhancementOption(
                    id: "custom",
                    title: "Apply",
                    subtitle: nil,
                    prompt: section,
                    isFree: true
                )
            ]
        }
    }
}


struct ThumbnailsStrip: View {
    // MARK: – Inputs
    let thumbs: [ThumbItem]
    let onSelect: (Int) -> Void
    let onRetry: () -> Void

    // MARK: – Layout
    private let thumbWidth:  CGFloat = 91   // 70 pt × 1.3
    private let thumbHeight: CGFloat = 118  // 70 pt × 1.3 (portrait)

    // Derived
    var isGenerating: Bool { thumbs.contains { !$0.isOriginal && $0.isLoading } }

    // MARK: – Body
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {

                // 1️⃣ thumbnails ------------------------------------------------
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
                        .frame(width: thumbWidth, height: thumbHeight)
                        .clipped()
                        .cornerRadius(14)

                        // spinner
                        if thumb.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }

                        // “ORIGINAL” badge
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
                    .frame(width: thumbWidth, height: thumbHeight)
                    .onTapGesture {
                        onSelect(thumb.id == -1 ? 0 : thumb.id + 1)
                    }
                }

                // 2️⃣ retry button --------------------------------------------
                Button(action: onRetry) {
                    ZStack {
                        Color.black.opacity(0.6)
                        Image(systemName: "arrow.clockwise")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: thumbWidth, height: thumbHeight)
                    .cornerRadius(14)
                    .overlay(isGenerating ? Color.black.opacity(0.4)
                                              .cornerRadius(14) : nil)
                }
                .disabled(isGenerating)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(height: thumbHeight + 16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}
import SwiftUI

private struct TopButtons: View {
    let onBack:    () -> Void
    let onReplace: () -> Void
    let onShare:   () -> Void
    let onSave:    () -> Void
    let topInset:  CGFloat

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack)    { Image(systemName: "chevron.left").modifier(circle) }
            Button(action: onReplace) { Image(systemName: "arrow.triangle.2.circlepath").modifier(circle) }
            Spacer()
            Button(action: onShare) { Image(systemName: "paperplane.fill").modifier(circle) }
            Button(action: onSave)  { Image(systemName: "square.and.arrow.down").modifier(circle) }
        }
        .padding(.top, topInset + 20)
    }

    private var circle: some ViewModifier { CircleIcon() }
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
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {
    /// Fast Gaussian blur using Core Image.
    func blurred(radius: Double) -> UIImage? {
        guard let cg = cgImage else { return nil }

        let ciImg  = CIImage(cgImage: cg)
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = ciImg
        filter.radius     = Float(radius)

        guard let out = filter.outputImage else { return nil }
        let ctx  = CIContext()
        guard let cgOut = ctx.createCGImage(out, from: ciImg.extent) else { return nil }
        return UIImage(cgImage: cgOut)
    }
}
