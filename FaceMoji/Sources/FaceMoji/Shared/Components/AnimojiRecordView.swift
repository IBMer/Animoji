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

    /// The current puppet being displayed
    public private(set) var currentPuppet: PuppetModel?

    /// Whether face tracking is currently active
    public private(set) var isTracking = false

    /// Whether recording is in progress
    public private(set) var isRecording = false

    /// Whether preview is playing
    public private(set) var isPreviewing = false

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

    // MARK: - Recording (Stub implementations for Sprint 2)

    /// Starts recording an Animoji video
    /// - Note: Full implementation will be added in Sprint 5
    public func startRecording() {
        guard !isRecording else { return }

        // Call private API method
        recordView.perform(Selector(("startRecording")))
        isRecording = true

        print("🔴 Recording started")
    }

    /// Stops recording
    /// - Note: Full implementation will be added in Sprint 5
    public func stopRecording() {
        guard isRecording else { return }

        // Call private API method
        recordView.perform(Selector(("stopRecording")))
        isRecording = false

        print("⏹️ Recording stopped")
    }

    /// Starts previewing the recorded video
    /// - Note: Full implementation will be added in Sprint 5
    public func startPreviewing() {
        guard !isPreviewing else { return }

        // Call private API method
        recordView.perform(Selector(("startPreviewing")))
        isPreviewing = true

        print("▶️ Preview started")
    }

    /// Stops previewing
    /// - Note: Full implementation will be added in Sprint 5
    public func stopPreviewing() {
        guard isPreviewing else { return }

        // Call private API method
        recordView.perform(Selector(("stopPreviewing")))
        isPreviewing = false

        print("⏸️ Preview stopped")
    }

    /// Exports the recorded movie to a URL
    /// - Parameters:
    ///   - url: The destination URL
    ///   - options: Export options
    ///   - completion: Completion handler
    /// - Note: Full implementation will be added in Sprint 5
    public func exportMovie(
        toURL url: URL,
        options: [String: Any]? = nil,
        completionHandler completion: (() -> Void)? = nil
    ) {
        // This will be implemented in Sprint 5
        print("💾 Export movie to: \(url.lastPathComponent)")
        completion?()
    }

    // MARK: - Cleanup

    deinit {
        stopTracking()
        stopRecording()
        stopPreviewing()
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
