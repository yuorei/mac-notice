// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "mac-notice",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "mac-notice",
            dependencies: ["BundleHook"],
            path: "Sources/mac-notice"
        ),
        .target(
            name: "BundleHook",
            path: "Sources/BundleHook",
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "mac-noticeTests",
            dependencies: ["mac-notice"]
        ),
    ]
)
