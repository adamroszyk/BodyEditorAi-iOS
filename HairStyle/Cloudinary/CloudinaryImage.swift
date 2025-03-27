import SwiftUI

struct CloudinaryImage: Decodable, Identifiable {
    let public_id: String
    let version: Int
    let format: String
    
    var id: String { public_id }
    
    // Construct the URL for the original uploaded image
    var imageUrl: String {
        "https://res.cloudinary.com/dao9lckfd/image/upload/v\(version)/\(public_id).\(format)"
    }
}

struct ImageListResponse: Decodable {
    let resources: [CloudinaryImage]
}

class FeedViewModel: ObservableObject {
    @Published var images: [CloudinaryImage] = []
    
    func loadImages() {
        // Replace "YOUR_CLOUD_NAME" and "myGenerations" with your actual values:
        guard let url = URL(string: "https://res.cloudinary.com/dao9lckfd/image/list/myGen.json") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching feed images: \(error)")
                return
            }
            if let data = data {
                do {
                    let listResponse = try JSONDecoder().decode(ImageListResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.images = listResponse.resources
                    }
                } catch {
                    print("Failed to decode Cloudinary image list: \(error)")
                }
            }
        }.resume()
    }
}
