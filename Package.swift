// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Aki",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "aki", targets: ["Aki"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Aki",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "AkiTests",
            dependencies: ["Aki"])
    ]
)
