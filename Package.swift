// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BIP32",
    platforms: [
        .macOS(.v10_12), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(
            name: "BIP32",
            targets: ["BIP32"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ShenghaiWang/BIP39.git", branch: "master")
    ],
    targets: [
        .target(
            name: "BIP32",
            dependencies: ["BIP39"]),
        .testTarget(
            name: "BIP32Tests",
            dependencies: ["BIP32"]),
    ]
)
