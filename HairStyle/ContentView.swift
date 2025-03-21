import SwiftUI
import PhotosUI
import Vision

struct ContentView: View {
    @StateObject var viewModel = ImageEditingViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var contours: CGPath? = nil
    @State private var sliderPosition: CGFloat = 0.5  // Controls the slider position
    @State private var showSlider: Bool = false      // Controls visibility of the slider
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1) Full-screen image area (with before/after slider).
                GeometryReader { geometry in
                    ZStack {
                        if let originalImage = inputImage,
                           let modifiedImage = viewModel.editedImage {
                            // Original image, filling entire space
                            Image(uiImage: originalImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                            
                            // Modified image, also filling entire space,
                            // masked by the slider rectangle
                            Image(uiImage: modifiedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .mask(
                                    Rectangle()
                                        .frame(width: geometry.size.width * sliderPosition)
                                )
                            
                            // The vertical slider “handle”
                            if showSlider {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 4, height: geometry.size.height)
                                    .offset(
                                        x: (geometry.size.width * sliderPosition)
                                           - (geometry.size.width / 2)
                                    )
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let screenWidth = geometry.size.width
                                                sliderPosition = min(max(0, value.location.x / screenWidth), 1)
                                            }
                                    )
                                    .transition(.opacity)
                            }
                        }
                        else if let image = viewModel.editedImage {
                            // If we only have a modified image
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        }
                        else if !viewModel.textResult.isEmpty {
                            // If we only have text results
                            ScrollView {
                                Text(viewModel.textResult)
                                    .padding()
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color.gray.opacity(0.1))
                        }
                        else {
                            // No image selected
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .overlay(Text("No Image Selected"))
                        }
                    }
                    // Tap anywhere on the image area to show the slider
                    .onTapGesture {
                        withAnimation {
                            showSlider = true
                        }
                        hideSliderWithDelay()
                    }
                }
                .edgesIgnoringSafeArea(.all)  // Make sure it goes behind navigation bar if needed
                
                // 2) Bottom menu area with a small margin
                VStack {
                    // If we have two images, show the before/after slider
                    if inputImage != nil && viewModel.editedImage != nil {
                        Slider(value: $sliderPosition, in: 0...1)
                            .padding(.horizontal)
                    }
                    
                    // “Select Image” button
                    Button("Select Image") {
                        showingImagePicker = true
                    }
                    .padding(.top, 8)
                    
                    // Prompt text field
                    TextField("Enter prompt for image modification...", text: $viewModel.prompt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // “Clear Image” button
                    if viewModel.editedImage != nil {
                        Button("Clear Image") {
                            viewModel.editedImage = nil
                            viewModel.textResult = ""
                            contours = nil
                            showSlider = false
                        }
                        .padding(.top, 4)
                    }
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 8)
                    }
                    
                    // “Modify Image” button
                    Button("Modify Image") {
                        viewModel.editImage()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .disabled(viewModel.editedImage == nil || viewModel.prompt.isEmpty || viewModel.isLoading)
                }
                .padding(.bottom, 20) // Small margin at bottom
            }
            .navigationTitle("Image Modification")
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
        }
    }
    
    func loadImage() {
        if let selectedImage = inputImage {
            viewModel.editedImage = selectedImage
            viewModel.textResult = ""
            viewModel.errorMessage = ""
        }
    }
    
    
    // Auto-hide the slider after 3 seconds
    func hideSliderWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSlider = false
            }
        }
    }
}
