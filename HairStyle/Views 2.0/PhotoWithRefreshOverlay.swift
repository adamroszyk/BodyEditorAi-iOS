import SwiftUI

// MARK: – Photo / slider view
// MARK: – Photo / slider / empty‑state wrapper
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
    let onAvatarTap: () -> Void     // NEW
    let onSaveTap: () -> Void

    var body: some View {
        ZStack { contentView }
    }

    @ViewBuilder
    private var contentView: some View {
        if let orig = originalImage, let edit = editedImage {
            Image(uiImage: edit).resizable().scaledToFit()
        } else if let edit = editedImage {
            Image(uiImage: edit).resizable().scaledToFit()
        } else {
            EmptyStateView(
                onAddTap: onAddTap,
                onAvatarTap: onAvatarTap,
                isGenerating: isGenerating
            )
        }
    }
}

// MARK: – Empty state with two shiny buttons
struct EmptyStateView: View {
    let onAddTap: () -> Void
    let onAvatarTap: () -> Void
    let isGenerating: Bool

    @State private var shineAdd = false
    @State private var shineAvatar = false

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
                HStack(spacing: 20) {
                    shimmerButton(
                        systemIcon: "photo.fill.on.rectangle.fill",
                        label: "Add Photo",
                        action: onAddTap,
                        shine: $shineAdd
                    )
                    shimmerButton(
                        systemIcon: "person.crop.rectangle",
                        label: "Select AI Avatar",
                        action: onAvatarTap,
                        shine: $shineAvatar
                    )
                }
            }
            Spacer()
        }
    }

    // Shared shimmering‑button builder
    private func shimmerButton(systemIcon: String,
                               label: String,
                               action: @escaping () -> Void,
                               shine: Binding<Bool>) -> some View {
        Button(action: {
            shine.wrappedValue = false
            action()
        }) {
            VStack(spacing: 12) {
                Image(systemName: systemIcon)
                    .font(.system(size: 40))
                Text(label).font(.headline)
            }
            .foregroundColor(.black)
            .padding()
            .frame(width: 150)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: shine.wrappedValue ? 200 : -200)
                    .mask(RoundedRectangle(cornerRadius: 12))
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shine.wrappedValue = true
            }
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
