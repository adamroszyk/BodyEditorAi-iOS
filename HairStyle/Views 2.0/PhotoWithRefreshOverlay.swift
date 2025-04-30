import SwiftUI

// MARK: – Photo / slider view
 struct PhotoWithRefreshOverlay: View {
    // Inputs
    let originalImage: UIImage?
    let editedImage: UIImage?
    let depthMapImage: UIImage?
    let isGenerating: Bool
    @Binding var sliderPosition: CGFloat
    @Binding var showSlider: Bool
    let onReplaceTap: () -> Void
    let onAddTap: () -> Void
    let onSaveTap: () -> Void

    // Zoom / pan state omitted for brevity – unchanged from earlier version

    var body: some View {
        ZStack {
            contentView
        }
    }

    @ViewBuilder private var contentView: some View {
        if let orig = originalImage, let edit = editedImage {
            Image(uiImage: edit).resizable().scaledToFit()
        } else if let edit = editedImage {
            Image(uiImage: edit).resizable().scaledToFit()
        } else {
            EmptyStateView(onAddTap: onAddTap, isGenerating: isGenerating)
        }
    }
}

// MARK: – Empty state
private struct EmptyStateView: View {
    let onAddTap: () -> Void
    let isGenerating: Bool

    var body: some View {
        VStack {
            Spacer()
            if isGenerating {
                Text(LoadingMessages.random())
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
            } else {
                Button(action: onAddTap) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.fill.on.rectangle.fill").font(.system(size: 40))
                        Text("Add Image +").font(.headline)
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            }
            Spacer()
        }
    }
}

// MARK: – Stub generation worker
 enum ImageEditingWorker {
    static func generate(input: UIImage, prompt: String) async -> UIImage? {
        let vm = ImageEditingViewModel()
        do {
            try await vm.loadModel()
            vm.editedImage = input
            vm.prompt = prompt
            await MainActor.run { vm.editImage() }
            while await MainActor.run(body: { vm.isLoading }) {
                try? await Task.sleep(for: .milliseconds(100))
            }
            return await MainActor.run(body: { vm.editedImage })
        } catch {
            print("Generation failed: \(error)")
            return nil
        }
    }
}
