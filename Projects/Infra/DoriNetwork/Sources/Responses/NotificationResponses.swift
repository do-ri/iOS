//
//  NotificationResponses.swift
//  Dori-iOS
//
//  Created by 강동영 on 4/27/26.
//

import Foundation

public struct NotificationSettingResponse: Decodable, Equatable, Sendable {
  public let typeCode: String
  public let category: String
  public let displayName: String
  public let enabled: Bool

  public init(
    typeCode: String,
    category: String,
    displayName: String,
    enabled: Bool
  ) {
    self.typeCode = typeCode
    self.category = category
    self.displayName = displayName
    self.enabled = enabled
  }
}
