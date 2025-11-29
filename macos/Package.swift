// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TransPop",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TransPop", targets: ["TransPop"])
    ],
    dependencies: [
        // Add dependencies if needed, e.g. for global shortcuts if we use a library
        // .package(url: "https://github.com/soffes/HotKey", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "TransPop",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
