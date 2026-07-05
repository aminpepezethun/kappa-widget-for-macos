// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "ohwell",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ohwell",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ohwellTests",
            dependencies: ["ohwell"]
        ),
        // UI tests — run via `make ui-test`, NOT `swift test`
        // Requires .app bundle built first. See Makefile.
        .testTarget(
            name: "ohwellUITests",
            dependencies: [],
            path: "Tests/ohwellUITests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
