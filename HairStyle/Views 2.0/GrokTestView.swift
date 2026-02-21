//
//  GrokTestView.swift
//  BodyEditor3
//
//  Test view for Grok image generation and editing API
//

import SwiftUI

struct GrokTestView: View {
    
    // MARK: - State
    @StateObject private var grokService = GrokImageService()
    
    @State private var inputImage: UIImage?
    @State private var prompt: String = ""
    @State private var showingImagePicker = false
    @State private var showingAvatarPicker = false
    @State private var showSaveSuccessAlert = false
    
    // Pre-bundled demo avatars
    private var builtInAvatars: [UIImage] = {
        (1...23).compactMap { UIImage(named: String(format: "Persona%05d", $0)) }
    }()
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Quick prompts for testing
    private let quickPrompts = [
        "Make this person look like a superhero",
        "Add a beautiful sunset background",
        "Make the person look 10 years younger",
        "Add professional studio lighting",
        "Transform into an oil painting style",
        "Add a sci-fi futuristic background"
    ]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.14, green: 0.13, blue: 0.13)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Image Selection Area
                        imageSelectionArea
                        
                        // Prompt Input
                        promptInputSection
                        
                        // Quick Prompts
                        quickPromptsSection
                        
                        // Generate Button
                        generateButton
                        
                        // Result Section
                        if grokService.generatedImage != nil || !grokService.errorMessage.isEmpty {
                            resultSection
                        }
                        
                        // Revised Prompt (if any)
                        if let revised = grokService.revisedPrompt, !revised.isEmpty {
                            revisedPromptSection(revised)
                        }
                    }
                    .padding()
                }
            }
            
            // Loading Overlay
            if grokService.isLoading {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .sheet(isPresented: $showingAvatarPicker) {
            AvatarPickerView(
                avatars: builtInAvatars,
                onSelect: { ui in
                    inputImage = ui
                    showingAvatarPicker = false
                },
                onCancel: { showingAvatarPicker = false }
            )
        }
        .alert("Saved", isPresented: $showSaveSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Image saved to Photos")
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Grok AI Test")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding()
    }
    
    // MARK: - Image Selection Area
    private var imageSelectionArea: some View {
        VStack(spacing: 16) {
            Text("Input Image (Optional)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let image = inputImage {
                // Show selected image
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                        .cornerRadius(16)
                    
                    // Clear button
                    Button(action: { inputImage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
            } else {
                // Image selection buttons
                HStack(spacing: 16) {
                    imageButton(
                        icon: "photo.fill.on.rectangle.fill",
                        label: "Add Photo",
                        action: { showingImagePicker = true }
                    )
                    
                    imageButton(
                        icon: "person.crop.rectangle",
                        label: "AI Avatar",
                        action: { showingAvatarPicker = true }
                    )
                }
            }
            
            Text("Without an image, Grok will generate from text only")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
    
    private func imageButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Prompt Input Section
    private var promptInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prompt")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Describe what you want to create or edit...", text: $prompt, axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
                .lineLimit(3...6)
        }
    }
    
    // MARK: - Quick Prompts Section
    private var quickPromptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Prompts")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickPrompts, id: \.self) { quickPrompt in
                        Button(action: { prompt = quickPrompt }) {
                            Text(quickPrompt)
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(prompt == quickPrompt ? 
                                              Color.blue.opacity(0.8) : 
                                              Color.black.opacity(0.5))
                                )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Generate Button
    private var generateButton: some View {
        Button(action: generateImage) {
            HStack {
                Image(systemName: "wand.and.stars")
                Text(inputImage != nil ? "Edit with Grok" : "Generate with Grok")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .pink]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(prompt.isEmpty || grokService.isLoading)
        .opacity(prompt.isEmpty ? 0.5 : 1.0)
    }
    
    // MARK: - Result Section
    private var resultSection: some View {
        VStack(spacing: 16) {
            Text("Result")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !grokService.errorMessage.isEmpty {
                // Error display
                Text(grokService.errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(12)
            }
            
            if let resultImage = grokService.generatedImage {
                // Result image
                Image(uiImage: resultImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(16)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: saveImage) {
                        Label("Save", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: shareImage) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                
                // Use as input button
                Button(action: { inputImage = resultImage }) {
                    Label("Use as Input", systemImage: "arrow.uturn.left")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
    
    // MARK: - Revised Prompt Section
    private func revisedPromptSection(_ revised: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grok's Revised Prompt")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(revised)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Generating with Grok AI...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("This may take up to 60 seconds")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
        }
    }
    
    // MARK: - Actions
    private func generateImage() {
        Task {
            await grokService.generateImage(
                prompt: prompt,
                inputImage: inputImage
            )
        }
    }
    
    private func saveImage() {
        guard let image = grokService.generatedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSaveSuccessAlert = true
    }
    
    private func shareImage() {
        guard let image = grokService.generatedImage else { return }
        let av = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        UIApplication.shared.windows.first?.rootViewController?
            .present(av, animated: true)
    }
}

// MARK: - Preview
struct GrokTestView_Previews: PreviewProvider {
    static var previews: some View {
        GrokTestView()
            .preferredColorScheme(.dark)
    }
}
