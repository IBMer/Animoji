//
//  FaceMojiError.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Error types for FaceMoji operations

import Foundation

/// Errors that can occur during FaceMoji operations
public enum FaceMojiError: LocalizedError {
    case cameraPermissionDenied
    case microphonePermissionDenied
    case faceTrackingNotAvailable
    case avatarKitLoadFailed
    case recordingFailed(Error)
    case exportFailed(Error)
    case storageError(Error)
    case puppetNotFound(String)
    case invalidRecording

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera access is required for face tracking."
        case .microphonePermissionDenied:
            return "Microphone access is required for recording audio."
        case .faceTrackingNotAvailable:
            return "Face tracking is not available on this device."
        case .avatarKitLoadFailed:
            return "Failed to load AvatarKit framework."
        case .recordingFailed(let error):
            return "Recording failed: \(error.localizedDescription)"
        case .exportFailed(let error):
            return "Export failed: \(error.localizedDescription)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .puppetNotFound(let name):
            return "Puppet '\(name)' not found."
        case .invalidRecording:
            return "Invalid recording data."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .cameraPermissionDenied, .microphonePermissionDenied:
            return "Please enable permissions in Settings > Privacy & Security."
        case .faceTrackingNotAvailable:
            return "This feature requires iPhone X or later with TrueDepth camera."
        case .avatarKitLoadFailed:
            return "This feature requires iOS 11.1 or later."
        default:
            return nil
        }
    }

    public var failureReason: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera permission was denied."
        case .microphonePermissionDenied:
            return "Microphone permission was denied."
        case .faceTrackingNotAvailable:
            return "TrueDepth camera is not available."
        case .avatarKitLoadFailed:
            return "AvatarKit framework could not be loaded."
        case .recordingFailed:
            return "The recording process encountered an error."
        case .exportFailed:
            return "The export process encountered an error."
        case .storageError:
            return "File system operation failed."
        case .puppetNotFound:
            return "The requested puppet is not available."
        case .invalidRecording:
            return "The recording data is corrupted or invalid."
        }
    }
}
