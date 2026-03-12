// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NgrokTools",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "NgrokTools",
            path: "Sources/NgrokTools",
            resources: [
                .copy("Resources/menubar-icon.png"),
                .copy("Resources/menubar-icon@2x.png"),
                .copy("Resources/AppIcon.appiconset"),
            ]
        ),
        .testTarget(
            name: "NgrokToolsTests",
            dependencies: ["NgrokTools"],
            path: "Tests/NgrokToolsTests"
        ),
    ]
)
