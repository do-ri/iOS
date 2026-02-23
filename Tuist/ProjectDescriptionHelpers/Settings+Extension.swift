//
//  Settings+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 강동영 on 2/12/26.
//

import ProjectDescription

public extension Settings {
  /// 프레임워크용 기본 설정
  static let frameworkSettings: Settings = .settings(
    base: [
      "SKIP_INSTALL": "YES",
      "DEFINES_MODULE": "YES",
      "ENABLE_BITCODE": "NO",
      "IPHONEOS_DEPLOYMENT_TARGET": .string(Environment.deploymentTarget),
      "SWIFT_VERSION": "6.0",
      "CLANG_ENABLE_MODULES": "YES"
    ]
  )
  
  /// 테스트용 기본 설정
  static let testSettings: Settings = .settings(
    base: [
      "ENABLE_TESTING_SEARCH_PATHS": "YES",
      "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "YES",
      "ENABLE_TESTABILITY": "YES",
      "IPHONEOS_DEPLOYMENT_TARGET": .string(Environment.deploymentTarget),
      "SWIFT_VERSION": "6.0",
      "DEVELOPMENT_TEAM": .string(Environment.teamID)
    ]
  )
  
  /// 앱용 설정
  static func appSettings() -> Settings {
    let rootPath = "Projects/App"
    let xcconfigPath = "\(rootPath)/Resources/Common.xcconfig"
    
    let baseSettings: [String: SettingValue] = [
      "APP_NAME": .string(Environment.App.displayName),
      "CODE_SIGN_STYLE": "Automatic",
      "DEVELOPMENT_TEAM": .string(Environment.teamID),
      "MARKETING_VERSION": .string(Environment.App.version),
      "CURRENT_PROJECT_VERSION": .string(Environment.App.buildNumber),
      "ENABLE_BITCODE": "NO",
      "IPHONEOS_DEPLOYMENT_TARGET": .string(Environment.deploymentTarget),
      "SWIFT_VERSION": "6.0",
    ]
    
    let debugSettings: [String: SettingValue] = [
      "PRODUCT_NAME": .string(BuildConfiguration.debug.appName),
      "ENABLE_TESTABILITY": "YES",
      "GCC_OPTIMIZATION_LEVEL": "0",
      "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
      "DEBUG_INFORMATION_FORMAT": "dwarf",
      "GCC_PREPROCESSOR_DEFINITIONS": .array(["DEBUG=1"])
    ]
    
    let releaseSettings: [String: SettingValue] = [
      "PRODUCT_NAME": .string(BuildConfiguration.release.appName),
      "SWIFT_OPTIMIZATION_LEVEL": "-O",
      "ENABLE_TESTABILITY": "NO",
      "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
      "SWIFT_COMPILATION_MODE": "wholemodule"
    ]
    
    return .settings(
      base: baseSettings,
      configurations: [
        .debug(
          name: .debug,
          settings: debugSettings,
          xcconfig: .relativeToRoot(xcconfigPath)
        ),
        .release(
          name: .release,
          settings: releaseSettings,
          xcconfig: .relativeToRoot(xcconfigPath)
        )
      ]
    )
  }
  
  /// 데모 앱용 설정
  static let demoAppSettings: Settings = .settings(
    base: [
      "CODE_SIGN_STYLE": "Automatic",
      "IPHONEOS_DEPLOYMENT_TARGET": .string(Environment.deploymentTarget),
      "SWIFT_VERSION": "6.0",
      "ENABLE_TESTABILITY": "YES"
    ]
  )
}
