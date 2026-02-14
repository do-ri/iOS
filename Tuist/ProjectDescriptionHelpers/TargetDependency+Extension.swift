import ProjectDescription

extension TargetDependency {
  public static func external(_ dependency: DoriDependency) -> TargetDependency {
    .external(name: dependency.name)
  }
}

public enum DoriDependency: String {
  case alamofire
  case composableArchitecture
  case kakaoSDKCommon
  case kakaoSDKAuth
  case kakaoSDKUser
  
  var name: String {
    rawValue
  }
}
