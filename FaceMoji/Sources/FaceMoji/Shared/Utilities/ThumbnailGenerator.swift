//
//  ThumbnailGenerator.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Generates thumbnails from video files

import UIKit
import AVFoundation

/// Generates thumbnails from video files
public actor ThumbnailGenerator {
    // MARK: - Singleton

    public static let shared = ThumbnailGenerator()

    // MARK: - Cache

    private var cache: [URL: UIImage] = [:]

    private init() {}

    // MARK: - Generation

    /// Generates a thumbnail for a video file
    /// - Parameters:
    ///   - url: The video file URL
    ///   - time: The time to capture (default: 0.5 seconds)
    ///   - size: The thumbnail size (default: 160x120)
    /// - Returns: UIImage thumbnail
    public func generateThumbnail(
        for url: URL,
        at time: TimeInterval = 0.5,
        size: CGSize = CGSize(width: 160, height: 120)
    ) async throws -> UIImage {
        // Check cache first
        if let cached = cache[url] {
            return cached
        }

        // Verify file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FaceMojiError.exportFailed(
                NSError(domain: "ThumbnailGenerator", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Video file not found"
                ])
            )
        }

        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)

        // Configure generator
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = size

        // Generate thumbnail
        let timestamp = CMTime(seconds: time, preferredTimescale: 600)

        do {
            let cgImage = try generator.copyCGImage(at: timestamp, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)

            // Cache for future use
            cache[url] = thumbnail

            return thumbnail
        } catch {
            throw FaceMojiError.exportFailed(error)
        }
    }

    /// Generates thumbnails for multiple videos
    /// - Parameters:
    ///   - urls: Array of video URLs
    ///   - time: The time to capture
    ///   - size: The thumbnail size
    /// - Returns: Dictionary mapping URLs to thumbnails
    public func generateThumbnails(
        for urls: [URL],
        at time: TimeInterval = 0.5,
        size: CGSize = CGSize(width: 160, height: 120)
    ) async -> [URL: UIImage] {
        var thumbnails: [URL: UIImage] = [:]

        await withTaskGroup(of: (URL, UIImage?).self) { group in
            for url in urls {
                group.addTask {
                    let thumbnail = try? await self.generateThumbnail(for: url, at: time, size: size)
                    return (url, thumbnail)
                }
            }

            for await (url, thumbnail) in group {
                if let thumbnail = thumbnail {
                    thumbnails[url] = thumbnail
                }
            }
        }

        return thumbnails
    }

    // MARK: - Cache Management

    /// Clears the thumbnail cache
    public func clearCache() {
        cache.removeAll()
    }

    /// Removes a specific thumbnail from cache
    /// - Parameter url: The video URL
    public func removeCachedThumbnail(for url: URL) {
        cache.removeValue(forKey: url)
    }

    /// Gets the cache size in bytes (approximate)
    public var cacheSize: Int {
        cache.values.reduce(0) { total, image in
            guard let data = image.pngData() else { return total }
            return total + data.count
        }
    }
}

// MARK: - Convenience Extension

extension RecordingModel {
    /// Generates a thumbnail for this recording
    /// - Returns: UIImage thumbnail
    public func generateThumbnail() async throws -> UIImage {
        try await ThumbnailGenerator.shared.generateThumbnail(for: fileURL)
    }
}
