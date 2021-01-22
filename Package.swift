// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Aki",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "aki", targets: ["Aki"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Aki",
            dependencies: []),
        .testTarget(
            name: "AkiTests",
            dependencies: ["Aki"])
    ]
)
