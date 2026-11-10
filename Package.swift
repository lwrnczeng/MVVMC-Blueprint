// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MVVMCBlueprint",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
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
