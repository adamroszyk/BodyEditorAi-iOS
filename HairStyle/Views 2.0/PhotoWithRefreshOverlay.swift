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


struct EmptyStateView: View {
    let onAddTap: () -> Void
    let isGenerating: Bool

    @State private var shineAdd = false

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
                Button(action: {
                    shineAdd = false
                    onAddTap()
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.system(size: 40))
                        Text("Add Image +")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    // shimmer overlay
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.4), Color.white.opacity(0.1)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: shineAdd ? 200 : -200)
                            .mask(RoundedRectangle(cornerRadius: 12))
                    )
                }
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        shineAdd = true
                    }
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
                if #available(iOS 16.0, *) {
                    try? await Task.sleep(for: .milliseconds(100))
                } else {
                    // Fallback on earlier versions
                }
            }
            return await MainActor.run(body: { vm.editedImage })
        } catch {
            print("Generation failed: \(error)")
            return nil
        }
    }
}
