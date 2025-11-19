//
//  AnimojiSceneView.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  SwiftUI bridge for AnimojiRecordView using UIViewRepresentable

import SwiftUI
import UIKit

/// SwiftUI view that bridges AnimojiRecordView to SwiftUI
public struct AnimojiSceneView: UIViewRepresentable {
    // MARK: - Properties

    /// The current puppet to display
    let puppet: PuppetModel?

    /// Background color for the scene
    let backgroundColor: Color

    /// Recording state
    let isRecording: Bool

    /// Preview state
    let isPreviewing: Bool

    /// Callback when recording state changes
    let onRecordingStateChange: ((Bool) -> Void)?

    // MARK: - Initialization

    public init(
        puppet: PuppetModel?,
        backgroundColor: Color = .black,
        isRecording: Bool = false,
        isPreviewing: Bool = false,
        onRecordingStateChange: ((Bool) -> Void)? = nil
    ) {
        self.puppet = puppet
        self.backgroundColor = backgroundColor
        self.isRecording = isRecording
        self.isPreviewing = isPreviewing
        self.onRecordingStateChange = onRecordingStateChange
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context: Context) -> AnimojiRecordView {
        let view = AnimojiRecordView()

        // Set initial background color
        view.sceneBackgroundColor = UIColor(backgroundColor)

        // Set initial puppet if available
        if let puppet = puppet {
            view.setPuppet(puppet)
        }

        print("✅ AnimojiSceneView created")

        return view
    }

    public func updateUIView(_ uiView: AnimojiRecordView, context: Context) {
        // Update puppet if changed
        if let puppet = puppet,
           puppet.id != uiView.currentPuppet?.id {
            uiView.setPuppet(puppet)
            print("🔄 Updated puppet to: \(puppet.name)")
        }

        // Update background color if changed
        let uiColor = UIColor(backgroundColor)
        if uiView.sceneBackgroundColor != uiColor {
            uiView.sceneBackgroundColor = uiColor
            print("🎨 Updated background color")
        }

        // Update recording state
        if isRecording != uiView.isRecording {
            if isRecording {
                uiView.startRecording()
            } else {
                uiView.stopRecording()
            }
        }

        // Update preview state
        if isPreviewing != uiView.isPreviewing {
            if isPreviewing {
                uiView.startPreviewing()
            } else {
                uiView.stopPreviewing()
            }
        }
    }

    public static func dismantleUIView(_ uiView: AnimojiRecordView, coordinator: ()) {
        // Cleanup when view is removed
        uiView.stopTracking()
        uiView.stopRecording()
        uiView.stopPreviewing()
        print("🗑️ AnimojiSceneView dismantled")
    }
}

// MARK: - Convenience Initializers

extension AnimojiSceneView {
    /// Creates a simple scene view with just a puppet
    /// - Parameter puppet: The puppet to display
    public init(puppet: PuppetModel?) {
        self.init(
            puppet: puppet,
            backgroundColor: .black,
            isRecording: false,
            isPreviewing: false,
            onRecordingStateChange: nil
        )
    }

    /// Creates a scene view with custom background
    /// - Parameters:
    ///   - puppet: The puppet to display
    ///   - backgroundColor: The background color
    public init(puppet: PuppetModel?, backgroundColor: Color) {
        self.init(
            puppet: puppet,
            backgroundColor: backgroundColor,
            isRecording: false,
            isPreviewing: false,
            onRecordingStateChange: nil
        )
    }
}

// MARK: - Preview Support

#Preview("AnimojiSceneView - No Puppet") {
    AnimojiSceneView(puppet: nil)
        .frame(height: 400)
}

#Preview("AnimojiSceneView - With Background") {
    VStack {
        AnimojiSceneView(
            puppet: nil,
            backgroundColor: .blue.opacity(0.3)
        )
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()

        Text("Animoji Scene")
            .font(.headline)
    }
}
