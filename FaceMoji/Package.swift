// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FaceMoji",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FaceMoji",
            targets: ["FaceMoji"]
        )
    ],
    dependencies: [
        // No external dependencies - using only Apple frameworks
    ],
    targets: [
        .target(
            name: "FaceMoji",
            dependencies: [],
            path: "Sources/FaceMoji"
        ),
        .testTarget(
            name: "FaceMojiTests",
            dependencies: ["FaceMoji"],
            path: "Tests/FaceMojiTests"
        )
    ]
)
