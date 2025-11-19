//
//  HapticManager.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Manages haptic feedback for user interactions

import UIKit

/// Manages haptic feedback throughout the app
@MainActor
public enum HapticManager {
    // MARK: - Impact Feedback

    /// Triggers an impact haptic feedback
    /// - Parameter style: The style of impact (light, medium, heavy, soft, rigid)
    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Triggers a notification haptic feedback
    /// - Parameter type: The type of notification (success, warning, error)
    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    // MARK: - Selection Feedback

    /// Triggers a selection change haptic feedback
    public static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Convenience Methods

    /// Light tap feedback (for selecting items)
    public static func lightTap() {
        impact(.light)
    }

    /// Medium tap feedback (for button presses)
    public static func mediumTap() {
        impact(.medium)
    }

    /// Heavy tap feedback (for important actions)
    public static func heavyTap() {
        impact(.heavy)
    }

    /// Success feedback (for completed actions)
    public static func success() {
        notification(.success)
    }

    /// Warning feedback (for cautionary actions)
    public static func warning() {
        notification(.warning)
    }

    /// Error feedback (for failed actions)
    public static func error() {
        notification(.error)
    }
}

// MARK: - Usage Guidelines

/*
 Recommended haptic feedback usage in FaceMoji:

 - Selecting a puppet: HapticManager.lightTap()
 - Starting recording: HapticManager.mediumTap()
 - Stopping recording: HapticManager.success()
 - Deleting recording: HapticManager.warning()
 - Export complete: HapticManager.success()
 - Error occurred: HapticManager.error()
 - Changing settings: HapticManager.selection()
 */
