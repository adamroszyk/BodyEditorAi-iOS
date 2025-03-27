import SwiftUI
import Vision
import CoreML
import CoreImage
import UIKit
import os


// MARK: - ImageEditingViewModel
class ImageEditingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var prompt: String = ""
    @Published var editedImage: UIImage? = nil
    @Published var textResult: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showPremiumAlert: Bool = false
    @Published var depthMapImage: UIImage? = nil  // Holds the generated depth map image
    
    // Depth model property
    var model: DepthAnythingV2SmallF16?
    
    // Proxy endpoint for your Gemini API key.
    let apiURL = URL(string: "https://gemini-proxy-flame.vercel.app/api/gemini")!
    
    // Define the target size expected by the model.
    private let targetSize = CGSize(width: 518, height: 392)
    
    // Shared CIContext instance.
    private let ciContext = CIContext()
    
    
    // New property: Public sharing checkbox state (default true)
    @Published var isPublicSharing: Bool = true
    
    // MARK: - Depth Model Loading & Depth Map Generation
    
    /// Loads your depth removal model.
    func loadModel() async throws {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly
        model = try DepthAnythingV2SmallF16(configuration: config)
    }
    
    
    func generateDepthMap(for image: UIImage) async {
        // Ensure the model is loaded.
        guard let depthModel = model else {
            await MainActor.run { self.errorMessage = "Model not loaded." }
            return
        }
        
        // Create a resized pixel buffer (518 x 392) using the helper extension.
        guard let resizedBuffer = image.resizedPixelBuffer(width: Int(targetSize.width), height: Int(targetSize.height)) else {
            await MainActor.run { self.errorMessage = "Failed to create resized pixel buffer." }
            return
        }
        
        // Debug: confirm the pixel buffer size.
        let w = CVPixelBufferGetWidth(resizedBuffer)
        let h = CVPixelBufferGetHeight(resizedBuffer)
        print("Pixel buffer is \(w)x\(h)")  // Should be 518x392
        
        do {
            // Run model inference synchronously.
            let prediction = try depthModel.prediction(image: resizedBuffer)
            let depthBuffer = prediction.depth
            let depthCI = CIImage(cvPixelBuffer: depthBuffer)
            
            if let cgImage = ciContext.createCGImage(depthCI, from: depthCI.extent) {
                let finalUIImage = UIImage(cgImage: cgImage)
                await MainActor.run {
                    self.depthMapImage = finalUIImage
                    print("Depth map generation successful")
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Depth model error: \(error.localizedDescription)"
            }
        }
    }

    
    
    func editImage() {
        guard let image = editedImage,
              let imageData = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "No valid image selected"
            }
            return
        }
        
        isLoading = true
        errorMessage = ""
        textResult = ""
        
        let payload: [String: Any] = [
            "prompt": prompt,
            "image": imageData
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to serialize request"
            }
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async { self.isLoading = false }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from server"
                }
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // (Handle API error responses)
                    if let errorDict = jsonResponse["error"] as? [String: Any] {
                        let errorMessage = (errorDict["message"] as? String) ?? "Unknown error"
                        DispatchQueue.main.async {
                            self.errorMessage = "API Error: \(errorMessage)"
                        }
                        return
                    }
                    
                    // Process text and inline data responses
                    if let candidates = jsonResponse["candidates"] as? [[String: Any]],
                       let candidate = candidates.first,
                       let content = candidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]] {
                        
                        for part in parts {
                            if let text = part["text"] as? String {
                                DispatchQueue.main.async {
                                    self.textResult += text
                                }
                            }
                            
                            if let inlineData = part["inlineData"] as? [String: Any],
                               let dataString = inlineData["data"] as? String,
                               let imageData = Data(base64Encoded: dataString),
                               let image = UIImage(data: imageData) {
                                
                                DispatchQueue.main.async {
                                    self.editedImage = image
                                }
                                
                                // Only share publicly if the toggle is on.
                                if self.isPublicSharing {
                                    CloudinaryManager.upload(image: image) { secureUrl in
                                        if let url = secureUrl {
                                            print("Image uploaded to Cloudinary: \(url)")
                                            // Optionally: save the URL for your feed if needed.
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                        DispatchQueue.main.async {
                            self.textResult = "Response: \(responseString)"
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    self.textResult = String(data: data, encoding: .utf8) ?? "Unable to display response"
                }
            }
        }.resume()
    }

    
    
    
}
