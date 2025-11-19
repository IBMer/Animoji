//
//  PuppetManager.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Manages Animoji puppet loading and caching

import Foundation
import UIKit
import Observation

/// Manages the loading and caching of Animoji puppets
@MainActor
@Observable
public final class PuppetManager {
    // MARK: - Singleton

    public static let shared = PuppetManager()

    // MARK: - Properties

    private let loader = AvatarKitLoader.shared
    private(set) public var availablePuppets: [PuppetModel] = []
    private var thumbnailCache: [String: UIImage] = [:]

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Loads all available puppets for the current iOS version
    /// - Returns: Array of available puppet models
    /// - Throws: AvatarKitError if loading fails
    public func loadAvailablePuppets() async throws -> [PuppetModel] {
        // Get all puppet names from AvatarKit
        let names = loader.getPuppetNames()

        // Create models for each puppet
        let puppets = names.compactMap { name -> PuppetModel? in
            // Get or load thumbnail
            let thumbnail = getCachedThumbnail(for: name) ?? loadThumbnail(for: name)

            // Save thumbnail to temporary directory for async loading
            let url = saveThumbnailToTemp(thumbnail, name: name)

            // Create puppet instance
            guard let avatarInstance = loader.createPuppet(named: name) else {
                return nil
            }

            return PuppetModel(
                name: name,
                thumbnailURL: url,
                avatarInstance: avatarInstance
            )
        }

        availablePuppets = puppets
        return puppets
    }

    /// Gets a specific puppet by name
    /// - Parameter name: The puppet name
    /// - Returns: The puppet model if found
    public func getPuppet(named name: String) -> PuppetModel? {
        return availablePuppets.first { $0.name == name }
    }

    /// Gets a puppet by PuppetItem enum
    /// - Parameter item: The puppet item
    /// - Returns: The puppet model if found
    public func getPuppet(_ item: PuppetItem) -> PuppetModel? {
        return getPuppet(named: item.rawValue)
    }

    // MARK: - Private Methods

    /// Loads a thumbnail for a puppet
    private func loadThumbnail(for name: String) -> UIImage? {
        if let cached = thumbnailCache[name] {
            return cached
        }

        guard let thumbnail = loader.getThumbnail(forPuppetNamed: name) else {
            return nil
        }

        thumbnailCache[name] = thumbnail
        return thumbnail
    }

    /// Gets a cached thumbnail if available
    private func getCachedThumbnail(for name: String) -> UIImage? {
        return thumbnailCache[name]
    }

    /// Saves a thumbnail image to temporary directory
    /// - Parameters:
    ///   - image: The thumbnail image
    ///   - name: The puppet name
    /// - Returns: URL of the saved image
    private func saveThumbnailToTemp(_ image: UIImage?, name: String) -> URL? {
        guard let image = image,
              let data = image.pngData() else {
            return nil
        }

        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("puppet_\(name).png")

        try? data.write(to: imageURL)
        return imageURL
    }

    // MARK: - Cache Management

    /// Clears the thumbnail cache
    public func clearCache() {
        thumbnailCache.removeAll()
    }

    /// Preloads thumbnails for better performance
    public func preloadThumbnails() async {
        let names = loader.getPuppetNames()

        for name in names {
            _ = loadThumbnail(for: name)
        }
    }
}
