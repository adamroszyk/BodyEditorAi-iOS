import SwiftUI

class ImageEditingViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var editedImage: UIImage? = nil
    @Published var textResult: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    // Proxy endpoint that securely handles your Gemini API key.
    let apiURL = URL(string: "https://gemini-proxy-flame.vercel.app/api/gemini")!
    
    func editImage() {
        // Ensure an image exists and encode it as base64.
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
        
        // Create payload for image modification.
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
                    print("Response: \(jsonResponse)")
                    
                    // Handle API errors.
                    if let error = jsonResponse["error"] as? [String: Any] {
                        let errorMessage = (error["message"] as? String) ?? "Unknown error"
                        DispatchQueue.main.async {
                            self.errorMessage = "API Error: \(errorMessage)"
                        }
                        return
                    }
                    
                    // Process response parts.
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
