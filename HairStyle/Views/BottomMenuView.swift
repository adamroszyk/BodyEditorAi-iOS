import SwiftUI
import StoreKit

struct BottomMenuView: View {
    @ObservedObject var viewModel: ImageEditingViewModel
    @Binding var inputImage: UIImage?
    @Binding var sliderPosition: CGFloat
    
    @State private var selectedCategory: String = "Hairstyle"
    @State private var selectedItemId: UUID?
    
    /// Tracks how many times the user has generated an image
    @State private var generationCount: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            categoriesSection
                .frame(height: 50)
                .padding(.horizontal)
            
            itemsSection
                .frame(height: 110)
        }
        .background(Color.clear)
        
        // Show a premium-limit alert if the user hits the generation limit
        .alert("Premium Limit", isPresented: $viewModel.showPremiumAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(BeautyDataPrompts.categories, id: \.self) { category in
                    Text(category)
                        .fontWeight(selectedCategory == category ? .bold : .regular)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedCategory == category ? Color.white.opacity(0.1) : Color.clear)
                        .foregroundColor(selectedCategory == category ? .white : .primary)
                        .shadow(color: selectedCategory == category ? Color.black.opacity(0.5) : Color.clear, radius: 0, x: 1, y: 1)
                        .shadow(color: selectedCategory == category ? Color.black.opacity(0.5) : Color.clear, radius: 0, x: -1, y: 1)
                        .shadow(color: selectedCategory == category ? Color.black.opacity(0.5) : Color.clear, radius: 0, x: 1, y: -1)
                        .shadow(color: selectedCategory == category ? Color.black.opacity(0.5) : Color.clear, radius: 0, x: -1, y: -1)
                        .cornerRadius(8)
                        .cornerRadius(8)
                        .onTapGesture {
                            withAnimation {
                                selectedCategory = category
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Items Section
    private var itemsSection: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: 16) {
                    // Loop through the items for the selected category
                    ForEach(BeautyDataPrompts.items[selectedCategory] ?? []) { item in
                        itemButton(for: item)
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: selectedCategory) { _ in
                scrollToFirst(proxy: proxy)
            }
            .onAppear {
                scrollToFirst(proxy: proxy)
            }
        }
    }
    
    // MARK: - Item Button
    private func itemButton(for item: HairItem) -> some View {
        VStack {
            // You can place an Image or systemName icon for the item here
            ZStack {
                if let imageName = item.image {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                } else {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                
                if viewModel.isLoading && selectedItemId == item.id {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 60, height: 60)
                        .background(Color.black.opacity(0.3))
                }
            }
            
            Text(item.name)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(selectedItemId == item.id ? Color.white.opacity(0.01) : Color.white)
        .cornerRadius(8)
        .onTapGesture {
            guard !viewModel.isLoading else { return }
            selectedItemId = item.id
            viewModel.prompt = item.prompt
            
            // Increment generation count
            generationCount += 0// Disabled for now, will add the payments later.
            
            // Check if user reached the limit (3 in this example)
            if generationCount >= 3 {
                // Show premium-limit message
                viewModel.errorMessage = "Premium limit reached. Upgrade to premium for unlimited images."
                viewModel.showPremiumAlert = true
                
                // Optionally request a StoreKit review
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
                
                // Because we've reached the limit, we skip calling editImage()
                // Instead we display the alert. You can handle logic as you see fit.
                
            } else {
                // If user is still within the limit, proceed with the image edit
                viewModel.editImage()
            }
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading && selectedItemId != item.id ? 0.5 : 1.0)
    }
    
    // MARK: - Helper: Scroll to First Item
    private func scrollToFirst(proxy: ScrollViewProxy) {
        if let firstId = BeautyDataPrompts.items[selectedCategory]?.first?.id {
            withAnimation {
                proxy.scrollTo(firstId, anchor: .leading)
            }
        }
    }
}
