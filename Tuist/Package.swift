// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings
import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    "ComposableArchitecture": .framework,
    "Dependencies": .framework,
    "CombineSchedulers": .framework,
    "Clocks": .framework,
    "CasePaths": .framework,
    "SwiftNavigation": .framework,
    "ConcurrencyExtras": .framework,
    "Swinject": .framework,
    "Alamofire": .framework,
    "KakaoSDKCommon": .framework,
    "KakaoSDKAuth": .framework,
    "KakaoSDKUser": .framework,
  ],
  baseSettings: .settings(
    base: [
      "CODE_SIGNING_ALLOWED": "NO",
      "CODE_SIGN_IDENTITY": "",
      "SWIFT_ENABLE_EXPLICIT_MODULES": "NO"
    ]
  )
)
#endif

let package = Package(
  name: "DoriDependencies",
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.25.5"),
    // swift-case-paths 1.8.0+ triggers CasePathsMacrosSupport-Swift.h not found on Xcode 26 macro host.
    // Pinning only swift-case-paths to 1.7.x is sufficient: SPM transitively constrains
    // swift-navigation to 2.8.x without a direct dependency (which would conflict with
    // TCA's IssueReporting trait requirement added after 2.8.0).
    .package(url: "https://github.com/pointfreeco/swift-case-paths", .upToNextMinor(from: "1.7.3")),
    .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.1"),
    .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.0.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0"),
  ]
)
