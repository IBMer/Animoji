//
//  ContentView.swift
//  FaceMojiExample
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//

import SwiftUI
import FaceMoji

struct ContentView: View {
    // MARK: - Properties

    @State private var viewModel = ContentViewModel()
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoadingPuppets {
                    loadingView
                } else if viewModel.availablePuppets.isEmpty {
                    errorView
                } else {
                    mainContent
                }
            }
            .navigationTitle("FaceMoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    historyButton
                }

                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
            .sheet(isPresented: $viewModel.showSettings) {
                settingsView
            }
            .sheet(isPresented: $viewModel.showHistory) {
                RecordingHistoryView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let message = viewModel.errorMessage {
                    Text(message)
                }
            }
            .task {
                await viewModel.loadPuppets()
                await viewModel.requestPermissions()
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Animoji Scene
            AnimojiSceneView(
                puppet: viewModel.currentPuppet,
                backgroundColor: viewModel.backgroundColor,
                isRecording: viewModel.isRecording,
                isPreviewing: viewModel.isPreviewing
            )
            .frame(height: 400)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding()

            // Status indicator
            if let puppet = viewModel.currentPuppet {
                Text("Current: \(puppet.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }

            // Puppet Grid
            PuppetGridView(
                puppets: viewModel.availablePuppets,
                selectedPuppet: viewModel.currentPuppet
            ) { puppet in
                viewModel.selectPuppet(puppet)
            }
            .frame(height: 220)

            Spacer()

            // Recording Controls
            RecordingControlsView(viewModel: viewModel)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading Animoji Puppets...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("This may take a moment")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundStyle(.orange)

            Text("Failed to Load Puppets")
                .font(.title2)
                .fontWeight(.semibold)

            Text("AvatarKit framework may not be available on this device.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                Task {
                    await viewModel.loadPuppets()
                }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Toolbar Buttons

    private var historyButton: some View {
        Button {
            viewModel.showHistory = true
        } label: {
            Image(systemName: "clock")
                .font(.body)
        }
    }

    private var settingsButton: some View {
        Button {
            viewModel.showSettings = true
        } label: {
            Image(systemName: "gearshape")
                .font(.body)
        }
    }

    // MARK: - Settings View

    private var settingsView: some View {
        NavigationStack {
            Form {
                // Background Color Section
                Section("Background") {
                    ForEach(Color.AnimojiBackground.allCases) { background in
                        Button {
                            viewModel.changeBackground(background)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(background.color)
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        if background.isGradient {
                                            LinearGradient.animojiGradient
                                                .clipShape(Circle())
                                        }
                                    }

                                Text(background.displayName)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if viewModel.selectedBackground == background {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // Info Section
                Section("Information") {
                    LabeledContent("Puppets Loaded", value: "\(viewModel.availablePuppets.count)")
                    LabeledContent("iOS Version", value: "17.0+")
                    LabeledContent("Framework", value: "SwiftUI + AvatarKit")
                }

                // Permissions Section
                Section("Permissions") {
                    Button {
                        PermissionManager.openSettings()
                    } label: {
                        Label("Open Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.showSettings = false
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Content View - Light") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Content View - Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
