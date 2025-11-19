//
//  Extensions.swift
//  FaceMoji
//
//  Created by Claude on 11/19/25.
//  Copyright © 2025 FaceMoji. All rights reserved.
//
//  Runtime utility functions for accessing private AvatarKit APIs

import Foundation
import ObjectiveC.runtime

// MARK: - Runtime Method Extraction

/// Extracts and calls a method with one argument from an Objective-C object or class
/// - Parameters:
///   - owner: The object or class to call the method on
///   - selector: The selector of the method to call
///   - arg1: The first argument to pass to the method
/// - Returns: The result of the method call, or nil if the method doesn't exist
func extractMethod(_ owner: AnyObject, _ selector: Selector, _ arg1: Any?) -> AnyObject? {
    guard let method = getMethod(owner, selector) else { return nil }
    let imp = method_getImplementation(method)
    typealias CFunction = @convention(c) (AnyObject, Selector, Any?) -> Unmanaged<AnyObject>
    let function = unsafeBitCast(imp, to: CFunction.self)
    return function(owner, selector, arg1).takeUnretainedValue()
}

/// Extracts and calls a method with two arguments from an Objective-C object or class
/// - Parameters:
///   - owner: The object or class to call the method on
///   - selector: The selector of the method to call
///   - arg1: The first argument to pass to the method
///   - arg2: The second argument to pass to the method
/// - Returns: The result of the method call, or nil if the method doesn't exist
func extractMethod(_ owner: AnyObject, _ selector: Selector, _ arg1: Any?, _ arg2: Any?) -> AnyObject? {
    guard let method = getMethod(owner, selector) else { return nil }
    let imp = method_getImplementation(method)
    typealias CFunction = @convention(c) (AnyObject, Selector, Any?, Any?) -> Unmanaged<AnyObject>
    let function = unsafeBitCast(imp, to: CFunction.self)
    return function(owner, selector, arg1, arg2).takeUnretainedValue()
}

/// Gets the method for a given selector from an object or class
/// - Parameters:
///   - owner: The object or class to get the method from
///   - selector: The selector of the method
/// - Returns: The method, or nil if not found
private func getMethod(_ owner: AnyObject, _ selector: Selector) -> Method? {
    if let owner = owner as? AnyClass {
        return class_getClassMethod(owner, selector)
    } else {
        return class_getInstanceMethod(type(of: owner), selector)
    }
}

// MARK: - Associated Objects

/// A wrapper class for storing associated values with type safety
private class Associated<Type>: NSObject {
    let value: Type
    init(_ value: Type) {
        self.value = value
    }
}

/// Protocol for types that can have associated objects
protocol Associable {}

extension Associable where Self: NSObject {
    /// Gets a typed value from key path
    func _value<T>(forKeyPath keyPath: String) -> T? {
        return (value(forKeyPath: keyPath) as? Associated<T>).map { $0.value }
    }

    /// Sets a typed value for key path
    func _setValue<T>(_ value: T?, forKeyPath keyPath: String) {
        setValue(value.map { Associated<T>($0) }, forKeyPath: keyPath)
    }
}

extension NSObject: Associable {}
