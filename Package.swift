// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SenziioCapacitorSse",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "SenziioCapacitorSse",
            targets: ["SenziioSSEPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "SenziioSSEPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/SenziioSSEPlugin"),
        .testTarget(
            name: "SenziioSSEPluginTests",
            dependencies: ["SenziioSSEPlugin"],
            path: "ios/Tests/SenziioSSEPluginTests")
    ]
)