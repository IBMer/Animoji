//
//  RecordingControlsView.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Recording control buttons and UI

import SwiftUI

/// View displaying recording controls (record, preview, delete, share)
public struct RecordingControlsView: View {
    // MARK: - Properties

    @Bindable var viewModel: ContentViewModel

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 16) {
            // Recording duration (only show while recording)
            if viewModel.isRecording {
                recordingDurationView
                    .transition(.scale.combined(with: .opacity))
            }

            // Control buttons
            HStack(spacing: 30) {
                switch viewModel.recordingState {
                case .idle:
                    recordButton

                case .recording:
                    stopButton

                case .preview:
                    previewControls
                }
            }
            .frame(height: 80)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.recordingState)
        }
        .padding(.vertical)
    }

    // MARK: - Components

    // MARK: Recording Duration

    private var recordingDurationView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .opacity(viewModel.isRecording ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.isRecording)

            Text(viewModel.formattedDuration)
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: Record Button

    private var recordButton: some View {
        Button {
            Task {
                await viewModel.toggleRecording()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 80, height: 80)

                Circle()
                    .fill(Color.red)
                    .frame(width: 64, height: 64)

                Image(systemName: "circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.red)
                    .symbolEffect(.bounce, value: viewModel.recordingState)
            }
        }
        .disabled(!viewModel.canRecord)
        .opacity(viewModel.canRecord ? 1.0 : 0.5)
    }

    // MARK: Stop Button

    private var stopButton: some View {
        Button {
            Task {
                await viewModel.toggleRecording()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 80, height: 80)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red)
                    .frame(width: 32, height: 32)
            }
        }
        .symbolEffect(.pulse)
    }

    // MARK: Preview Controls

    private var previewControls: some View {
        HStack(spacing: 24) {
            // Delete button
            Button {
                viewModel.deleteRecording()
            } label: {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .frame(width: 44, height: 44)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }

            // Play/Pause button
            Button {
                viewModel.togglePreview()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)
                }
            }

            // Share button
            shareButton
        }
    }

    private var shareButton: some View {
        ShareLink(
            item: URL(string: "facemoji://recording")!, // Placeholder URL
            preview: SharePreview(
                "Animoji Recording",
                image: Image(systemName: "face.smiling")
            )
        ) {
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

// MARK: - Previews

#Preview("Recording Controls - Idle") {
    let viewModel = ContentViewModel()
    viewModel.currentPuppet = PuppetModel(name: "cat")

    return RecordingControlsView(viewModel: viewModel)
        .padding()
}

#Preview("Recording Controls - Recording") {
    let viewModel = ContentViewModel()
    viewModel.recordingState = .recording
    viewModel.recordingDuration = 5.3

    return RecordingControlsView(viewModel: viewModel)
        .padding()
}

#Preview("Recording Controls - Preview") {
    let viewModel = ContentViewModel()
    viewModel.recordingState = .preview

    return RecordingControlsView(viewModel: viewModel)
        .padding()
}

#Preview("Recording Controls - Disabled") {
    let viewModel = ContentViewModel()
    viewModel.currentPuppet = nil // No puppet selected

    return VStack {
        Text("No puppet selected - button disabled")
            .font(.caption)
            .foregroundStyle(.secondary)

        RecordingControlsView(viewModel: viewModel)
    }
    .padding()
}
