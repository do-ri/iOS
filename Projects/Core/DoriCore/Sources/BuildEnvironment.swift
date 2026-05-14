//
//  BuildEnvironment.swift
//  Dori-iOS
//
//  Created by 강동영 on 4/18/26.
//

import Foundation

public enum BuildEnvironment: String, Sendable {
  case debug
  case qa
  case release

  public static let current: BuildEnvironment = {
    #if DEBUG
    return .debug
    #elseif QA
    return .qa
    #else
    return .release
    #endif
  }()

  public var isTestingEnabled: Bool {
    switch self {
    case .debug, .qa: return true
    case .release: return false
    }
  }

  public var displayName: String {
    switch self {
    case .debug: return "DEBUG"
    case .qa: return "QA"
    case .release: return "RELEASE"
    }
  }
}
