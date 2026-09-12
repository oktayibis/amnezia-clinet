// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AmneziaCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AmneziaCore",
            targets: ["AmneziaCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AmneziaCore",
            dependencies: [],
            path: "AmneziaCore",
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .testTarget(
            name: "AmneziaCoreTests",
            dependencies: ["AmneziaCore"],
            path: "Tests/AmneziaCoreTests"
        )
    ]
)
