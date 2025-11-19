//
//  AnimojiRecorder.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Manages Animoji recording functionality using AvatarKit

import Foundation
import AVFoundation
import Observation

/// Delegate protocol for recording events
@MainActor
public protocol AnimojiRecorderDelegate: AnyObject {
    func recorderDidStartRecording(_ recorder: AnimojiRecorder)
    func recorderDidStopRecording(_ recorder: AnimojiRecorder)
    func recorderDidStartPreviewing(_ recorder: AnimojiRecorder)
    func recorderDidStopPreviewing(_ recorder: AnimojiRecorder)
    func recorderDidFinishPlaying(_ recorder: AnimojiRecorder)
    func recorder(_ recorder: AnimojiRecorder, didFailWithError error: Error)
}

/// Manages recording of Animoji videos
@MainActor
@Observable
public final class AnimojiRecorder {
    // MARK: - Singleton

    public static let shared = AnimojiRecorder()

    // MARK: - Properties

    /// Whether currently recording
    public private(set) var isRecording = false

    /// Whether currently previewing
    public private(set) var isPreviewing = false

    /// Current recording URL (temporary)
    public private(set) var currentRecordingURL: URL?

    /// Recording start time
    private var recordingStartTime: Date?

    /// Reference to the AVTRecordView
    private weak var recordView: NSObject?

    /// Delegate for recording events
    public weak var delegate: AnimojiRecorderDelegate?

    // MARK: - Initialization

    private init() {}

    // MARK: - Setup

    /// Sets the record view for recording operations
    /// - Parameter view: The AVTRecordView instance
    public func setRecordView(_ view: NSObject) {
        self.recordView = view
        print("✅ AnimojiRecorder: RecordView set")
    }

    // MARK: - Recording Control

    /// Starts recording an Animoji video
    /// - Throws: FaceMojiError if recording cannot start
    public func startRecording() async throws {
        guard !isRecording else {
            print("⚠️ Already recording")
            return
        }

        guard let recordView = recordView else {
            throw FaceMojiError.recordingFailed(
                NSError(domain: "AnimojiRecorder", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "RecordView not set"
                ])
            )
        }

        // Check permissions
        let permissions = await PermissionManager.requestAllPermissions()
        guard permissions.allGranted else {
            if !permissions.camera {
                throw FaceMojiError.cameraPermissionDenied
            } else {
                throw FaceMojiError.microphonePermissionDenied
            }
        }

        // Delete previous recording if exists
        if let previousURL = currentRecordingURL {
            try? FileManager.default.removeItem(at: previousURL)
            currentRecordingURL = nil
        }

        // Call AVTRecordView's startRecording method
        recordView.perform(Selector(("startRecording")))

        isRecording = true
        recordingStartTime = Date()

