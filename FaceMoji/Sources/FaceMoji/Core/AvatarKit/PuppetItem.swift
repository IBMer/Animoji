//
//  PuppetItem.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Defines all available Animoji puppet types

import Foundation

/// Enumeration of all available Animoji puppets
/// Puppets are organized by iOS version availability
public enum PuppetItem: String, CaseIterable, Sendable {
    // MARK: - iOS 11.1 Puppets
    case monkey
    case robot
    case cat
    case dog
    case alien
    case fox
    case poo
    case pig
    case panda
    case rabbit
    case chicken
    case unicorn

    // MARK: - iOS 11.3 Puppets
    case lion
    case dragon
    case skull
    case bear

    // MARK: - iOS 12.0 Puppets
    case tiger
    case koala
    case trex
    case ghost

    // MARK: - iOS 12.2 Puppets
    case giraffe
    case shark
    case owl
    case boar

    // MARK: - All Cases (Version-aware)

    /// Returns all available puppets for the current iOS version
    public static var allAvailableCases: [PuppetItem] {
        var cases: [PuppetItem] = [
            .monkey, .robot, .cat, .dog, .alien, .fox, .poo, .pig,
            .panda, .rabbit, .chicken, .unicorn
        ]

        // iOS 11.3+ puppets
        if #available(iOS 11.3, *) {
            cases += [.lion, .dragon, .skull, .bear]
        }

        // iOS 12.0+ puppets
        if #available(iOS 12.0, *) {
            cases += [.tiger, .koala, .trex, .ghost]
        }

        // iOS 12.2+ puppets
        if #available(iOS 12.2, *) {
            cases += [.giraffe, .shark, .owl, .boar]
        }

        return cases
    }

    // MARK: - Display Properties

    /// Human-readable display name for the puppet
    public var displayName: String {
        switch self {
        case .trex:
            return "T-Rex"
        case .poo:
            return "Poop"
        default:
            return rawValue.capitalized
        }
    }
}
