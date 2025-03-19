import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject var viewModel = ImageEditingViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                // Display the edited image if available; if not, show text result (if any); otherwise, a placeholder
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
                
                // Error message display
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                // Button to open the image picker
                Button("Select Image") {
                    showingImagePicker = true
                }
                .padding()
                
                // Text field for entering the prompt
                TextField("Enter prompt for image modification...", text: $viewModel.prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Status indicator
                if viewModel.editedImage != nil {
                    Text("Image selected - Enter prompt to modify this image")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                // Button to clear the current image
                if viewModel.editedImage != nil {
                    Button("Clear Image") {
                        viewModel.editedImage = nil
                        viewModel.textResult = ""
                    }
                    .padding(.top, 4)
                }
                
                // Show a loading indicator when waiting for a response
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                // Button to trigger the API call
                Button("Modify Image") {
                    viewModel.editImage()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                // Disable if no image is selected, prompt is empty, or a request is in progress
                .disabled(viewModel.editedImage == nil || viewModel.prompt.isEmpty || viewModel.isLoading)
            }
            .navigationTitle("Image Modification")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
        }
    }
    
    // When an image is selected, load it into the ViewModel and clear any previous text result
    func loadImage() {
        if let selectedImage = inputImage {
            viewModel.editedImage = selectedImage
            viewModel.textResult = ""
            viewModel.errorMessage = ""
        }
    }
}
