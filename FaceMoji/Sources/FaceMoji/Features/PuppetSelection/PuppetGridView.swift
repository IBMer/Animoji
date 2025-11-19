//
//  PuppetGridView.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Grid view for selecting Animoji puppets

import SwiftUI

/// Grid view displaying available puppets for selection
public struct PuppetGridView: View {
    // MARK: - Properties

    let puppets: [PuppetModel]
    let selectedPuppet: PuppetModel?
    let onSelect: (PuppetModel) -> Void

    /// Number of columns in the grid
    private let columns: Int

    /// Spacing between cells
    private let spacing: CGFloat

    // MARK: - Initialization

    public init(
        puppets: [PuppetModel],
        selectedPuppet: PuppetModel?,
        columns: Int = 4,
        spacing: CGFloat = 12,
        onSelect: @escaping (PuppetModel) -> Void
    ) {
        self.puppets = puppets
        self.selectedPuppet = selectedPuppet
        self.columns = columns
        self.spacing = spacing
        self.onSelect = onSelect
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            if puppets.isEmpty {
                emptyState
            } else {
                puppetGrid
            }
        }
    }

    // MARK: - Components

    private var puppetGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(puppets) { puppet in
                PuppetCell(
                    puppet: puppet,
                    isSelected: puppet.id == selectedPuppet?.id
                )
                .onTapGesture {
                    onSelect(puppet)
                }
            }
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "face.smiling")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Puppets Available")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Please check AvatarKit availability")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Puppet Cell

/// Individual cell displaying a puppet
struct PuppetCell: View {
    // MARK: - Properties

    let puppet: PuppetModel
    let isSelected: Bool

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body

    var body: some View {
        VStack(spacing: 6) {
            // Thumbnail
            AsyncImage(url: puppet.thumbnailURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    errorPlaceholder
                case .empty:
                    loadingPlaceholder
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 70, height: 70)
            .background(thumbnailBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.blue, lineWidth: 3)
                }
            }
            .shadow(
                color: isSelected ? .blue.opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )

            // Name
            Text(puppet.displayName)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    // MARK: - Components

    private var thumbnailBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
    }

    private var loadingPlaceholder: some View {
        ProgressView()
            .frame(width: 70, height: 70)
    }

    private var errorPlaceholder: some View {
        Image(systemName: "exclamationmark.triangle")
            .font(.title2)
            .foregroundStyle(.orange)
            .frame(width: 70, height: 70)
    }
}

// MARK: - Previews

#Preview("Puppet Grid - Light Mode") {
    PuppetGridView(
        puppets: [
            PuppetModel(name: "cat"),
            PuppetModel(name: "dog"),
            PuppetModel(name: "monkey"),
            PuppetModel(name: "robot"),
            PuppetModel(name: "unicorn"),
            PuppetModel(name: "panda")
        ],
        selectedPuppet: PuppetModel(name: "cat")
    ) { puppet in
        print("Selected: \(puppet.name)")
    }
    .frame(height: 300)
    .preferredColorScheme(.light)
}

#Preview("Puppet Grid - Dark Mode") {
    PuppetGridView(
        puppets: [
            PuppetModel(name: "cat"),
            PuppetModel(name: "dog"),
            PuppetModel(name: "monkey"),
            PuppetModel(name: "robot")
        ],
        selectedPuppet: PuppetModel(name: "dog")
    ) { puppet in
        print("Selected: \(puppet.name)")
    }
    .frame(height: 200)
    .preferredColorScheme(.dark)
}

#Preview("Puppet Grid - Empty") {
    PuppetGridView(
        puppets: [],
        selectedPuppet: nil
    ) { _ in }
    .frame(height: 300)
}
