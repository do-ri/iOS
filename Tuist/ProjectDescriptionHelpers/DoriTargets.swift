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
    case .app: Environment.projectName
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
  case testSupport
  case network
  case networkImpl
  case kakaoAuth
  case appleAuth
  case keychain
  case fcm
  case onboarding
  case calendar
  case history
  case myPage
  case addDori
  case notification

  public var module: DoriModule {
    switch self {
    case .core:
      DoriModule(name: "DoriCore", layer: .core)
    case .designSystem:
      DoriModule(name: "DoriDesignSystem", layer: .core)
    case .testSupport:
      DoriModule(name: "DoriTestSupport", layer: .core)
    case .network:
      DoriModule(name: "DoriNetwork", layer: .infra)
    case .networkImpl:
      DoriModule(name: "DoriNetworkImpl", layer: .infra)
    case .kakaoAuth:
      DoriModule(name: "PlatformKakaoAuth", layer: .platform, directoryName: "KakaoAuth")
    case .appleAuth:
      DoriModule(name: "PlatformAppleAuth", layer: .platform, directoryName: "AppleAuth")
    case .keychain:
      DoriModule(name: "PlatformKeychain", layer: .platform, directoryName: "Keychain")
    case .fcm:
      DoriModule(name: "PlatformFCM", layer: .platform, directoryName: "FCM")
    case .onboarding:
      DoriModule(name: "FeatureOnboarding", layer: .feature, directoryName: "Onboarding")
    case .calendar:
      DoriModule(name: "FeatureCalendar", layer: .feature, directoryName: "Calendar")
    case .history:
      DoriModule(name: "FeatureHistory", layer: .feature, directoryName: "History")
    case .myPage:
      DoriModule(name: "FeatureMyPage", layer: .feature, directoryName: "MyPage")
    case .addDori:
      DoriModule(name: "FeatureAddDori", layer: .feature, directoryName: "AddDori")
    case .notification:
      DoriModule(name: "FeatureNotification", layer: .feature, directoryName: "Notification")
    }
  }
}
