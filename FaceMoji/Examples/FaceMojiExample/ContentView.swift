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
    @State private var puppets: [PuppetModel] = []
    @State private var selectedPuppet: PuppetModel?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Puppets...")
                        .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)

                        Text("Error Loading")
                            .font(.headline)

                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Retry") {
                            loadPuppets()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    puppetGrid
                }
            }
            .navigationTitle("FaceMoji")
            .task {
                loadPuppets()
            }
        }
    }

    private var puppetGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 12
            ) {
                ForEach(puppets) { puppet in
                    PuppetCell(
                        puppet: puppet,
                        isSelected: puppet.id == selectedPuppet?.id
                    ) {
                        selectedPuppet = puppet
                        HapticManager.lightTap()
                    }
                }
            }
            .padding()
        }
    }

    private func loadPuppets() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let loadedPuppets = try await PuppetManager.shared.loadAvailablePuppets()
                await MainActor.run {
                    self.puppets = loadedPuppets
                    self.selectedPuppet = loadedPuppets.first
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Puppet Cell

struct PuppetCell: View {
    let puppet: PuppetModel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: puppet.thumbnailURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 70, height: 70)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                }
            }

            Text(puppet.displayName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    ContentView()
}
