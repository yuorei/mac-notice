// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "mac-notice",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "mac-notice",
            path: "Sources/mac-notice",
            linkerSettings: [
                .linkedFramework("AppKit")
            ]
        ),
        .testTarget(
            name: "mac-noticeTests",
            dependencies: ["mac-notice"]
        ),
    ]
)
