//
//  RecordingHistoryView.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  View for browsing and managing saved recordings

import SwiftUI
import AVKit

/// View displaying all saved recordings
public struct RecordingHistoryView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @State private var storage = RecordingStorage.shared
    @State private var selectedRecording: RecordingModel?
    @State private var showDeleteAlert = false
    @State private var recordingToDelete: RecordingModel?
    @State private var showPlayer = false

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            Group {
                if storage.recordings.isEmpty {
                    emptyState
                } else {
                    recordingsList
                }
            }
            .navigationTitle("Recording History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    doneButton
                }

                if !storage.recordings.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        storageInfoButton
                    }
                }
            }
            .alert("Delete Recording", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    recordingToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let recording = recordingToDelete {
                        deleteRecording(recording)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this recording?")
            }
            .sheet(item: $selectedRecording) { recording in
                VideoPlayerView(recording: recording)
            }
        }
    }

    // MARK: - Components

    private var recordingsList: some View {
        List {
            Section {
                ForEach(storage.recordings) { recording in
                    RecordingRow(recording: recording)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRecording = recording
                        }
                }
                .onDelete(perform: deleteRecordings)
            } header: {
                HStack {
                    Text("Recordings (\(storage.recordings.count)/\(storage.maxRecordings))")
                    Spacer()
                    Text(storage.formattedTotalSize)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Recordings", systemImage: "video.slash")
        } description: {
            Text("Your recorded Animoji videos will appear here")
        }
    }

    private var doneButton: some View {
        Button("Done") {
            dismiss()
        }
    }

    private var storageInfoButton: some View {
        Menu {
            Text("Total: \(storage.formattedTotalSize)")
            Text("Limit: \(storage.maxRecordings) recordings")

            Divider()

            Button(role: .destructive) {
                showDeleteAllAlert()
            } label: {
                Label("Delete All", systemImage: "trash")
            }
        } label: {
            Image(systemName: "info.circle")
        }
    }

    // MARK: - Actions

    private func deleteRecordings(at offsets: IndexSet) {
        for index in offsets {
            let recording = storage.recordings[index]
            try? storage.deleteRecording(recording)
        }
        HapticManager.success()
    }

    private func deleteRecording(_ recording: RecordingModel) {
        try? storage.deleteRecording(recording)
        recordingToDelete = nil
        HapticManager.success()
    }

    private func showDeleteAllAlert() {
        // Show alert to confirm delete all
        storage.deleteAllRecordings()
        HapticManager.warning()
    }
}

// MARK: - Recording Row

struct RecordingRow: View {
    let recording: RecordingModel
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 80, height: 60)

                    ProgressView()
                }

                // Play overlay
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
            .task {
                // Generate thumbnail
                if thumbnail == nil {
                    thumbnail = try? await recording.generateThumbnail()
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.puppetName.capitalized)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label(recording.formattedDuration, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let size = recording.formattedFileSize {
                        Label(size, systemImage: "doc")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(recording.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Video Player View

struct VideoPlayerView: View {
    let recording: RecordingModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if recording.fileExists {
                    VideoPlayer(player: AVPlayer(url: recording.fileURL))
                        .onAppear {
                            // Auto-play when view appears
                            let player = AVPlayer(url: recording.fileURL)
                            player.play()
                        }
                } else {
                    ContentUnavailableView {
                        Label("File Not Found", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text("The recording file could not be found")
                    }
                }
            }
            .navigationTitle(recording.puppetName.capitalized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    ShareLink(item: recording.fileURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Recording History - Empty") {
    RecordingHistoryView()
}

#Preview("Recording History - With Data") {
    let storage = RecordingStorage.shared
    // Preview with mock data
    return RecordingHistoryView()
}
