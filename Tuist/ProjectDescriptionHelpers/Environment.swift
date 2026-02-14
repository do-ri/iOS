//
//  Environment.swift
//  ProjectDescriptionHelpers
//
//  Created by 강동영 on 2/12/26.
//

import Foundation

import ProjectDescription

// MARK: - Build Configuration
public enum BuildConfiguration: String, CaseIterable {
  case debug = "Debug"
  case release = "Release"
  
  public var bundleIdSuffix: String {
    switch self {
    case .debug: return ""
    case .release: return ""
    }
  }
  
  public var appName: String {
    switch self {
    case .debug: return "Dori-Debug"
    case .release: return "Dori"
    }
  }
}

// MARK: - Environment
public struct Environment {
  public static let deploymentTarget = "17.6"
  public static let teamID = "T5D2PB4P5T"
  public static let organizationName = "com.arex"
  public static let defaultRegion = "ko"
  public static let projectName = "Dori-iOS"
  
  public struct App {
    public static let baseBundleId = "\(organizationName).dori"
    public static let displayName = "도리"
    public static let version = "1.0.0"
    public static let buildNumber = "1"
    
    public static func bundleId(for configuration: BuildConfiguration = .release) -> String {
      baseBundleId + configuration.bundleIdSuffix
    }
  }
  
  public static func bundleId(for module: String, configuration: BuildConfiguration = .release) -> String {
    "\(organizationName).\(module.lowercased())\(configuration.bundleIdSuffix)"
  }
  
  public static func bundleId(category: ModuleCategory, module: String, configuration: BuildConfiguration = .release) -> String {
    "\(organizationName).\(category.rawValue).\(module.lowercased())\(configuration.bundleIdSuffix)"
  }
}

// MARK: - Module Categories
public enum ModuleCategory: String, CaseIterable {
  case app = "app"
  case core = "core"
  case feature = "feature"
  case domain = "domain"
  case data = "data"
  case shared = "shared"
  case plugin = "plugin"
}
