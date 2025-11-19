//
//  RecordingModel.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Data model representing a saved recording

import Foundation

/// Represents a saved Animoji recording
public struct RecordingModel: Identifiable, Codable, Sendable {
    // MARK: - Properties

    public let id: UUID
    public let date: Date
    public let fileURL: URL
    public let duration: TimeInterval
    public let puppetName: String

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        fileURL: URL,
        duration: TimeInterval,
        puppetName: String
    ) {
        self.id = id
        self.date = date
        self.fileURL = fileURL
        self.duration = duration
        self.puppetName = puppetName
    }

    // MARK: - Computed Properties

    /// Formatted duration string (MM:SS)
    public var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Formatted date string
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// File size in bytes
    public var fileSize: Int64? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let size = attributes[.size] as? Int64 else {
            return nil
        }
        return size
    }

    /// Formatted file size string
    public var formattedFileSize: String? {
        guard let size = fileSize else { return nil }

        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    // MARK: - File Management

    /// Checks if the recording file exists
    public var fileExists: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    /// Deletes the recording file from disk
    /// - Throws: Error if deletion fails
    public func deleteFile() throws {
        try FileManager.default.removeItem(at: fileURL)
    }
}
