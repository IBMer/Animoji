//
//  PuppetModel.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Data model representing an Animoji puppet

import Foundation

/// Represents an Animoji puppet with its metadata and instance
public struct PuppetModel: Identifiable, Hashable, Sendable {
    // MARK: - Properties

    public let id: UUID
    public let name: String
    public let thumbnailURL: URL?
    public nonisolated(unsafe) var avatarInstance: Any?  // AVTAnimoji instance (not Sendable)

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        name: String,
        thumbnailURL: URL? = nil,
        avatarInstance: Any? = nil
    ) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbnailURL
        self.avatarInstance = avatarInstance
    }

    // MARK: - Computed Properties

    /// Display name for the puppet (capitalized)
    public var displayName: String {
        // Convert to PuppetItem if possible for better display name
        if let item = PuppetItem(rawValue: name) {
            return item.displayName
        }
        return name.capitalized
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }

    public static func == (lhs: PuppetModel, rhs: PuppetModel) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}
