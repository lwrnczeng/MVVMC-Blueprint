// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MVVMCBlueprint",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MVVMCBlueprint",
            targets: ["MVVMCBlueprint"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MVVMCBlueprint",
            dependencies: [],
            resources: [
                .process("Features/Checkout/Data/MockJson")
            ]
        ),
        .testTarget(
            name: "MVVMCBlueprintTests",
            dependencies: ["MVVMCBlueprint"]
        ),
    ]
)
