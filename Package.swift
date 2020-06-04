// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ParagraphTextKit",
    platforms: [
        .macOS(.v10_15),
		.iOS(.v13)
    ],
    products: [
        .library(
            name: "ParagraphTextKit",
            targets: ["ParagraphTextKit"]),
    ],
    dependencies: [

	],
    targets: [
        .target(
            name: "ParagraphTextKit",
            dependencies: []),
        .testTarget(
            name: "ParagraphTextKitTests",
            dependencies: ["ParagraphTextKit"]),
    ]
)