        delegate?.recorderDidStartRecording(self)
        print("🔴 Recording started")
    }

    /// Stops the current recording
    public func stopRecording() async {
        guard isRecording else {
            print("⚠️ Not currently recording")
            return
        }

        guard let recordView = recordView else {
            print("⚠️ RecordView not available")
            return
        }

        // Call AVTRecordView's stopRecording method
        recordView.perform(Selector(("stopRecording")))

        isRecording = false

        // Get the recorded file URL
        if let url = recordView.value(forKeyPath: "recordedFileURL") as? URL {
            currentRecordingURL = url
            print("💾 Recording saved to: \(url.lastPathComponent)")
        }

        // Calculate duration
        if let startTime = recordingStartTime {
            let duration = Date().timeIntervalSince(startTime)
            print("⏱️ Recording duration: \(String(format: "%.1f", duration))s")
        }

        recordingStartTime = nil
        delegate?.recorderDidStopRecording(self)
        print("⏹️ Recording stopped")
    }

    // MARK: - Preview Control

    /// Starts previewing the recorded video
    /// - Throws: FaceMojiError if no recording exists
    public func startPreviewing() async throws {
        guard let currentRecordingURL = currentRecordingURL else {
            throw FaceMojiError.invalidRecording
        }

        guard FileManager.default.fileExists(atPath: currentRecordingURL.path) else {
            throw FaceMojiError.invalidRecording
        }

        guard let recordView = recordView else {
            throw FaceMojiError.recordingFailed(
                NSError(domain: "AnimojiRecorder", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "RecordView not set"
                ])
            )
        }

        guard !isPreviewing else {
            print("⚠️ Already previewing")
            return
        }

        // Call AVTRecordView's startPreviewing method
        recordView.perform(Selector(("startPreviewing")))

        isPreviewing = true
        delegate?.recorderDidStartPreviewing(self)
        print("▶️ Preview started")
    }

    /// Stops previewing the recorded video
    public func stopPreviewing() {
        guard isPreviewing else {
            print("⚠️ Not currently previewing")
            return
        }

        guard let recordView = recordView else {
            print("⚠️ RecordView not available")
            return
        }

        // Call AVTRecordView's stopPreviewing method
        recordView.perform(Selector(("stopPreviewing")))

        isPreviewing = false
        delegate?.recorderDidStopPreviewing(self)
        print("⏸️ Preview stopped")
    }

    /// Handles when playback finishes
    internal func didFinishPlaying() {
        isPreviewing = false
        delegate?.recorderDidFinishPlaying(self)
        print("✅ Playback finished")
    }

    // MARK: - Export

    /// Exports the recorded video to a specific URL
    /// - Parameters:
    ///   - destinationURL: The destination URL
    ///   - options: Export options
    /// - Throws: FaceMojiError if export fails
    public func exportMovie(
        to destinationURL: URL,
        options: [String: Any]? = nil
    ) async throws {
        guard let currentRecordingURL = currentRecordingURL else {
            throw FaceMojiError.invalidRecording
        }

        guard let recordView = recordView else {
            throw FaceMojiError.exportFailed(
                NSError(domain: "AnimojiRecorder", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "RecordView not set"
                ])
            )
        }

        print("💾 Exporting to: \(destinationURL.lastPathComponent)")

        // Delete existing file if needed
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        // Export using AVTRecordView's method
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            // Create a completion handler
            let completionHandler: @convention(block) () -> Void = {
                print("✅ Export completed")
                continuation.resume()
            }

            // Call exportMovieToURL:options:completionHandler:
            let selector = Selector(("exportMovieToURL:options:completionHandler:"))
            if recordView.responds(to: selector) {
                // Use NSInvocation or perform with multiple arguments
                recordView.perform(selector, with: destinationURL, with: options, with: completionHandler)
            } else {
                // Fallback: just copy the file
                do {
                    try FileManager.default.copyItem(at: currentRecordingURL, to: destinationURL)
                    print("✅ File copied successfully")
                } catch {
                    print("❌ Export error: \(error)")
                }
                continuation.resume()
            }
        }
    }

    // MARK: - Cleanup

    /// Deletes the current recording
    public func deleteCurrentRecording() {
        if let url = currentRecordingURL {
            try? FileManager.default.removeItem(at: url)
            currentRecordingURL = nil
            print("🗑️ Current recording deleted")
        }
    }

    /// Cleans up all resources
    public func cleanup() {
        if isRecording {
            Task {
                await stopRecording()
            }
        }

        if isPreviewing {
            stopPreviewing()
        }

        deleteCurrentRecording()
        recordView = nil
    }

    // MARK: - Info

    /// Gets the duration of the current recording
    /// - Returns: Duration in seconds, or nil if no recording
    public func getCurrentRecordingDuration() -> TimeInterval? {
        guard let url = currentRecordingURL else { return nil }

        let asset = AVURLAsset(url: url)
        return asset.duration.seconds
    }

    /// Gets the file size of the current recording
    /// - Returns: File size in bytes, or nil if no recording
    public func getCurrentRecordingFileSize() -> Int64? {
        guard let url = currentRecordingURL else { return nil }

        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? Int64 else {
            return nil
        }

        return size
    }
}

// MARK: - Default Delegate Implementation

extension AnimojiRecorderDelegate {
    public func recorderDidStartRecording(_ recorder: AnimojiRecorder) {}
    public func recorderDidStopRecording(_ recorder: AnimojiRecorder) {}
    public func recorderDidStartPreviewing(_ recorder: AnimojiRecorder) {}
    public func recorderDidStopPreviewing(_ recorder: AnimojiRecorder) {}
    public func recorderDidFinishPlaying(_ recorder: AnimojiRecorder) {}
    public func recorder(_ recorder: AnimojiRecorder, didFailWithError error: Error) {}
}
