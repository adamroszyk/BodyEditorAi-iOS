import SwiftUI
import Photos
import StoreKit

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("isPremium") var isPremium: Bool = false
    
    @State private var currentPage = 0
    private let totalPages = 6

    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Review Prompt (moved to first)
            ReviewPromptPageView(onContinue: { currentPage = 1 })
                .tag(0)
            
            // Page 2: Benefit 1
            OnboardingPageView(imageName: "star.fill",
                               title: "Amazing Features",
                               description: "Discover advanced AI editing to bring out your best self.",
                               onContinue: { currentPage = 2 })
                .tag(1)
            
            // Page 3: Benefit 2
            OnboardingPageView(imageName: "sparkles",
                               title: "Effortless Beauty",
                               description: "Instantly enhance your selfies with just a tap.",
                               onContinue: { currentPage = 3 })
                .tag(2)
            
            // Page 4: Benefit 3
            OnboardingPageView(imageName: "heart.fill",
                               title: "Share Your Style",
                               description: "Create stunning images and share your unique look with friends.",
                               onContinue: { currentPage = 4 })
                .tag(3)
            
            // Page 5: Photo Library Permission
            PhotoLibraryPermissionPageView(onContinue: { currentPage = 5 })
                .tag(4)
            
            // Page 6: Paywall
            PaywallPageView(isPremium: $isPremium, onComplete: completeOnboarding)
                .tag(5)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button(action: onContinue) {
                Text("Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }
}

struct PhotoLibraryPermissionPageView: View {
    @State private var permissionGranted = false
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(permissionGranted ? .green : .orange)
            Text("Photo Library Access")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("We need permission to save your edited photos to your library.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: {
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    DispatchQueue.main.async {
                        permissionGranted = (status == .authorized || status == .limited)
                    }
                }
            }) {
                Text(permissionGranted ? "Permission Granted" : "Grant Photo Library Access")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(permissionGranted ? Color.green : Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            Spacer()
            Button(action: onContinue) {
                Text("Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }
}

struct ReviewPromptPageView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "hand.thumbsup.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.purple)
            Text("Enjoying the App?")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("We’d love to hear your feedback. Please take a moment to rate us!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }) {
                Text("Rate Now")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            Spacer()
            Button(action: onContinue) {
                Text("Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }
}
