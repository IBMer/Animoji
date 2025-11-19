//
//  PermissionManager.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Manages camera and microphone permissions

import AVFoundation
import UIKit

/// Permission status for camera and microphone
public struct PermissionStatus: Sendable {
    public let camera: Bool
    public let microphone: Bool

    public var allGranted: Bool {
        camera && microphone
    }

    public var anyDenied: Bool {
        !camera || !microphone
    }
}

/// Manages permissions for camera and microphone access
@MainActor
public enum PermissionManager {
    // MARK: - Camera Permission

    /// Requests camera access permission
    /// - Returns: true if granted, false otherwise
    public static func requestCameraAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    /// Checks current camera permission status
    /// - Returns: Authorization status
    public static func cameraAuthorizationStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    /// Checks if camera access is granted
    /// - Returns: true if authorized, false otherwise
    public static var isCameraAuthorized: Bool {
        cameraAuthorizationStatus() == .authorized
    }

    // MARK: - Microphone Permission

    /// Requests microphone access permission
    /// - Returns: true if granted, false otherwise
    public static func requestMicrophoneAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    /// Checks current microphone permission status
    /// - Returns: Authorization status
    public static func microphoneAuthorizationStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .audio)
    }

    /// Checks if microphone access is granted
    /// - Returns: true if authorized, false otherwise
    public static var isMicrophoneAuthorized: Bool {
        microphoneAuthorizationStatus() == .authorized
    }

    // MARK: - Combined Permissions

    /// Requests both camera and microphone access
    /// - Returns: PermissionStatus with both permission states
    public static func requestAllPermissions() async -> PermissionStatus {
        async let camera = requestCameraAccess()
        async let microphone = requestMicrophoneAccess()

        return await PermissionStatus(
            camera: camera,
            microphone: microphone
        )
    }

    /// Checks if all required permissions are granted
    /// - Returns: true if both camera and microphone are authorized
    public static var allPermissionsGranted: Bool {
        isCameraAuthorized && isMicrophoneAuthorized
    }

    /// Gets current permission status for both camera and microphone
    /// - Returns: PermissionStatus with current states
    public static var currentPermissionStatus: PermissionStatus {
        PermissionStatus(
            camera: isCameraAuthorized,
            microphone: isMicrophoneAuthorized
        )
    }

    // MARK: - Settings

    /// Opens the app's settings page in the Settings app
    public static func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }

    // MARK: - Permission Checking

    /// Checks and requests permissions if needed
    /// - Returns: PermissionStatus after checking/requesting
    /// - Throws: FaceMojiError if permissions are denied
    public static func ensurePermissions() async throws -> PermissionStatus {
        let current = currentPermissionStatus

        // If already granted, return immediately
        if current.allGranted {
            return current
        }

        // Request missing permissions
        let status = await requestAllPermissions()

        // Throw error if any permission is denied
        if !status.camera {
            throw FaceMojiError.cameraPermissionDenied
        }
        if !status.microphone {
            throw FaceMojiError.microphonePermissionDenied
        }

        return status
    }
}
