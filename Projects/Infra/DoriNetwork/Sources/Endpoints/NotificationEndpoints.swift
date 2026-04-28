//
//  NotificationEndpoints.swift
//  Dori-iOS
//
//  Created by 강동영 on 4/27/26.
//

import Foundation

public struct FetchNotificationSettingsEndpoint: Endpoint {
  public let baseURL: String = NetworkConfig.baseURL
  public let path: String = "/notifications/settings"
  public let method: HTTPMethod = .GET
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data? = nil

  public init() {}
}

public struct UpdateNotificationSettingEndpoint: Endpoint {
  public let baseURL: String = NetworkConfig.baseURL
  public let path: String = "/notifications/settings"
  public let method: HTTPMethod = .PUT
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data?

  public init(typeCode: String, enabled: Bool) {
    self.body = try? JSONEncoder().encode(
      UpdateNotificationSettingRequest(
        typeCode: typeCode,
        enabled: enabled
      )
    )
  }
}

private struct UpdateNotificationSettingRequest: Encodable {
  let typeCode: String
  let enabled: Bool
}
