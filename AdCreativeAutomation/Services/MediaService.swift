import Foundation
import UIKit
import AVFoundation

protocol MediaServiceProtocol {
    func processMedia(_ data: Data, type: CreativeType) async throws -> Data
    func generateThumbnail(from data: Data, type: CreativeType) async throws -> UIImage
    func optimizeForPlatform(_ data: Data, platform: AdPlatform) async throws -> Data
}

class MediaService: MediaServiceProtocol {
    private let imageProcessor: ImageProcessor
    private let videoProcessor: VideoProcessor
    
    init(
        imageProcessor: ImageProcessor = ImageProcessor(),
        videoProcessor: VideoProcessor = VideoProcessor()
    ) {
        self.imageProcessor = imageProcessor
        self.videoProcessor = videoProcessor
    }
    
    func processMedia(_ data: Data, type: CreativeType) async throws -> Data {
        switch type {
        case .image:
            return try await imageProcessor.process(data)
        case .video:
            return try await videoProcessor.process(data)
        case .carousel:
            // Process each image in the carousel
            return try await imageProcessor.process(data)
        case .collection:
            // Process collection of media
            return try await imageProcessor.process(data)
        }
    }
    
    func generateThumbnail(from data: Data, type: CreativeType) async throws -> UIImage {
        switch type {
        case .image:
            return try await imageProcessor.generateThumbnail(from: data)
        case .video:
            return try await videoProcessor.generateThumbnail(from: data)
        case .carousel, .collection:
            // Generate thumbnail from first item
            return try await imageProcessor.generateThumbnail(from: data)
        }
    }
    
    func optimizeForPlatform(_ data: Data, platform: AdPlatform) async throws -> Data {
        switch platform {
        case .facebook:
            return try await optimizeForFacebook(data)
        case .tiktok:
            return try await optimizeForTikTok(data)
        }
    }
    
    private func optimizeForFacebook(_ data: Data) async throws -> Data {
        // Apply Facebook-specific optimizations
        // For now, just return the original data
        return data
    }
    
    private func optimizeForTikTok(_ data: Data) async throws -> Data {
        // Apply TikTok-specific optimizations
        // For now, just return the original data
        return data
    }
}

class ImageProcessor {
    func process(_ data: Data) async throws -> Data {
        guard let image = UIImage(data: data) else {
            throw MediaError.invalidData
        }
        
        // Apply image processing
        // For now, just return the original data
        return data
    }
    
    func generateThumbnail(from data: Data) async throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw MediaError.invalidData
        }
        
        let size = CGSize(width: 300, height: 300)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

class VideoProcessor {
    func process(_ data: Data) async throws -> Data {
        // Process video data
        // For now, just return the original data
        return data
    }
    
    func generateThumbnail(from data: Data) async throws -> UIImage {
        guard let url = saveDataToTemporaryFile(data) else {
            throw MediaError.invalidData
        }
        
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 1)
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        
        try? FileManager.default.removeItem(at: url)
        
        return UIImage(cgImage: cgImage)
    }
    
    private func saveDataToTemporaryFile(_ data: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}

enum MediaError: LocalizedError {
    case invalidData
    case processingFailed
    case thumbnailGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid media data"
        case .processingFailed:
            return "Failed to process media"
        case .thumbnailGenerationFailed:
            return "Failed to generate thumbnail"
        }
    }
} 