import SwiftUI
import Vision

// MARK: - NormalizedContour
struct NormalizedContour {
    let normalizedPoints: [CGPoint]
}

// Because `MeshGradient` is available in iOS 18.0+,
// we mark this property accordingly.
@available(iOS 18.0, *)
private var meshGradientStrokeStyle: MeshGradient {
    MeshGradient(
        width: 3,
        height: 3,
        points: [
            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.8, 0.2], [1.0, 0.5],
            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
        ],
        colors: [
            .black, .black, .black,
            .blue,  .blue,  .blue,
            .green, .green, .green
        ]
    )
}

func detectNormalizedContours(in image: UIImage) -> [NormalizedContour]? {
    guard let cgImage = image.cgImage else { return nil }

    let request = VNDetectContoursRequest()
    
    // If you're targeting iOS 15 or higher:
    if #available(iOS 15.0, *) {
        // Increase contrastAdjustment to detect more subtle edges
        request.contrastAdjustment = 0.70  // Try 1.2, 1.5, 2.0, etc.
        
        // If the image background is lighter than the foreground
        request.detectDarkOnLight = false
        
        // Limit how large the image is scaled before detection
        request.maximumImageDimension = 512
    }
    
    
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
        try handler.perform([request])
        guard let observation = request.results?.first as? VNContoursObservation else { return nil }
        
        var contours: [NormalizedContour] = []
        
        for i in 0..<observation.topLevelContourCount {
            guard let contour = observation.topLevelContours[safe: i] else { continue }
            // Flip y-coordinates to match SwiftUI's top-left origin
            let points = contour.normalizedPoints.map {
                CGPoint(x: CGFloat($0.x), y: CGFloat(1 - $0.y))
            }
            contours.append(NormalizedContour(normalizedPoints: points))
        }
        
        return contours
    } catch {
        print("Error detecting contours: \(error)")
        return nil
    }
}

struct ContoursOverlay: View {
    let contours: [NormalizedContour]
    let dashPhase: CGFloat
    
    var body: some View {
        if #available(iOS 18.0, *) {
            // iOS 17+ uses MeshGradient as the stroke fill
            ContoursShape(contours: contours)
                .stroke(
                   
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: [
                            // Same 3x3 grid of control points
                            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                            [0.0, 0.5], [0.8, 0.2], [1.0, 0.5],
                            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                        ],
                        colors: [
                            // Top row
                            Color(red: 1.0, green: 0.28, blue: 0.45), // pink
                            Color(red: 1.0, green: 0.28, blue: 0.45),
                            Color(red: 1.0, green: 0.55, blue: 0.20), // orange

                            // Middle row
                            Color(red: 1.0, green: 0.28, blue: 0.45),
                            Color(red: 1.0, green: 0.55, blue: 0.20),
                            Color(red: 1.0, green: 0.55, blue: 0.20),

                            // Bottom row
                            Color(red: 1.0, green: 0.28, blue: 0.45),
                            Color(red: 1.0, green: 0.55, blue: 0.20),
                            Color(red: 1.0, green: 0.72, blue: 0.10)  // yellowish
                        ]
                    ),
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round,
                        dash: [20, 40],
                        dashPhase: dashPhase
                    )
                )
        } else {
            // Fallback for iOS < 17
            ContoursShape(contours: contours)
                .stroke(
                    Color.red,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round,
                        dash: [10, 20],
                        dashPhase: dashPhase
                    )
                )
        }
    }
}


// MARK: - ContoursShape
struct ContoursShape: Shape {
    let contours: [NormalizedContour]
    
    func path(in rect: CGRect) -> Path {
        var combined = Path()
        for contour in contours {
            guard let first = contour.normalizedPoints.first else { continue }
            combined.move(to: CGPoint(x: first.x * rect.width, y: first.y * rect.height))
            
            for point in contour.normalizedPoints.dropFirst() {
                combined.addLine(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
            }
            combined.closeSubpath()
        }
        return combined
    }
}

// MARK: - Safe Collection Subscript
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - resizeImage(image:targetSize:)
func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
}


// MARK: - AspectLimitedComparisonView
struct AspectLimitedComparisonView: View {
    let originalImage: UIImage?
    let modifiedImage: UIImage?
    let depthMapImage: UIImage?
    
    @Binding var sliderPosition: CGFloat
    @Binding var showSlider: Bool
    
    @State private var normalizedContours: [NormalizedContour] = []
    @State private var dashPhase: CGFloat = 0.0
    
    // Use MeshGradient stroke if iOS >= 18, else fallback to a solid color.
  
    let CustomStrokeFill: any ShapeStyle = {
        if #available(iOS 18.0, *) {
            // Return the MeshGradient (which *is* a ShapeStyle in iOS 17)
            return meshGradientStrokeStyle
        } else {
            // Fallback for older iOS
            return Color.red
        }
    }()
    var body: some View {
        GeometryReader { geometry in
            let displaySize = geometry.size
            
            ZStack {
                // 1) Original image in the background
                Image(uiImage: originalImage!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: displaySize.width, height: displaySize.height)
                
                if modifiedImage == originalImage {
                    // If 'modifiedImage' is the same as 'originalImage', show the depth overlay + contours
                    if let depth = depthMapImage {
                        // Resize depth to the same displayed size
                        let resizedDepth = resizeImage(image: depth, targetSize: displaySize)
                        
                        
                        Image(uiImage: resizedDepth)
                            .resizable()
                            .scaledToFit()
                            .frame(width: displaySize.width, height: displaySize.height)
                            .opacity(0.00)
                            .overlay(
                                ContoursOverlay(
                                    contours: normalizedContours,
                                    dashPhase: dashPhase
                                )
                            )
                            .onAppear {
                                // Detect contours in the resized depth image
                                if let contours = detectNormalizedContours(in: resizedDepth) {
                                    self.normalizedContours = contours
                                }
                                // Animate dash phase
                                withAnimation(
                                    Animation.linear(duration: 999).repeatForever(autoreverses: false)
                                ) {
                                    self.dashPhase -= 10000
                                }
                            }
                    }
                } else {
                    // Otherwise, just show the modified image
                    if let modified = modifiedImage {
                        Image(uiImage: modified)
                            .resizable()
                            .scaledToFit()
                            .frame(width: displaySize.width, height: displaySize.height)
                    }
                }
            }
            .onTapGesture {
                withAnimation {
                    showSlider.toggle()
                }
            }
        }
        // Force the overall aspect ratio to match the original
        .aspectRatio(originalImage!.size, contentMode: .fit)
    }
}
