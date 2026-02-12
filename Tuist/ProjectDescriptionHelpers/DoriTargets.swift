import ProjectDescription

public enum DoriLayer: String, CaseIterable, Sendable {
  case app = "App"
  case core = "Core"
  case infra = "Infra"
  case platform = "Platform"
  case feature = "Feature"

  /// Root-relative project path (Workspace.swift용)
  public var projectPath: Path {
    "Projects/\(rawValue)"
  }

  /// Per-layer Project.swift의 project name
  public var projectName: String {
    switch self {
    case .app: DoriManifest.projectName
    default: "Dori\(rawValue)"
    }
  }
}

public struct DoriModule: Sendable {
  public let name: String
  public let layer: DoriLayer
  public let directoryName: String

  public init(name: String, layer: DoriLayer, directoryName: String? = nil) {
    self.name = name
    self.layer = layer
    self.directoryName = directoryName ?? name
  }

  /// Root-relative path (Workspace 참조용)
  public var path: String {
    "Projects/\(layer.rawValue)/\(directoryName)"
  }

  /// Layer-relative path (per-layer Project.swift 내부용)
  public var localPath: String {
    directoryName
  }

  /// 같은 Project 내 타겟 의존성
  public var targetDependency: TargetDependency {
    .target(name: name)
  }

  /// 다른 Project에서 참조할 때 사용하는 크로스 프로젝트 의존성
  public var projectDependency: TargetDependency {
    .project(
      target: name,
      path: "../\(layer.rawValue)"
    )
  }
}

public enum DoriModules: CaseIterable, Sendable {
  case core
  case designSystem
  case network
  case networkImpl
  case kakaoAuth
  case keychain
  case onboarding
  case calendar
  case history
  case myPage

  public var module: DoriModule {
    switch self {
    case .core:
      DoriModule(name: "DoriCore", layer: .core)
    case .designSystem:
      DoriModule(name: "DoriDesignSystem", layer: .core)
    case .network:
      DoriModule(name: "DoriNetwork", layer: .infra)
    case .networkImpl:
      DoriModule(name: "DoriNetworkImpl", layer: .infra)
    case .kakaoAuth:
      DoriModule(name: "PlatformKakaoAuth", layer: .platform, directoryName: "KakaoAuth")
    case .keychain:
      DoriModule(name: "PlatformKeychain", layer: .platform, directoryName: "Keychain")
    case .onboarding:
      DoriModule(name: "FeatureOnboarding", layer: .feature, directoryName: "Onboarding")
    case .calendar:
      DoriModule(name: "FeatureCalendar", layer: .feature, directoryName: "Calendar")
    case .history:
      DoriModule(name: "FeatureHistory", layer: .feature, directoryName: "History")
    case .myPage:
      DoriModule(name: "FeatureMyPage", layer: .feature, directoryName: "MyPage")
    }
  }
}

public enum DoriAppTarget {
  public static let name = "DoriApp"

  private static let path = "."
  private static let rootPath = "Projects/App"
  private static let xcconfigPath = "\(rootPath)/Resources/Common.xcconfig"

  public static func make(dependencies: [TargetDependency]) -> Target {
    .target(
      name: name,
      destinations: .iOS,
      product: .app,
      bundleId: DoriManifest.bundleIDPrefix,
      deploymentTargets: DoriManifest.deploymentTarget,
      infoPlist: .extendingDefault(with: [
        "UILaunchScreen": .dictionary([:]),
        "BASE_URL": "$(BASE_URL)",
        "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",
        "Appearance": "Light",
        "CFBundleURLTypes": [
          [
            "CFBundleTypeRole": "Editor",
            "CFBundleURLName": Plist.Value.string(DoriManifest.bundleIDPrefix),
            "CFBundleURLSchemes": ["$(KAKAO_CAllBACK)"],
          ],
        ],
        "LSApplicationQueriesSchemes": [
          "kakaokompassauth",
          "kakaolink",
        ],
      ]),
      sources: ["Sources/**"],
      resources: [.glob(pattern: "Resources/**", excluding: ["Resources/info.plist"])],
      dependencies: dependencies,
      settings: .settings(
        base: DoriManifest.commonSettings,
        configurations: [
          .debug(name: "Debug", xcconfig: .relativeToRoot(xcconfigPath)),
          .release(name: "Release", xcconfig: .relativeToRoot(xcconfigPath)),
        ]
      )
    )
  }
}

public extension Target {
  static func doriFramework(
    _ module: DoriModule,
    dependencies: [TargetDependency] = [],
    hasResources: Bool = false
  ) -> Target {
    .target(
      name: module.name,
      destinations: .iOS,
      product: .framework,
      bundleId: "\(DoriManifest.bundleIDPrefix).\(module.name)",
      deploymentTargets: DoriManifest.deploymentTarget,
      sources: ["\(module.localPath)/Sources/**"],
      resources: hasResources ? ["\(module.localPath)/Resources/**"] : nil,
      dependencies: dependencies,
      settings: .settings(base: DoriManifest.commonSettings)
    )
  }

  static func doriUnitTests(
    _ module: DoriModule,
    dependencies: [TargetDependency] = []
  ) -> Target {
    .target(
      name: "\(module.name)Tests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "\(DoriManifest.bundleIDPrefix).\(module.name)Tests",
      deploymentTargets: DoriManifest.deploymentTarget,
      sources: ["\(module.localPath)/Tests/**"],
      dependencies: [.target(name: module.name)] + dependencies,
      settings: .settings(base: DoriManifest.commonSettings)
    )
  }
}

public extension Project {
  static func dori(
    name: String = DoriManifest.projectName,
    packages: [Package] = [],
    targets: [Target],
    resourceSynthesizers: [ResourceSynthesizer] = []
  ) -> Project {
    Project(
      name: name,
      organizationName: DoriManifest.organizationName,
      packages: packages,
      settings: .settings(base: DoriManifest.commonSettings),
      targets: targets,
      resourceSynthesizers: resourceSynthesizers
    )
  }
}
