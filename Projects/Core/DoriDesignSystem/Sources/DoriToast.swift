//
//  DoriToast.swift
//  DoriDesignSystem
//
//  Created by 강동영 on 2/13/26.
//

import Foundation

public struct DoriToast: Equatable, Sendable {
  public let id: UUID
  public let type: ToastType
  public let message: String
  public let duration: TimeInterval

  public init(
    id: UUID = UUID(),
    type: ToastType,
    message: String,
    duration: TimeInterval? = nil
  ) {
    self.id = id
    self.type = type
    self.message = message
    self.duration = duration ?? type.defaultDuration
  }
}

public enum ToastType: Equatable, Sendable {
  case success
  case error
  case info

  public var defaultDuration: TimeInterval {
    switch self {
    case .success, .info:
      return 2.0
    case .error:
      return 3.0
    }
  }
}
