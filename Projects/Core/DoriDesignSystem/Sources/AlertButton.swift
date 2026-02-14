//
//  AlertButton.swift
//  DoriDesignSystem
//
//  Created by 강동영 on 2/13/26.
//

public struct AlertButton {
  public let title: String
  public let action: @MainActor () -> Void

  public init(
    title: String,
    action: @escaping @MainActor () -> Void
  ) {
    self.title = title
    self.action = action
  }

  public init(
    _ type: AlertButtonType,
    action: @escaping @MainActor () -> Void
  ) {
    self.title = type.title
    self.action = action
  }

  public enum AlertButtonType {
    case yes
    case no

    public var title: String {
      switch self {
      case .yes:
        return "예"
      case .no:
        return "아니오"
      }
    }
  }
}
