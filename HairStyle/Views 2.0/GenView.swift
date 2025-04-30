import SwiftUI
import StoreKit      // ← add


/// The main generation view, with a full-screen loading indicator and faster spinner.
struct GenView: View {
    let section: String
    @StateObject private var viewModel = ImageEditingViewModel()
    @State private var selectedOption: EnhancementOption?

    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var sliderPosition: CGFloat = 0.5
    @State private var showSlider = false
    @State private var showSaveSuccessAlert = false
    @State private var isSpinning = false
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("completedGenerationCount") private var completedGenerationCount = 0
    @AppStorage("hasRequestedReview")       private var hasRequestedReview     = false

    /// Enhancement options based on selected section
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
        case "Legs":      return BodyEnhancementPrompts.leg
        case "jewellery": return BodyEnhancementPrompts.jewellery
        case "Eyewear":  return BodyEnhancementPrompts.eyewear
        default:          return []
        }
    }

    var body: some View {
        ZStack {
            // Content container, blurred & disabled when loading
            ZStack(alignment: .top) {
                GeometryReader { geo in
                    PhotoContainerView(
                        inputImage: $inputImage,
                        editedImage: viewModel.editedImage,
                        depthMapImage: viewModel.depthMapImage,
                        sliderPosition: $sliderPosition,
                        showSlider: $showSlider,
                        onAddTap: pickImage,
                        onReplaceTap: pickImage,
                        onSaveTap: saveImage
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()

                    if inputImage != nil {
                        TopButtons(
                            onReplace: pickImage,
                            onSave: saveImage,
                            topInset: -20
                        )
                        .padding(.horizontal, 16)
                    }

                    VStack {
                        Spacer()
                        EnhancementPanelView(
                            section: section,
                            options: enhancementOptions,
                            selectedOption: $selectedOption,
                            applyAction: { viewModel.editImage() },
                            cancelAction: { dismiss() }
                        )
                        .frame(width: geo.size.width)
                    }
                }
            }
            .blur(radius: viewModel.isLoading ? 12 : 0)
            .disabled(viewModel.isLoading)
            // Remove horizontal padding when loading to ensure full-width blur
            .padding(.horizontal, viewModel.isLoading ? 0 : 8)

            // Loading overlay with faster spinner
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                    //.rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .animation(.linear(duration: 0.6).repeatForever(autoreverses: false), value: isSpinning)
                    .onAppear { isSpinning = true }
                    
            }
        }
        
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .alert("Saved", isPresented: $showSaveSuccessAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Image saved successfully to your Photos.")
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.loadModel()
                } catch {
                    viewModel.errorMessage = "Failed to load model: \(error.localizedDescription)"
                }
            }
            selectedOption = enhancementOptions.first
            viewModel.prompt = selectedOption?.prompt ?? ""
        }
        .onChange(of: selectedOption) { new in
                    viewModel.prompt = new?.prompt ?? ""
        
            guard new != nil else { return }          // ignore nil resets

            // Increment and persist the completed-generation counter
            completedGenerationCount += 1

            // Ask for a rating *only* on the 3rd generation, and only once
            if completedGenerationCount == 3 && !hasRequestedReview,
               let scene = UIApplication.shared.connectedScenes
                             .compactMap({ $0 as? UIWindowScene })
                             .first(where: { $0.activationState == .foregroundActive }) {

                SKStoreReviewController.requestReview(in: scene)
                hasRequestedReview = true                   // never prompt again
            }
        }
        
    }

    private func pickImage() {
        showingImagePicker = true
    }

    private func loadImage() {
        guard let img = inputImage else { return }
        viewModel.editedImage = img
    }

    private func saveImage() {
        guard let img = viewModel.editedImage else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        showSaveSuccessAlert = true
    }
}

// Top button row extracted
private struct TopButtons: View {
    let onReplace: () -> Void
    let onSave: () -> Void
    let topInset: CGFloat

    var body: some View {
        HStack {
            Button(action: onReplace) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            Spacer()
            Button(action: onSave) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
        }
        .padding(.top, topInset + 20)
    }
}
