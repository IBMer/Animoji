//
//  RecordingStorage.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Manages storage and retrieval of Animoji recordings

import Foundation
import Observation

/// Manages persistent storage of recordings
@MainActor
@Observable
public final class RecordingStorage {
    // MARK: - Singleton

    public static let shared = RecordingStorage()

    // MARK: - Properties

    /// All stored recordings
    public private(set) var recordings: [RecordingModel] = []

    /// Maximum number of recordings to keep
    public var maxRecordings: Int = 5

    /// Storage directory for recordings
    private let storageDirectory: URL

    /// Metadata file URL
    private var metadataURL: URL {
        storageDirectory.appendingPathComponent("metadata.json")
    }

    // MARK: - Initialization

    private init() {
        // Create storage directory
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        storageDirectory = documentsPath.appendingPathComponent("Recordings")

        // Create directory if needed
        try? FileManager.default.createDirectory(
            at: storageDirectory,
            withIntermediateDirectories: true
        )

        // Load existing recordings
        loadRecordings()

        print("✅ RecordingStorage initialized at: \(storageDirectory.path)")
    }

    // MARK: - Save Recording

    /// Saves a new recording
    /// - Parameters:
    ///   - sourceURL: Source recording URL
    ///   - puppetName: Name of the puppet used
    ///   - duration: Recording duration
    /// - Returns: The saved recording model
    /// - Throws: FaceMojiError if save fails
    @discardableResult
    public func saveRecording(
        from sourceURL: URL,
        puppetName: String,
        duration: TimeInterval
    ) async throws -> RecordingModel {
        // Verify source exists
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw FaceMojiError.storageError(
                NSError(domain: "RecordingStorage", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Source file does not exist"
                ])
            )
        }

        // Generate unique filename
        let filename = generateFilename(for: puppetName)
        let destinationURL = storageDirectory.appendingPathComponent(filename)

        // Copy file to storage
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        } catch {
            throw FaceMojiError.storageError(error)
        }

        // Create recording model
        let recording = RecordingModel(
            fileURL: destinationURL,
            duration: duration,
            puppetName: puppetName
        )

        // Add to recordings list
        recordings.insert(recording, at: 0)

        // Enforce max recordings limit
        while recordings.count > maxRecordings {
            if let removed = recordings.popLast() {
                try? FileManager.default.removeItem(at: removed.fileURL)
                print("🗑️ Removed old recording: \(removed.fileURL.lastPathComponent)")
            }
        }

        // Save metadata
        saveMetadata()

        print("💾 Recording saved: \(filename)")
        return recording
    }

    // MARK: - Delete Recording

    /// Deletes a specific recording
    /// - Parameter recording: The recording to delete
    /// - Throws: FaceMojiError if deletion fails
    public func deleteRecording(_ recording: RecordingModel) throws {
        // Delete file
        do {
            try FileManager.default.removeItem(at: recording.fileURL)
        } catch {
            throw FaceMojiError.storageError(error)
        }

        // Remove from list
        recordings.removeAll { $0.id == recording.id }

        // Save metadata
        saveMetadata()

        print("🗑️ Recording deleted: \(recording.fileURL.lastPathComponent)")
    }

    /// Deletes all recordings
    public func deleteAllRecordings() {
        for recording in recordings {
            try? FileManager.default.removeItem(at: recording.fileURL)
        }

        recordings.removeAll()
        saveMetadata()

        print("🗑️ All recordings deleted")
    }

    // MARK: - Load/Save Metadata

    /// Loads recordings metadata from disk
    private func loadRecordings() {
        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            print("ℹ️ No existing recordings metadata")
            return
        }

        do {
            let data = try Data(contentsOf: metadataURL)
            let loadedRecordings = try JSONDecoder().decode([RecordingModel].self, from: data)

            // Filter out recordings whose files no longer exist
            recordings = loadedRecordings.filter { recording in
                FileManager.default.fileExists(atPath: recording.fileURL.path)
            }

            print("✅ Loaded \(recordings.count) recordings")

            // Save metadata again to remove deleted files
            if recordings.count != loadedRecordings.count {
                saveMetadata()
            }
        } catch {
            print("⚠️ Failed to load recordings: \(error)")
            recordings = []
        }
    }

    /// Saves recordings metadata to disk
    private func saveMetadata() {
        do {
            let data = try JSONEncoder().encode(recordings)
            try data.write(to: metadataURL)
            print("💾 Metadata saved (\(recordings.count) recordings)")
        } catch {
            print("⚠️ Failed to save metadata: \(error)")
        }
    }

    // MARK: - Utilities

    /// Generates a unique filename for a recording
    /// - Parameter puppetName: The puppet name
    /// - Returns: Unique filename with .mov extension
    private func generateFilename(for puppetName: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let uuid = UUID().uuidString.prefix(8)
        return "animoji_\(puppetName)_\(timestamp)_\(uuid).mov"
    }

    /// Gets the total storage size used by recordings
    /// - Returns: Total size in bytes
    public func getTotalStorageSize() -> Int64 {
        var totalSize: Int64 = 0

        for recording in recordings {
            if let size = recording.fileSize {
                totalSize += size
            }
        }

        return totalSize
    }

    /// Gets formatted total storage size
    public var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: getTotalStorageSize(), countStyle: .file)
    }

    // MARK: - Cleanup

    /// Removes recordings older than specified days
    /// - Parameter days: Number of days
    public func removeRecordingsOlderThan(days: Int) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let oldRecordings = recordings.filter { $0.date < cutoffDate }

        for recording in oldRecordings {
            try? deleteRecording(recording)
        }

        if !oldRecordings.isEmpty {
            print("🗑️ Removed \(oldRecordings.count) old recordings")
        }
    }

    /// Clears all data and resets storage
    public func reset() {
        deleteAllRecordings()

        // Delete metadata file
        try? FileManager.default.removeItem(at: metadataURL)

        // Recreate storage directory
        try? FileManager.default.createDirectory(
            at: storageDirectory,
            withIntermediateDirectories: true
        )

        print("🔄 Storage reset complete")
    }
}

// MARK: - Query Methods

extension RecordingStorage {
    /// Gets recordings for a specific puppet
    /// - Parameter puppetName: The puppet name
    /// - Returns: Array of recordings for that puppet
    public func getRecordings(for puppetName: String) -> [RecordingModel] {
        recordings.filter { $0.puppetName == puppetName }
    }

    /// Gets the most recent recording
    public var latestRecording: RecordingModel? {
        recordings.first
    }

    /// Checks if storage is near capacity
    public var isNearCapacity: Bool {
        recordings.count >= maxRecordings - 1
    }

    /// Gets the number of recordings
    public var recordingCount: Int {
        recordings.count
    }
}
