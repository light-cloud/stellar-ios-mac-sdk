// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "stellar-ios-mac-sdk",
    products: [
        .library(name: "stellar-ios-mac-sdk", targets: ["stellarsdk"]),
    ],
    dependencies: [
    ],
    exclude: ["stellarsdk/stellarsdk/libs", "stellarsdk/stellarsdk/osx", "stellarsdk/stellarsdk/iphone", "stellarsdk/stellarsdk/simulator"],
    targets: [
        .target(
            name: "stellarsdk",
            dependencies: [],
            path: "stellarsdk/stellarsdk",
            exclude: ["stellarsdk/stellarsdk/libs", "stellarsdk/stellarsdk/osx", "stellarsdk/stellarsdk/iphone", "stellarsdk/stellarsdk/simulator"]),
        .testTarget(
            name: "stellarsdkTests",
            dependencies: ["stellarsdk"],
            path: "stellarsdk/stellarsdkTests"),
    ],
)