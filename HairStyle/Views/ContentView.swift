//
//  ContentView.swift
//  PicUp
//  Updated 30-04-2025 – passes `isGenerating` flag to the photo overlay
//

import SwiftUI

struct ContentView: View {
    // MARK: – View-model
    @StateObject private var viewModel = ImageEditingViewModel()

    // MARK: – UI State
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var sliderPosition: CGFloat = 0.5
    @State private var showSlider = false
    @State private var showSaveSuccessAlert = false

    // Derived flag
    private var isGenerating: Bool { viewModel.isLoading }

    var body: some View {
        ZStack {
            // Background covers full screen
            backgroundView
                .ignoresSafeArea()

            // Photo (maintain aspect ratio, no distortion)
            PhotoWithRefreshOverlay(
                originalImage: inputImage,
                editedImage: viewModel.editedImage,
                depthMapImage: viewModel.depthMapImage,
                isGenerating: isGenerating,          // ← NEW
                sliderPosition: $sliderPosition,
                showSlider: $showSlider,
                onReplaceTap: pickImage,
                onAddTap: pickImage,
                onSaveTap: saveImage
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom Controls Panel
            VStack {
                Spacer()
                BottomMenuView(
                    viewModel: viewModel,
                    inputImage: $inputImage,
                    sliderPosition: $sliderPosition
                )
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .alert("Saved", isPresented: $showSaveSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Image saved successfully to your Photos.")
        }
        .onAppear {
            Task {
                do { try await viewModel.loadModel() }
                catch { viewModel.errorMessage = "Failed to load model: \(error.localizedDescription)" }
            }
        }
    }
}

// MARK: – Helpers
private extension ContentView {
    var backgroundView: some View {
        Group {
            if let image = inputImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 120)
                    .overlay(Color.black.opacity(0.4))
            } else {
                Color.black.opacity(0.6)
            }
        }
    }

    func pickImage() { showingImagePicker = true }

    func loadImage() {
        guard let selected = inputImage else { return }   // user cancelled
        viewModel.editedImage = selected
        viewModel.errorMessage = ""
        Task { await viewModel.generateDepthMap(for: selected) }
    }

    func saveImage() {
        guard let imageToSave = viewModel.editedImage else { return }
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        showSaveSuccessAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
