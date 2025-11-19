//
//  ContentViewModel.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Main view model for FaceMoji app using @Observable

import SwiftUI
import Observation

/// Main view model managing the app's state
@MainActor
@Observable
public final class ContentViewModel {
    // MARK: - Puppet State

    /// All available puppets
    public var availablePuppets: [PuppetModel] = []

    /// Currently selected puppet
    public var currentPuppet: PuppetModel?

    /// Whether puppets are loading
    public var isLoadingPuppets = false

    // MARK: - Recording State

    /// Current recording state
    public var recordingState: RecordingState = .idle

    /// Recording duration in seconds
    public var recordingDuration: TimeInterval = 0

    /// Whether currently recording
    public var isRecording: Bool {
        recordingState.isRecording
    }

    /// Whether in preview mode
    public var isPreviewing: Bool {
        recordingState.isPreviewing
    }

    // MARK: - UI State

    /// Background color for Animoji scene
    public var backgroundColor: Color = .black

    /// Selected background preset
    public var selectedBackground: Color.AnimojiBackground = .black {
        didSet {
            if !selectedBackground.isGradient {
                backgroundColor = selectedBackground.color
            }
        }
    }

    /// Whether settings view is shown
    public var showSettings = false

    /// Whether to show background picker
    public var showBackgroundPicker = false

    // MARK: - Error Handling

    /// Current error to display
    public var currentError: Error?

    /// Whether to show error alert
    public var showError = false

    /// Error message for display
    public var errorMessage: String? {
        currentError?.localizedDescription
    }

    // MARK: - Dependencies

    private let puppetManager: PuppetManager
    private var recordingTimer: Timer?

    // MARK: - Initialization

    public init(puppetManager: PuppetManager = .shared) {
        self.puppetManager = puppetManager
    }

    // MARK: - Puppet Management

    /// Loads all available puppets
    public func loadPuppets() async {
        guard !isLoadingPuppets else { return }

        isLoadingPuppets = true

        do {
            let puppets = try await puppetManager.loadAvailablePuppets()

            await MainActor.run {
                self.availablePuppets = puppets

                // Select first puppet by default
                if self.currentPuppet == nil, let first = puppets.first {
                    self.currentPuppet = first
                }

                self.isLoadingPuppets = false

                print("✅ Loaded \(puppets.count) puppets")
            }
        } catch {
            await MainActor.run {
                self.handleError(error)
                self.isLoadingPuppets = false
            }
        }
    }

    /// Selects a puppet
    /// - Parameter puppet: The puppet to select
    public func selectPuppet(_ puppet: PuppetModel) {
        // Don't switch puppet while recording
        guard !isRecording else {
            print("⚠️ Cannot switch puppet while recording")
            return
        }

        currentPuppet = puppet
        HapticManager.lightTap()

        print("👉 Selected puppet: \(puppet.name)")
    }

    /// Selects a puppet by item
    /// - Parameter item: The puppet item
    public func selectPuppet(_ item: PuppetItem) {
        guard let puppet = availablePuppets.first(where: { $0.name == item.rawValue }) else {
            return
        }
        selectPuppet(puppet)
    }

    // MARK: - Recording Control

    /// Toggles recording on/off
    public func toggleRecording() async {
        switch recordingState {
        case .idle:
            await startRecording()
        case .recording:
            await stopRecording()
        case .preview:
            // Can't toggle while in preview
            break
        }
    }

    /// Starts recording
    private func startRecording() async {
        // Check permissions first
        do {
            _ = try await PermissionManager.ensurePermissions()
        } catch {
            handleError(error)
            return
        }

        HapticManager.mediumTap()
        recordingState = .recording
        startRecordingTimer()

        print("🔴 Recording started")
    }

    /// Stops recording
    private func stopRecording() async {
        HapticManager.success()
        recordingState = .preview
        stopRecordingTimer()

        print("⏹️ Recording stopped")
    }

    /// Toggles preview playback
    public func togglePreview() {
        guard recordingState == .preview else { return }

        // This will be fully implemented in Sprint 5
        HapticManager.lightTap()
        print("▶️ Toggle preview")
    }

    /// Deletes the current recording
    public func deleteRecording() {
        guard recordingState == .preview else { return }

        HapticManager.warning()
        recordingState = .idle
        recordingDuration = 0

        print("🗑️ Recording deleted")
    }

    /// Exports the recording
    /// - Parameter url: The URL to export to
    public func exportRecording(to url: URL) async {
        // This will be fully implemented in Sprint 5
        HapticManager.success()
        print("💾 Export recording to: \(url.lastPathComponent)")
    }

    // MARK: - Recording Timer

    private func startRecordingTimer() {
        recordingDuration = 0

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.recordingDuration += 0.1
            }
        }
    }

    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    // MARK: - Background Management

    /// Changes the background color
    /// - Parameter background: The background preset
    public func changeBackground(_ background: Color.AnimojiBackground) {
        selectedBackground = background
        HapticManager.selection()

        print("🎨 Changed background to: \(background.displayName)")
    }

    // MARK: - Error Handling

    private func handleError(_ error: Error) {
        currentError = error
        showError = true
        HapticManager.error()

        print("❌ Error: \(error.localizedDescription)")
    }

    /// Clears the current error
    public func clearError() {
        currentError = nil
        showError = false
    }

    // MARK: - Permissions

    /// Checks if all required permissions are granted
    public func checkPermissions() async -> Bool {
        let status = PermissionManager.currentPermissionStatus
        return status.allGranted
    }

    /// Requests all required permissions
    public func requestPermissions() async {
        do {
            _ = try await PermissionManager.ensurePermissions()
            print("✅ All permissions granted")
        } catch {
            handleError(error)
        }
    }

    // MARK: - Cleanup

    deinit {
        stopRecordingTimer()
    }
}

// MARK: - Computed Properties

extension ContentViewModel {
    /// Formatted recording duration string (MM:SS.S)
    public var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        let decimals = Int((recordingDuration.truncatingRemainder(dividingBy: 1)) * 10)

        return String(format: "%02d:%02d.%d", minutes, seconds, decimals)
    }

    /// Whether the record button should be enabled
    public var canRecord: Bool {
        recordingState == .idle && currentPuppet != nil
    }

    /// Whether the preview controls should be shown
    public var showPreviewControls: Bool {
        recordingState == .preview
    }
}
