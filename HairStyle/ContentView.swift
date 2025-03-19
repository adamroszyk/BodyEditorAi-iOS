import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject var viewModel = ImageEditingViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                // Display image or text result or placeholder
                if let image = viewModel.editedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .padding()
                } else if !viewModel.textResult.isEmpty {
                    ScrollView {
                        Text(viewModel.textResult)
                            .padding()
                    }
                    .frame(maxHeight: 300)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .overlay(Text("No Image Selected"))
                        .padding()
                }
                
                // Button to open the image picker
                Button("Select Image") {
                    showingImagePicker = true
                }
                .padding()
                
                // Text field for prompt
                TextField("Enter prompt for image modification...", text: $viewModel.prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Additional UI elements…
                if viewModel.editedImage != nil {
                    Button("Clear Image") {
                        viewModel.editedImage = nil
                        viewModel.textResult = ""
                    }
                    .padding(.top, 4)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
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
            .navigationTitle("Image Modification")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
            // Add alert that triggers when errorMessage is not empty
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
    
    // Load image into viewModel after selection
    func loadImage() {
        if let selectedImage = inputImage {
            viewModel.editedImage = selectedImage
            viewModel.textResult = ""
            viewModel.errorMessage = ""
        }
    }
}
