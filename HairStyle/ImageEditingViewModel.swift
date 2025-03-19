import SwiftUI

class ImageEditingViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var editedImage: UIImage? = nil
    @Published var textResult: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    // Proxy endpoint that securely handles the Gemini API key
    let apiURL = URL(string: "https://gemini-proxy-flame.vercel.app/api/gemini")!
    
    func editImage() {
        isLoading = true
        errorMessage = ""
        textResult = ""

        // Create payload for image generation
        let payload: [String: Any] = [
            "prompt": prompt,
            "image": true // Signal that we want image generation
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
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
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
            
            // First, try to parse response as JSON
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Response: \(jsonResponse)")
                    
                    // Check for error in response
                    if let error = jsonResponse["error"] as? [String: Any] {
                        let errorMessage = (error["message"] as? String) ?? "Unknown error"
                        DispatchQueue.main.async {
                            self.errorMessage = "API Error: \(errorMessage)"
                        }
                        return
                    }
                    
                    // Try to extract image data from response
                    if let candidates = jsonResponse["candidates"] as? [[String: Any]],
                       let candidate = candidates.first,
                       let content = candidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]] {
                        
                        // Process response parts
                        for part in parts {
                            // Handle text parts
                            if let text = part["text"] as? String {
                                DispatchQueue.main.async {
                                    self.textResult += text
                                }
                            }
                            
                            // Handle image parts
                            if let inlineData = part["inlineData"] as? [String: Any],
                               let data = inlineData["data"] as? String,
                               let imageData = Data(base64Encoded: data) {
                                
                                if let image = UIImage(data: imageData) {
                                    DispatchQueue.main.async {
                                        self.editedImage = image
                                    }
                                }
                            }
                        }
                    } else {
                        // If no candidates/parts found, just show the raw response
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
