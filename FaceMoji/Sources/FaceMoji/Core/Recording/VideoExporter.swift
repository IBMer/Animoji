//
//  VideoExporter.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Handles video export and conversion

import Foundation
import AVFoundation
import UIKit

/// Video export quality presets
public enum VideoExportQuality {
    case low
    case medium
    case high
    case original

    var avAssetExportPreset: String {
        switch self {
        case .low:
            return AVAssetExportPreset640x480
        case .medium:
            return AVAssetExportPreset960x540
        case .high:
            return AVAssetExportPreset1920x1080
        case .original:
            return AVAssetExportPresetPassthrough
        }
    }

    var displayName: String {
        switch self {
        case .low:
            return "Low (480p)"
        case .medium:
            return "Medium (540p)"
        case .high:
            return "High (1080p)"
        case .original:
            return "Original"
        }
    }
}

/// Manages video export operations
public actor VideoExporter {
    // MARK: - Singleton

    public static let shared = VideoExporter()

    private init() {}

    // MARK: - Export to Video

    /// Exports a video with specified quality
    /// - Parameters:
    ///   - sourceURL: Source video URL
    ///   - destinationURL: Destination URL
    ///   - quality: Export quality preset
    ///   - progress: Progress callback (0.0 - 1.0)
    /// - Throws: FaceMojiError if export fails
    public func exportVideo(
        from sourceURL: URL,
        to destinationURL: URL,
        quality: VideoExportQuality = .high,
        progress: (@Sendable (Double) -> Void)? = nil
    ) async throws {
        // Verify source exists
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw FaceMojiError.exportFailed(
                NSError(domain: "VideoExporter", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Source file does not exist"
                ])
            )
        }

        // Delete destination if exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        // Create asset
        let asset = AVURLAsset(url: sourceURL)

        // Create export session
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: quality.avAssetExportPreset
        ) else {
            throw FaceMojiError.exportFailed(
                NSError(domain: "VideoExporter", code: -2, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to create export session"
                ])
            )
        }

        exportSession.outputURL = destinationURL
        exportSession.outputFileType = .mov

        // Monitor progress
        let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()

        let progressTask = Task { @MainActor in
            for await _ in progressTimer.values {
                let currentProgress = Double(exportSession.progress)
                progress?(currentProgress)

                if exportSession.status != .exporting {
                    break
                }
            }
        }

        // Export
        await exportSession.export()

        progressTask.cancel()

        // Check result
        switch exportSession.status {
        case .completed:
            print("✅ Video exported successfully to: \(destinationURL.lastPathComponent)")

        case .failed:
            if let error = exportSession.error {
                throw FaceMojiError.exportFailed(error)
            } else {
                throw FaceMojiError.exportFailed(
                    NSError(domain: "VideoExporter", code: -3, userInfo: [
                        NSLocalizedDescriptionKey: "Export failed with unknown error"
                    ])
                )
            }

        case .cancelled:
            throw FaceMojiError.exportFailed(
                NSError(domain: "VideoExporter", code: -4, userInfo: [
                    NSLocalizedDescriptionKey: "Export was cancelled"
                ])
            )

        default:
            throw FaceMojiError.exportFailed(
                NSError(domain: "VideoExporter", code: -5, userInfo: [
                    NSLocalizedDescriptionKey: "Unexpected export status: \(exportSession.status.rawValue)"
                ])
            )
        }
    }

    // MARK: - Copy Video

    /// Copies a video file to a new location
    /// - Parameters:
    ///   - sourceURL: Source video URL
    ///   - destinationURL: Destination URL
    /// - Throws: FaceMojiError if copy fails
    public func copyVideo(
        from sourceURL: URL,
        to destinationURL: URL
    ) throws {
        // Verify source exists
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw FaceMojiError.exportFailed(
                NSError(domain: "VideoExporter", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Source file does not exist"
                ])
            )
        }

        // Delete destination if exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        // Copy file
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

        print("✅ Video copied to: \(destinationURL.lastPathComponent)")
    }

    // MARK: - Video Info

    /// Gets information about a video file
    /// - Parameter url: Video URL
    /// - Returns: Video metadata
    public func getVideoInfo(for url: URL) async -> VideoInfo? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        let asset = AVURLAsset(url: url)

        guard let track = try? await asset.loadTracks(withMediaType: .video).first else {
            return nil
        }

        let duration = try? await asset.load(.duration)
        let naturalSize = try? await track.load(.naturalSize)
        let frameRate = try? await track.load(.nominalFrameRate)

        let fileSize: Int64? = {
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let size = attributes[.size] as? Int64 else {
                return nil
            }
            return size
        }()

        return VideoInfo(
            url: url,
            duration: duration?.seconds ?? 0,
            size: naturalSize ?? .zero,
            frameRate: frameRate ?? 0,
            fileSize: fileSize ?? 0
        )
    }

    // MARK: - GIF Export (Phase 2 - Stub)

    /// Exports video to animated GIF (Future implementation)
    /// - Parameters:
    ///   - sourceURL: Source video URL
    ///   - destinationURL: Destination GIF URL
    ///   - frameRate: Frames per second (default: 10)
    ///   - maxSize: Maximum dimension (default: 480)
    /// - Note: This is a stub for future implementation
    public func exportToGIF(
        from sourceURL: URL,
        to destinationURL: URL,
        frameRate: Int = 10,
        maxSize: CGFloat = 480
    ) async throws {
        // This will be implemented in a future sprint
        throw FaceMojiError.exportFailed(
            NSError(domain: "VideoExporter", code: -100, userInfo: [
                NSLocalizedDescriptionKey: "GIF export not yet implemented"
            ])
        )
    }
}

// MARK: - Video Info

/// Information about a video file
public struct VideoInfo: Sendable {
    public let url: URL
    public let duration: TimeInterval
    public let size: CGSize
    public let frameRate: Float
    public let fileSize: Int64

    public var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    public var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    public var resolution: String {
        "\(Int(size.width))×\(Int(size.height))"
    }
}
