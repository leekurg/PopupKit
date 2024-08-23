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
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                /// Uncomment if you want PopupKit work withing SwiftUI Previews context.
                /// In this case It is required to define an aprropriate **root** modifier to setup
                /// **preseter** and a root view. This can be achieved by using ``View/debugPreviewNotificationEnv(:_)``.
//                .define("DISABLE_POPUPKIT_IN_PREVIEWS")
            ]
        )
    ]
)
