// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
  productTypes: [
    "ComposableArchitecture": .framework,
    "Swinject": .framework,
    "Alamofire": .framework,
    "KakaoSDKCommon": .framework,
    "KakaoSDKAuth": .framework,
    "KakaoSDKUser": .framework,
  ]
)
#endif

let package = Package(
  name: "DoriDependencies",
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
    .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.1"),
    .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.0.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
  ]
)
