//
//  AnimojiRecordView.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  UIKit wrapper for AVTRecordView from AvatarKit private framework

import UIKit
import SceneKit
import AVFoundation

/// UIKit view that wraps AVTRecordView for displaying and recording Animoji
@MainActor
public class AnimojiRecordView: UIView {
    // MARK: - Properties

    private let recordView: SCNView
    private let loader = AvatarKitLoader.shared
    private let recorder = AnimojiRecorder.shared

    /// The current puppet being displayed
    public private(set) var currentPuppet: PuppetModel?

    /// Whether face tracking is currently active
    public private(set) var isTracking = false

    /// Whether recording is in progress
    public var isRecording: Bool {
        recorder.isRecording
    }

    /// Whether preview is playing
    public var isPreviewing: Bool {
        recorder.isPreviewing
    }

    /// Background color for the scene
    public var sceneBackgroundColor: UIColor = .black {
        didSet {
            recordView.backgroundColor = sceneBackgroundColor
        }
    }

    // MARK: - Initialization

    public override init(frame: CGRect) {
        // Create AVTRecordView instance using private API
        recordView = loader.createRecordView()

        super.init(frame: frame)

        setupView()
        setupRecordView()
    }

    required init?(coder: NSCoder) {
        recordView = AvatarKitLoader.shared.createRecordView()

        super.init(coder: coder)

        setupView()
        setupRecordView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = true
    }

    private func setupRecordView() {
        // Configure the record view
        recordView.frame = bounds
        recordView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        recordView.backgroundColor = sceneBackgroundColor

        // Add as subview
        addSubview(recordView)

        // Set the record view in the recorder
        recorder.setRecordView(recordView as NSObject)

        // Start face tracking automatically
        startTracking()
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        recordView.frame = bounds
    }

    // MARK: - Puppet Management

    /// Sets the current puppet to display
    /// - Parameter puppet: The puppet model to display
    public func setPuppet(_ puppet: PuppetModel) {
        guard let avatarInstance = puppet.avatarInstance else {
            print("⚠️ Warning: Puppet has no avatar instance")
            return
        }

        // Set the avatar on the record view using KVC
        recordView.setValue(avatarInstance, forKeyPath: "avatar")
        currentPuppet = puppet

        print("✅ Set puppet: \(puppet.name)")
    }

    /// Sets the puppet by name
    /// - Parameter name: The name of the puppet
    public func setPuppetName(_ name: String) {
        guard let puppet = PuppetManager.shared.getPuppet(named: name) else {
            print("⚠️ Warning: Puppet '\(name)' not found")
            return
        }

        setPuppet(puppet)
    }

    /// Sets the puppet by PuppetItem enum
    /// - Parameter item: The puppet item
    public func setPuppet(item: PuppetItem) {
        setPuppetName(item.rawValue)
    }

    // MARK: - Face Tracking

    /// Starts face tracking
    private func startTracking() {
        // Face tracking is handled automatically by AVTRecordView
        // when it's added to the view hierarchy
        isTracking = true
    }

    /// Stops face tracking
    public func stopTracking() {
        isTracking = false
    }

    // MARK: - Recording

    /// Starts recording an Animoji video
    public func startRecording() async throws {
        try await recorder.startRecording()
    }

    /// Stops recording
    public func stopRecording() async {
        await recorder.stopRecording()
    }

    /// Starts previewing the recorded video
    public func startPreviewing() async throws {
        try await recorder.startPreviewing()
    }

    /// Stops previewing
    public func stopPreviewing() {
        recorder.stopPreviewing()
    }

    /// Exports the recorded movie to a URL
    /// - Parameters:
    ///   - url: The destination URL
    ///   - options: Export options
    public func exportMovie(
        toURL url: URL,
        options: [String: Any]? = nil
    ) async throws {
        try await recorder.exportMovie(to: url, options: options)
    }

    /// Gets the current recording URL
    public var currentRecordingURL: URL? {
        recorder.currentRecordingURL
    }

    // MARK: - Cleanup

    deinit {
        stopTracking()
        // Recorder cleanup is handled by AnimojiRecorder singleton
    }
}

// MARK: - Scene Access

extension AnimojiRecordView {
    /// Access to the underlying SceneKit view
    public var sceneView: SCNView {
        return recordView
    }

    /// Access to the SceneKit scene
    public var scene: SCNScene? {
        return recordView.scene
    }
}

// MARK: - Debug Helpers

extension AnimojiRecordView {
    /// Prints debug information about the current state
    public func printDebugInfo() {
        print("""

        === AnimojiRecordView Debug Info ===
        Current Puppet: \(currentPuppet?.name ?? "None")
        Is Tracking: \(isTracking)
        Is Recording: \(isRecording)
        Is Previewing: \(isPreviewing)
        Background Color: \(sceneBackgroundColor)
        Frame: \(frame)
        ===================================

        """)
    }
}
