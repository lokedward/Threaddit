import Foundation
import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageProcessingService {
    static let shared = ImageProcessingService()
    
    private let context = CIContext()
    
    private init() {}
    
    /// Processes an array of UIImages in parallel, removing backgrounds.
    func processClothingImages(_ images: [UIImage]) async throws -> [UIImage] {
        return try await withThrowingTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, image) in images.enumerated() {
                group.addTask {
                    let processed = try await self.removeBackground(from: image)
                    // Sleep slightly to prevent Vision overload if not needed, but we rely on async tasks
                    return (index, processed)
                }
            }
            
            var results: [UIImage?] = Array(repeating: nil, count: images.count)
            for try await (index, image) in group {
                results[index] = image
            }
            
            return results.compactMap { $0 }
        }
    }
    
    /// Attempts to remove the background using Vision. Falls back to a high-contrast B&W filter on failure.
    private func removeBackground(from image: UIImage) async throws -> UIImage {
        // Fallback closure definition
        let applyFallback: () -> UIImage = {
            return self.applyHighContrastNoirFilter(to: image) ?? image
        }
        
        guard let cgImage = image.cgImage else {
            return applyFallback()
        }
        
        if #available(iOS 17.0, *) {
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
                guard let result = request.results?.first else {
                    return applyFallback()
                }
                
                let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                let maskCI = CIImage(cvPixelBuffer: mask)
                let originalCI = CIImage(cgImage: cgImage)
                
                let filter = CIFilter.blendWithMask()
                filter.inputImage = originalCI
                filter.maskImage = maskCI
                filter.backgroundImage = CIImage(color: .clear)
                
                guard let output = filter.outputImage,
                      let finalCGImage = self.context.createCGImage(output, from: output.extent) else {
                    return applyFallback()
                }
                
                return UIImage(cgImage: finalCGImage, scale: image.scale, orientation: image.imageOrientation)
                
            } catch {
                return applyFallback()
            }
        } else {
            return applyFallback()
        }
    }
    
    /// Applies an editorial high-contrast Noir filter as a stylistic fallback
    private func applyHighContrastNoirFilter(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let noir = CIFilter.photoEffectNoir()
        noir.inputImage = ciImage
        guard let noirOutput = noir.outputImage else { return nil }
        
        let contrast = CIFilter.colorControls()
        contrast.inputImage = noirOutput
        contrast.contrast = 1.2
        contrast.brightness = 0.05
        
        guard let finalOutput = contrast.outputImage,
              let cgImage = context.createCGImage(finalOutput, from: finalOutput.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
