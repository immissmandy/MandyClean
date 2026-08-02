// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MandyClean",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MandyClean", targets: ["MandyClean"])
    ],
    targets: [
        .executableTarget(
            name: "MandyClean",
            path: "MandyClean"
        )
    ]
)
