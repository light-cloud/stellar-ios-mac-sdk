// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "stellar-ios-mac-sdk",
    products: [
        .library(name: "stellar-ios-mac-sdk", targets: ["stellarsdk"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "stellarsdk",
            dependencies: [],
            path: "stellarsdk/stellarsdk",
            exclude: ["stellarsdk/stellarsdk/libs/ed25519-C/module.modulemap", "stellarsdk/stellarsdk/osx/module.modulemap", "stellarsdk/stellarsdk/iphone/module.modulemap", "stellarsdk/stellarsdk/simulator/module.modulemap"]),
        .testTarget(
            name: "stellarsdkTests",
            dependencies: ["stellarsdk"],
            path: "stellarsdk/stellarsdkTests"),
    ],
)
