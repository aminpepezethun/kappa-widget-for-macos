// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "ohwell",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ohwell"
        ),
        .testTarget(
            name: "ohwellTests",
            dependencies: ["ohwell"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
