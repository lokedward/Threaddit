// ImageStorageService.swift
// Handles saving/loading images to/from the Documents directory

import Foundation
import UIKit

class ImageStorageService {
    static let shared = ImageStorageService()
    
    private let fileManager = FileManager.default
    private let imageDirectory: URL
    
    private init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imageDirectory = documentsPath.appendingPathComponent("ClothingImages", isDirectory: true)
        
        // Create the directory if it doesn't exist
        if !fileManager.fileExists(atPath: imageDirectory.path) {
            try? fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// Save an image with compression and return the UUID
    func saveImage(_ image: UIImage, withID id: UUID = UUID()) -> UUID? {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let fileURL = imageDirectory.appendingPathComponent("\(id.uuidString).jpg")
        
        do {
            try data.write(to: fileURL)
            return id
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    /// Load an image by its UUID
    func loadImage(withID id: UUID) -> UIImage? {
        let fileURL = imageDirectory.appendingPathComponent("\(id.uuidString).jpg")
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    /// Delete an image by its UUID
    func deleteImage(withID id: UUID) {
        let fileURL = imageDirectory.appendingPathComponent("\(id.uuidString).jpg")
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Get all image file URLs (for export)
    func getAllImageURLs() -> [URL] {
        guard let contents = try? fileManager.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil) else {
            return []
        }
        return contents.filter { $0.pathExtension == "jpg" }
    }
}
