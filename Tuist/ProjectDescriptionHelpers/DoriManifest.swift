import ProjectDescription

public enum DoriManifest {
  public static let projectName = "Dori-iOS"
  public static let organizationName = "com.arex"
  public static let bundleIDPrefix = "com.arex.dori"
  public static var deploymentTarget: DeploymentTargets {
    .iOS("17.6")
  }

  public static var commonSettings: SettingsDictionary {
    [
      "SWIFT_VERSION": "6.0",
    ]
  }
}

public enum DoriDependency {
  public static var alamofire: TargetDependency {
    .external(name: "Alamofire")
  }

  public static var composableArchitecture: TargetDependency {
    .external(name: "ComposableArchitecture")
  }

  public static var kakaoSDKCommon: TargetDependency {
    .external(name: "KakaoSDKCommon")
  }

  public static var kakaoSDKAuth: TargetDependency {
    .external(name: "KakaoSDKAuth")
  }

  public static var kakaoSDKUser: TargetDependency {
    .external(name: "KakaoSDKUser")
  }
}
