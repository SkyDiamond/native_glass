// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "native_glass",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "native-glass", targets: ["native_glass"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "native_glass",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: []
        )
    ]
)
