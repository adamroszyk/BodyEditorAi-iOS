import SwiftUI

struct CatalogView: View {
    // MARK: — Prompt definitions shown in the horizontal panel
    private let promptItems: [PromptItem] = [
        
        .init(name: "🗑️ Remove Objects",
              prompt: "Erase unwanted objects or people from the background and intelligently rebuild the missing scenery for a clean shot"),

        .init(name: "👔 Professional Photo",
              prompt: "respectfully make the photo look more professional, like a corporate portrait with neutral backdrop, balanced lighting, and crisp details, keep the face details and photo composition the same"),

        .init(name: "🏖️ Body Tuner",
              prompt: "Refine waistline, smooth skin, and subtly enhance posture for a confident, natural swimsuit silhouette"),

        .init(name: "🐻 Wild Animal encounter",
              prompt: "Composite the subject embracing a photorealistic wild animal—matching lighting and shadows for a seamless, share-worthy moment"),

        .init(name: "🤵‍♂️ Classy Seaside",
              prompt: "Reimagine the portrait on Italy’s sun-soaked coast with Bond-style elegance: turquoise sea, retro speedboat, and golden light"),

        .init(name: "🛠️ Fix Bad Photo",
              prompt: "Rescue blurry, dark, or pixelated shots by sharpening details, balancing exposure, and reviving true-to-life colours"),

        .init(name: "💇‍♀️ Volume & Style",
              prompt: "Respectfully enhance the natural hair volume for a salon-perfect finish"),

        .init(name: "😁 Smile Boost",
              prompt: "Gently lift lip corners, brighten teeth, and align facial harmony to create a natural, confident smile"),

        .init(name: "📱 Phone Removal",
              prompt: "remove the smartphone from the image, make the pose natural, and add a subtle background, enhance the smile"),

        
        .init(name: "🌅 Golden-Hour Glow",
              prompt: "Infuse the scene with gentle sunset warmth, adding soft highlights and a cinematic amber tint"),
        .init(name: "💡 Fairy-Light Bokeh",
              prompt: "Scatter dreamy string-light bokeh in the background while keeping the subject tack-sharp"),
        .init(name: "📸 Mirror Selfie Cleanup",
              prompt: "Erase smudges, fingerprints, and edge glare for a spotless mirror-selfie finish"),
        .init(name: "🎞️ 35 mm Film Grain",
              prompt: "Overlay fine analog grain and subtle color shifts for an authentic film-camera feel"),
        .init(name: "🏠 Cozy Tone",
              prompt: "Warm up shadows and mid-tones for a soft, homely ambience that flatters skin tones"),
        .init(name: "📷 Depth Portrait",
              prompt: "Simulate DSLR-style depth of field, blurring cluttered closets so the subject pops"),
        .init(name: "🪞 Reflection Boost",
              prompt: "Enhance mirror reflections and add subtle vignetting to frame the subject elegantly"),
        .init(name: "🚪 Closet Fade",
              prompt: "Desaturate and soften wardrobe colors in the background to reduce visual noise"),
        .init(name: "🌬️ Soft-Breeze Hair",
              prompt: "Introduce a gentle hair movement and airy lightness for a candid, in-motion effect"),
        .init(name: "✨ Velvet Skin",
              prompt: "Smooth complexion just enough to mimic natural evening light, retaining realistic texture"),

        
            .init(name: "📱 Story Frame 9:16",
                  prompt: "Auto-crop to a perfect 9:16 ratio, extending blurred edges if needed so nothing important is lost"),
            .init(name: "🤳 Arm-Length Perspective",
                  prompt: "Correct wide-angle distortion from a front-camera lens for natural proportions and straighter lines"),
            .init(name: "🔆 Window Light Boost",
                  prompt: "Add soft, directional daylight from one side, creating gentle face highlights and clear catch-lights"),
            .init(name: "💫 Vertical Lens Flare",
                  prompt: "Overlay subtle golden flare streaks that run top-to-bottom to enhance back-lit selfies"),
            .init(name: "➿ Spiral Focus",
                  prompt: "Apply a delicate spiral blur emanating from corners to draw attention straight to the subject’s eyes"),
            .init(name: "🎞️ Film Burn Edge",
                  prompt: "Introduce warm, analog film-burn at the upper and lower edges for a retro story vibe"),
            .init(name: "🌫️ Haze Fade",
                  prompt: "Fade distant background elements with a soft vertical haze for extra depth and reduced clutter"),
            .init(name: "🚶‍♀️ Body Highlight",
                  prompt: "Add subtle rim lighting along the torso to flatter full-length mirror selfies and define shape"),
            .init(name: "📏 Slim Stretch",
                  prompt: "Gently elongate the canvas to add perceived height while preserving realistic body ratios"),
            .init(name: "🎭 Mood DuoTone",
                  prompt: "Blend two complementary warm tones from top to bottom, creating a stylish magazine-grade gradient"),

        .init(name: "👩‍💼 CEO Hair",
              prompt: "Give hair a sleek, power-professional style that’s perfect for LinkedIn headshots"),
        .init(name: "🧜‍♀️ Mermaid Waves",
              prompt: "Create soft mermaid-inspired waves with beachy texture—no heat needed"),
        .init(name: "💖 Barbie Pink",
              prompt: "Re-colour hair to a glossy, vibrant Barbie-pink while keeping strands defined"),
        .init(name: "🎮 Anime Glam",
              prompt: "Transform the photo into stylised anime art with cel-shaded hair and bright eyes"),
        .init(name: "🌌 Galactic Ombré",
              prompt: "Blend cosmic purples and blues into a seamless space-ombré gradient"),
        .init(name: "🚀 Big-Hair Boost",
              prompt: "Simulate a voluminous salon blow-out with maximum bounce and body"),
        .init(name: "🪞 Glass Skin",
              prompt: "Smooth and illuminate complexion for a pore-less glass-skin glow"),
        .init(name: "🫧 Anti-Frizz",
              prompt: "Erase frizz and flyaways for silky, perfectly polished strands"),
        .init(name: "💜 Neon Streaks",
              prompt: "Paint electrifying neon streaks through the hair for a cyber-punk vibe"),
        .init(name: "🦸‍♀️ Action Figure",
              prompt: "Render the subject as a hyper-detailed action figure with dramatic lighting"),
        .init(name: "🚫 Ex Eraser",
              prompt: "Remove an unwanted person from the shot while enhancing the remaining subject"),
        .init(name: "📸 Bokeh Pop",
              prompt: "Add creamy DSLR-style background bokeh so the subject pops instantly"),

        
        
        
        
        
        .init(name: "🧹 Remove Objects",
              prompt: "Remove the unwanted objects from the background keeping the subject intact"),
        .init(name: "🎨 Clear Background",
              prompt: "Replace the background with a plain, neutral colour"),
        .init(name: "🎞️ Blur Background",
              prompt: "Blur the background softly to emphasise the subject"),
        .init(name: "🌈 Vibrant Colours",
              prompt: "Enhance all colours for a vivid, saturated look while preserving skin tones"),
        .init(name: "🪄 Magic Retouch",
              prompt: "Subtly smooth skin and reduce blemishes for a polished finish"),
        .init(name: "✨ Highlight Pop",
              prompt: "Increase highlights and contrast to make the subject stand out"),
        .init(name: "🗑️ Object Eraser",
                  prompt: "Erase distracting items while keeping the main subject crisp"),

            // 2. Body tuning
            .init(name: "🏋️‍♂️ Body Sculpt",
                  prompt: "Subtly reshape and refine body contours for a balanced, natural look"),

            // 3. Face retouch
            .init(name: "💆‍♀️ Face Refine",
                  prompt: "Smooth skin and adjust facial features while preserving authenticity"),

            // 4. Teeth correction
            .init(name: "😁 Bright Smile",
                  prompt: "Whiten and perfect teeth for a confident, natural-looking grin"),

            // 5. Background removal
            .init(name: "✂️ Cut-Out",
                  prompt: "Remove the background entirely, delivering a clean transparent PNG"),

            // 6. Wrinkle removal
            .init(name: "🧴 Smooth Lines",
                  prompt: "Reduce wrinkles and fine lines for a refreshed appearance"),

            // 7. AI weight loss
            .init(name: "⚖️ Slim Fit",
                  prompt: "Trim the silhouette realistically for a slimmer profile"),

            // 8. AI Auto elegance
            .init(name: "✨ Auto Elegance",
                  prompt: "Automatically balance tone, lighting, and colour for an upscale finish"),

            // 9. AI Hair – haircut, colouring, restoration
            .init(name: "💇‍♀️ Hair Studio",
                  prompt: "Preview new haircuts, colours, or fuller volume with lifelike results"),

            // 10. HD Portrait
            .init(name: "📸 HD Portrait",
                  prompt: "Enhance portrait clarity and detail to high-definition quality"),

            // 11. One-touch makeup
            .init(name: "💄 Insta Makeup",
                  prompt: "Apply natural-looking makeup instantly, matched to skin tone"),

            // 12. 3D beauty
            .init(name: "🌀 3D Glam",
                  prompt: "Add subtle depth and contour for a dimensional beauty effect"),

            // 13. Hi-res
            .init(name: "🔍 Upscale 4K",
                  prompt: "Increase resolution up to 4K while preserving sharpness and detail"),

            // 14. Hair volumes
            .init(name: "🌟 Volume Boost",
                  prompt: "Add fullness and body to hair for a luxuriously voluminous style"),

            // 15. Beauty filters
            .init(name: "🎞️ Beauty Film",
                  prompt: "Apply a soft cinematic filter for an instant glow"),

            // 16. Face tools
            .init(name: "🛠️ Face Toolkit",
                  prompt: "Precisely adjust eyes, nose, lips and more with intuitive sliders")

    ]

