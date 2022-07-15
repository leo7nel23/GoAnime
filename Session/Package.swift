// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Session",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Session",
            targets: ["Session"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Session",
            dependencies: [],
            swiftSettings: [.define("DEBUG_MODE", .when(configuration: .debug))]
        ),
        .testTarget(
            name: "SessionTests",
            dependencies: ["Session"]
        )
    ]
)
