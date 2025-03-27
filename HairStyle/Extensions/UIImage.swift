import SwiftUI
import Vision
import CoreML
import CoreImage
import UIKit
import os

// MARK: - CIImage Extension
extension CIImage {
    /// Returns a resized CIImage.
    func resized(to size: CGSize) -> CIImage {
        let scaleX = size.width / extent.width
        let scaleY = size.height / extent.height
        var outputImage = transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        // Reset the origin to (0,0)
        outputImage = outputImage.transformed(by: CGAffineTransform(translationX: -outputImage.extent.origin.x,
                                                                    y: -outputImage.extent.origin.y))
        return outputImage
    }
}
extension CIContext {
    /// Renders a CIImage to a new CVPixelBuffer using the specified pixel format.
    func render(_ image: CIImage, pixelFormat: OSType) -> CVPixelBuffer? {
        // Ensure valid dimensions by rounding up and enforcing a minimum value
        let width = max(Int(ceil(image.extent.width)), 1)
        let height = max(Int(ceil(image.extent.height)), 1)
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            pixelFormat,
            attrs as CFDictionary,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("CVPixelBufferCreate failed with status: \(status)")
            return nil
        }
        self.render(image, to: buffer)
        return buffer
    }
}


// Extension to enhance image contrast
extension UIImage {
    func applyingContrast(_ contrast: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(contrast, forKey: kCIInputContrastKey)
        filter?.setValue(0, forKey: kCIInputBrightnessKey)
        filter?.setValue(1.0, forKey: kCIInputSaturationKey)
        
        guard let outputImage = filter?.outputImage,
              let filteredCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: filteredCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

extension UIImage {
    func resizedPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pxBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary
        
        guard CVPixelBufferCreate(kCFAllocatorDefault,
                                  width,
                                  height,
                                  kCVPixelFormatType_32ARGB,
                                  attrs,
                                  &pxBuffer) == kCVReturnSuccess,
              let buffer = pxBuffer,
              let cgImage = self.cgImage else {
            return nil
        }
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        guard let ctx = context else { return nil }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        ctx.draw(cgImage, in: rect)
        
        return buffer
    }
}
