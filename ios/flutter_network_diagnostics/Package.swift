// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_network_diagnostics",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-network-diagnostics", targets: ["flutter_network_diagnostics"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_network_diagnostics_objc",
            dependencies: [],
            path: "Sources/flutter_network_diagnostics_objc",
            linkerSettings: [
                .linkedLibrary("resolv")
            ]
        ),
        .target(
            name: "flutter_network_diagnostics",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "flutter_network_diagnostics_objc"
            ],
            path: "Sources/flutter_network_diagnostics",
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
