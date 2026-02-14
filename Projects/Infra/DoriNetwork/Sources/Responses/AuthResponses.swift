//
//  AuthResponses.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/10/26.
//

import Foundation

// MARK: - Auth Response DTOs

public struct SocialLoginResponse: Codable, Equatable, Sendable {
  public let accessToken: String
  public let refreshToken: String
  public let id: Int64

  public init(
    accessToken: String,
    refreshToken: String,
    id: Int64
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.id = id
  }
}

public struct TokenRefreshResponse: Decodable, Equatable, Sendable {
  public let accessToken: String
  public let refreshToken: String
  public let id: Int

  public init(
    accessToken: String,
    refreshToken: String,
    id: Int
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.id = id
  }
}
