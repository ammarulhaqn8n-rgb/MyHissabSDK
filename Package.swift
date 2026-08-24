// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyHissabSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MyHissabSDK",
            targets: ["MyHissabSDK"]
        )
    ],
    targets: [
        .target(
            name: "MyHissabSDK"
        )
    ]
)
