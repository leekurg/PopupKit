// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PopupKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "PopupKit",
            targets: ["PopupKit"]
        )
    ],
    targets: [
        .target(
            name: "PopupKit",
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]
        )
    ]
)
