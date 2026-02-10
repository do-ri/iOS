// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    productTypes: [
        "Alamofire": .staticFramework,
    ]
)
#endif

let package = Package(
    name: "DoriDependencies",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.1"),
    ]
)
