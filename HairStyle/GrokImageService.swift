//
//  GrokImageService.swift
//  BodyEditor3
//
//  Grok API service for image generation and understanding
//

import SwiftUI
import UIKit

// MARK: - Grok API Response Models
struct GrokImageResponse: Codable {
    let images: [GrokImage]?
    let created: Int?
    let model: String?
    let error: String?
}

struct GrokImage: Codable {
    let index: Int?
    let url: String?
    let b64_json: String?
    let revised_prompt: String?
}

// MARK: - Grok Image Service
class GrokImageService: ObservableObject {
    
    // Proxy endpoints for Grok API
    private let generateURL = URL(string: "https://gemini-proxy-flame.vercel.app/api/grok-image-generation")!
    private let understandURL = URL(string: "https://gemini-proxy-flame.vercel.app/api/grok-image-to-text")!
    
    @Published var isLoading = false
    @Published var generatedImage: UIImage?
    @Published var analysisText: String = ""
    @Published var errorMessage: String = ""
    @Published var revisedPrompt: String?
    
    // MARK: - Image Generation (Text + Optional Image → Image)
    /// Generate or edit an image using Grok's image generation API
    /// - Parameters:
    ///   - prompt: Text description of what to generate/edit
    ///   - inputImage: Optional input image for editing mode
    ///   - aspectRatio: Optional aspect ratio (e.g., "16:9", "4:3", "1:1")
    func generateImage(prompt: String, inputImage: UIImage? = nil, aspectRatio: String? = nil) async {
        print("🚀 [GrokService] Starting image generation...")
        print("🚀 [GrokService] URL: \(generateURL.absoluteString)")
        print("🚀 [GrokService] Prompt: \(prompt)")
        print("🚀 [GrokService] Has input image: \(inputImage != nil)")
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
            generatedImage = nil
            revisedPrompt = nil
        }
        
        var payload: [String: Any] = [
            "prompt": prompt,
            "n": 1,
            "response_format": "b64_json",
            "model": "grok-2-image-latest"
        ]
        
        // Add aspect ratio if provided
        if let aspectRatio = aspectRatio {
            payload["aspect_ratio"] = aspectRatio
        }
        
        // Add input image for editing if provided
        if let image = inputImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            payload["image"] = base64String
            print("🚀 [GrokService] Added input image, base64 length: \(base64String.count)")
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ [GrokService] Failed to serialize request payload")
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to serialize request"
            }
            return
        }
        
        print("🚀 [GrokService] Request payload size: \(jsonData.count) bytes")
        
        var request = URLRequest(url: generateURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 120 // 2 minute timeout for image generation
        
        print("🚀 [GrokService] Sending POST request to: \(generateURL.absoluteString)")
        print("🚀 [GrokService] HTTP Method: \(request.httpMethod ?? "nil")")
        print("🚀 [GrokService] Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [GrokService] Invalid response - not HTTPURLResponse")
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid response"
                }
                return
            }
            
            print("📥 [GrokService] Response status code: \(httpResponse.statusCode)")
            print("📥 [GrokService] Response headers: \(httpResponse.allHeaderFields)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 [GrokService] Response body (first 500 chars): \(String(responseString.prefix(500)))")
            }
            
            if httpResponse.statusCode != 200 {
                print("❌ [GrokService] Non-200 status code: \(httpResponse.statusCode)")
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMsg = errorJson["error"] as? String {
                    print("❌ [GrokService] API Error message: \(errorMsg)")
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "API Error: \(errorMsg)"
                    }
                } else {
                    let bodyString = String(data: data, encoding: .utf8) ?? "Unable to decode"
                    print("❌ [GrokService] Raw error body: \(bodyString)")
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "HTTP Error: \(httpResponse.statusCode) - \(bodyString)"
                    }
                }
                return
            }
            
            // Parse the response
            print("✅ [GrokService] Got 200 response, parsing...")
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("✅ [GrokService] Parsed JSON response keys: \(jsonResponse.keys)")
                
                // Log mode and model to verify edit vs generate
                if let mode = jsonResponse["mode"] as? String {
                    print("🎯 [GrokService] MODE: \(mode) (edit = image was used, generate = text only)")
                }
                if let model = jsonResponse["model"] as? String {
                    print("🎯 [GrokService] MODEL: \(model)")
                }
                if let raw = jsonResponse["raw"] as? [String: Any] {
                    print("🔍 [GrokService] Raw response keys: \(raw.keys)")
                    if let rawModel = raw["model"] as? String {
                        print("🔍 [GrokService] Raw model used: \(rawModel)")
                    }
                }
                
                if let images = jsonResponse["images"] as? [[String: Any]],
                   let firstImage = images.first {
                    print("✅ [GrokService] Found images array with \(images.count) images")
                    print("✅ [GrokService] First image keys: \(firstImage.keys)")
                    
                    // Try to get the image from b64_json
                    if let b64String = firstImage["b64_json"] as? String {
                        print("✅ [GrokService] Found b64_json, length: \(b64String.count)")
                        if let imageData = Data(base64Encoded: b64String),
                           let uiImage = UIImage(data: imageData) {
                            print("✅ [GrokService] Successfully decoded image from base64")
                            await MainActor.run {
                                self.generatedImage = uiImage
                                self.revisedPrompt = firstImage["revised_prompt"] as? String
                                self.isLoading = false
                            }
                            return
                        } else {
                            print("❌ [GrokService] Failed to decode base64 to image")
                        }
                    }
                    
                    // Try to get the image from URL
                    if let urlString = firstImage["url"] as? String,
                       let imageURL = URL(string: urlString) {
                        print("✅ [GrokService] Found image URL: \(urlString)")
                        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
                        if let uiImage = UIImage(data: imageData) {
                            print("✅ [GrokService] Successfully downloaded and decoded image from URL")
                            await MainActor.run {
                                self.generatedImage = uiImage
                                self.revisedPrompt = firstImage["revised_prompt"] as? String
                                self.isLoading = false
                            }
                            return
                        } else {
                            print("❌ [GrokService] Failed to decode downloaded image data")
                        }
                    }
                } else {
                    print("❌ [GrokService] No 'images' array found in response")
                }
            } else {
                print("❌ [GrokService] Failed to parse response as JSON")
            }
            
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to parse image from response"
            }
            
        } catch {
            print("❌ [GrokService] Network/Request error: \(error)")
            print("❌ [GrokService] Error description: \(error.localizedDescription)")
            await MainActor.run {
                isLoading = false
                errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Image Understanding (Image → Text)
    /// Analyze an image using Grok's vision model
    /// - Parameters:
    ///   - image: The image to analyze
    ///   - prompt: Optional prompt describing what to analyze (defaults to general description)
    func analyzeImage(image: UIImage, prompt: String? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = ""
            analysisText = ""
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to convert image"
            }
            return
        }
        
        let base64String = imageData.base64EncodedString()
        
        var payload: [String: Any] = [
            "image": base64String,
            "model": "grok-2-vision-latest"
        ]
        
        if let prompt = prompt {
            payload["prompt"] = prompt
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to serialize request"
            }
            return
        }
        
        var request = URLRequest(url: understandURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 60
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid response"
                }
                return
            }
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMsg = errorJson["error"] as? String {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "API Error: \(errorMsg)"
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    }
                }
                return
            }
            
            // Parse the response
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let text = jsonResponse["text"] as? String {
                await MainActor.run {
                    self.analysisText = text
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to parse response"
                }
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Reset
    func reset() {
        isLoading = false
        generatedImage = nil
        analysisText = ""
        errorMessage = ""
        revisedPrompt = nil
    }
}