    // MARK: — Data for grid sections
    private let bodyShapeItems: [(title: String, icon: String)] = [
        ("Chest Curve",   "Chest"),
        ("Flat Abs",      "Belly"),
        ("Buttocks+",     "Buttock"),
        ("Slim Waist",    "Waist"),
        ("Legs",          "Legs"),
        ("Muscles",       "Muscle")
    ]

    private let facialItems: [(title: String, icon: String)] = [
        ("Face",          "Face"),
        ("Eyes",          "Eyes"),
        ("Nose",          "Nose"),
        ("Lips",          "Lips"),
        ("Skin",          "Skin")
    ]

    private let hairAccessoryItems: [(title: String, icon: String)] = [
        ("Hair",          "Hair"),
        ("Jewellery",     "jewellery"),
        ("Eyewear",       "Eyewear")
    ]

    // Three flexible columns
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 16),
        count: 3
    )

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // MARK: — Grok Test Button (Top)
                    NavigationLink(destination: GrokTestView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "wand.and.stars")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Grok AI Lab")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("Test image generation & editing")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .opacity(0.6)
                        }
                        .foregroundColor(.white)
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
                    .padding(.horizontal)
                    
                    // MARK: — Header
                    HStack {
                        Text("BodyEditor Ai")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.pink, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Spacer()
                    }
                    .padding(.horizontal)

                    // MARK: — Prompt Panel
                    HorizontalPromptScroll(items: promptItems)
                        .padding(.top, 4)

                    // MARK: — Body Shape Section
                    SectionGrid(
                        title: "Body Shape",
                        items: bodyShapeItems,
                        columns: columns
                    )

                    // MARK: — Facial Section
                    SectionGrid(
                        title: "Facial",
                        items: facialItems,
                        columns: columns
                    )

                    // MARK: — Hair & Accessories Section
                    SectionGrid(
                        title: "Hair & Accessories",
                        items: hairAccessoryItems,
                        columns: columns
                    )
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.14, green: 0.13, blue: 0.13).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

// MARK: — Section Grid (unchanged)
private struct SectionGrid: View {
    let title: String
    let items: [(title: String, icon: String)]
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                ForEach(items, id: \ .title) { item in
                    NavigationLink(
                        destination: GenView(section: item.icon)
                    ) {
                        VStack(spacing: 8) {
                            // Circular icon background
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 70, height: 70)
                                    .shadow(color: Color.white.opacity(0.2),
                                            radius: 6,
                                            x: 0,
                                            y: 0)

                                Image(item.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            }

                            Text(item.title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
            .preferredColorScheme(.dark)
    }
}
