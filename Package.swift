// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EthereumPriceChart",
    platforms: [.iOS(.v16)],
    products: [
        .app(
            name: "EthereumPriceChart",
            targets: ["EthereumPriceChart"]
        )
    ],
    dependencies: [
        // No external dependencies needed as we're using built-in Charts framework
    ],
    targets: [
        .target(
            name: "EthereumPriceChart",
            dependencies: [],
            path: "EthereumPriceChart"
        )
    ]
)
