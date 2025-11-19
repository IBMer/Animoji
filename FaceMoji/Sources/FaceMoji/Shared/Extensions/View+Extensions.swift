//
//  View+Extensions.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  SwiftUI View extensions for common patterns

import SwiftUI

// MARK: - Conditional Modifiers

extension View {
    /// Applies a modifier conditionally
    /// - Parameters:
    ///   - condition: The condition to check
    ///   - transform: The transformation to apply if condition is true
    /// - Returns: Modified view
    @ViewBuilder
    public func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies one of two modifiers based on a condition
    /// - Parameters:
    ///   - condition: The condition to check
    ///   - trueTransform: Applied if condition is true
    ///   - falseTransform: Applied if condition is false
    /// - Returns: Modified view
    @ViewBuilder
    public func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

// MARK: - Corner Radius

extension View {
    /// Applies corner radius to specific corners
    /// - Parameters:
    ///   - radius: The corner radius
    ///   - corners: The corners to round
    /// - Returns: Modified view
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

/// Custom shape for rounding specific corners
private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Haptic Feedback

extension View {
    /// Adds haptic feedback on tap
    /// - Parameters:
    ///   - style: The impact style
    ///   - action: The action to perform
    /// - Returns: Modified view
    public func onTapWithHaptic(
        style: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        perform action: @escaping () -> Void
    ) -> some View {
        self.onTapGesture {
            HapticManager.impact(style)
            action()
        }
    }
}

// MARK: - Error Alert

extension View {
    /// Presents an error alert
    /// - Parameters:
    ///   - error: Binding to optional error
    ///   - buttonTitle: The dismiss button title
    /// - Returns: Modified view
    public func errorAlert(
        error: Binding<Error?>,
        buttonTitle: String = "OK"
    ) -> some View {
        let localError = error.wrappedValue
        return alert(
            isPresented: .constant(localError != nil),
            error: localError
        ) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            if let recoverySuggestion = error.recoverySuggestion {
                Text(recoverySuggestion)
            }
        }
    }
}
