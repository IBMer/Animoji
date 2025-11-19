//
//  Color+Extensions.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Color extensions for theming and presets

import SwiftUI

// MARK: - Background Colors

extension Color {
    /// Predefined background colors for Animoji scene
    public enum AnimojiBackground: String, CaseIterable, Identifiable {
        case black
        case white
        case darkGray
        case lightGray
        case blue
        case purple
        case pink
        case gradient

        public var id: String { rawValue }

        public var color: Color {
            switch self {
            case .black:
                return .black
            case .white:
                return .white
            case .darkGray:
                return Color(white: 0.2)
            case .lightGray:
                return Color(white: 0.85)
            case .blue:
                return Color.blue.opacity(0.3)
            case .purple:
                return Color.purple.opacity(0.3)
            case .pink:
                return Color.pink.opacity(0.3)
            case .gradient:
                return .black // Gradient handled separately
            }
        }

        public var displayName: String {
            switch self {
            case .black:
                return "Black"
            case .white:
                return "White"
            case .darkGray:
                return "Dark Gray"
            case .lightGray:
                return "Light Gray"
            case .blue:
                return "Blue"
            case .purple:
                return "Purple"
            case .pink:
                return "Pink"
            case .gradient:
                return "Gradient"
            }
        }

        public var isGradient: Bool {
            self == .gradient
        }
    }

    /// Default background color for Animoji
    public static let defaultAnimojiBackground = Color.black
}

// MARK: - Hex Initializer

extension Color {
    /// Creates a color from a hex string
    /// - Parameter hex: Hex color string (e.g., "#FF5733" or "FF5733")
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Backgrounds

extension LinearGradient {
    /// Predefined gradient for Animoji background
    public static var animojiGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.6),
                Color.blue.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Sunset gradient
    public static var sunsetGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.orange,
                Color.pink
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Ocean gradient
    public static var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.blue,
                Color.cyan
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
