import SwiftUI
import PhotosUI
import Vision

struct ContentView: View {
    @StateObject var viewModel = ImageEditingViewModel()
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    // Slider controls
    @State private var sliderPosition: CGFloat = 0.5
    @State private var showSlider: Bool = false
    
    // State variable for showing a save-success alert
    @State private var showSaveSuccessAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if let image = inputImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 30)
                        .opacity(0.6)
                        .ignoresSafeArea()
                } else {
                    Color.pink.opacity(0.1).ignoresSafeArea()
                }
                
                VStack {
                    Spacer(minLength: 0)
                    
                    PhotoWithRefreshOverlay(
                        originalImage: inputImage,
                        editedImage: viewModel.editedImage,
                        depthMapImage: viewModel.depthMapImage,
                        sliderPosition: $sliderPosition,
                        showSlider: $showSlider,
                        onReplaceTap: {
                            showingImagePicker = true
                            Task {
                                loadImage()
                            }
                        },
                        onAddTap: { showingImagePicker = true },
                        onSaveTap: { showSaveSuccessAlert = false }
                    )
                    
                    Spacer(minLength: 0)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                BottomMenuView(
                    viewModel: viewModel,
                    inputImage: $inputImage,
                    sliderPosition: $sliderPosition
                )
                .frame(height: 160)
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { !viewModel.errorMessage.isEmpty },
                set: { _ in viewModel.errorMessage = "" }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Saved", isPresented: $showSaveSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Image saved successfully to your Photos.")
            }
            .toolbar {
                // Settings button in the upper left corner.
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView(viewModel: viewModel, sliderPosition: $sliderPosition)) {
                        Image(systemName: "gear")
                    }
                }
                // Feed icon in the upper right corner.
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FeedView()) {
                        Image(systemName: "square.grid.2x2")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .task {
            do {
                try await viewModel.loadModel()
            } catch {
                viewModel.errorMessage = "Failed to load model: \(error.localizedDescription)"
            }
        }
    }
    
    func loadImage() {
        if let selectedImage = inputImage {
            viewModel.editedImage = selectedImage
            viewModel.textResult = ""
            viewModel.errorMessage = ""
            
            // Generate the depth map asynchronously after selecting an image.
            Task {
                await viewModel.generateDepthMap(for: selectedImage)
            }
        }
    }
}
