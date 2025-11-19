//
//  RecordingState.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Represents the current state of recording

import Foundation

/// Represents the different states of the recording process
public enum RecordingState: Equatable, Sendable {
    /// No recording is active, ready to start
    case idle

    /// Currently recording
    case recording

    /// Recording finished, in preview mode
    case preview

    // MARK: - Computed Properties

    /// Whether the app is currently recording
    public var isRecording: Bool {
        self == .recording
    }

    /// Whether the app is in preview mode
    public var isPreviewing: Bool {
        self == .preview
    }

    /// Whether the app is idle
    public var isIdle: Bool {
        self == .idle
    }

    // MARK: - Display Properties

    /// Human-readable description of the state
    public var description: String {
        switch self {
        case .idle:
            return "Ready"
        case .recording:
            return "Recording"
        case .preview:
            return "Preview"
        }
    }
}
