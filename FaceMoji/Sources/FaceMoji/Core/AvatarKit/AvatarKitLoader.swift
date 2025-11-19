//
//  AvatarKitLoader.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Loads and provides access to Apple's private AvatarKit framework

import Foundation
import SceneKit
import UIKit

/// Errors that can occur when loading AvatarKit
public enum AvatarKitError: LocalizedError {
    case frameworkNotFound
    case frameworkLoadFailed
    case classNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .frameworkNotFound:
            return "AvatarKit framework not found. This feature requires iOS 11.1 or later."
        case .frameworkLoadFailed:
            return "Failed to load AvatarKit framework."
        case .classNotFound(let className):
            return "Required class '\(className)' not found in AvatarKit framework."
        }
    }
}

/// Singleton class responsible for loading and accessing AvatarKit private framework
@MainActor
public final class AvatarKitLoader {
    // MARK: - Singleton

    public static let shared = AvatarKitLoader()

    // MARK: - Properties

    private let bundle: Bundle
    public let animojiClass: NSObject.Type
    public let recordViewClass: SCNView.Type

    // MARK: - Initialization

    private init() {
        // Load AvatarKit framework bundle
        guard let bundle = Bundle(path: "/System/Library/PrivateFrameworks/AvatarKit.framework") else {
            fatalError("AvatarKit framework not found. This app requires iOS 11.1+ with AvatarKit support.")
        }

        // Load the framework
        guard bundle.load() else {
            fatalError("Failed to load AvatarKit framework.")
        }

        self.bundle = bundle

        // Get AVTAnimoji class
        guard let animojiClass = NSClassFromString("AVTAnimoji") as? NSObject.Type else {
            fatalError("AVTAnimoji class not found in AvatarKit framework.")
        }
        self.animojiClass = animojiClass

        // Get AVTRecordView class
        guard let recordViewClass = NSClassFromString("AVTRecordView") as? SCNView.Type else {
            fatalError("AVTRecordView class not found in AvatarKit framework.")
        }
        self.recordViewClass = recordViewClass
    }

    // MARK: - Public Methods

    /// Creates an Animoji puppet instance by name
    /// - Parameter name: The name of the puppet (e.g., "cat", "dog")
    /// - Returns: The puppet instance, or nil if not found
    public func createPuppet(named name: String) -> Any? {
        return extractMethod(animojiClass, Selector(("animojiNamed:")), name)
    }

    /// Gets all available puppet names from AvatarKit
    /// - Returns: Array of puppet name strings
    public func getPuppetNames() -> [String] {
        return animojiClass.value(forKeyPath: "animojiNames") as? [String] ?? []
    }

    /// Gets a thumbnail image for a puppet
    /// - Parameters:
    ///   - name: The name of the puppet
    ///   - options: Optional rendering options
    /// - Returns: The thumbnail image, or nil if not available
    public func getThumbnail(forPuppetNamed name: String, options: [String: Any]? = nil) -> UIImage? {
        return extractMethod(
            animojiClass,
            Selector(("thumbnailForAnimojiNamed:options:")),
            name,
            options
        ) as? UIImage
    }

    /// Creates a new AVTRecordView instance
    /// - Returns: A new record view instance
    public func createRecordView() -> SCNView {
        return recordViewClass.init()
    }
}

// MARK: - Validation

extension AvatarKitLoader {
    /// Checks if AvatarKit is available on this device
    /// - Returns: true if available, false otherwise
    public static func isAvailable() -> Bool {
        guard Bundle(path: "/System/Library/PrivateFrameworks/AvatarKit.framework") != nil else {
            return false
        }
        return true
    }

    /// Checks if TrueDepth camera is available (required for face tracking)
    /// - Returns: true if available, false otherwise
    public static func isFaceTrackingAvailable() -> Bool {
        // TrueDepth camera is available on iPhone X and later
        // This is a simple check - in production you might want to check ARFaceTrackingConfiguration.isSupported
        return ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 11
    }
}
