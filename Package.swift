// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LLMAPI",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Run", targets: ["Run"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    ],
    targets: [
        .executableTarget(
            name: "Run",
            dependencies: [.product(name: "Vapor", package: "vapor")],
            path: "LLMAPI"
        ),
    ]
)
