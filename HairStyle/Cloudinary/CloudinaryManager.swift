//
//  CloudinaryManager.swift
//  HairStyle
//
//  Created by adam on 25/03/2025.
//


import Cloudinary
import UIKit

struct CloudinaryManager {
    static let shared: CLDCloudinary = {
        let config = CLDConfiguration(
            cloudName: "dao9lckfd"
        )
        return CLDCloudinary(configuration: config)
    }()
    
    static func upload(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        let params = CLDUploadRequestParams().setFolder("photoGenerations").setTags(["myGen"])  // Add your chosen tag here

        CloudinaryManager.shared.createUploader().upload(data: imageData,
                                                         uploadPreset: "HairStyle01",
                                                         params: params) { result, error in
            if let error = error {
                print("Cloudinary upload error: \(error)")
                completion(nil)
            } else if let result = result {
                // Return the secure URL string for later use
                completion(result.secureUrl)
            }
        }
    }
}
