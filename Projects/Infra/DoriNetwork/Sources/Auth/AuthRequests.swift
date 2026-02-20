//
//  AuthRequests.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation

public struct KakaoLoginRequest: Codable, Equatable, Sendable {
  public let accessToken: String

  public init(accessToken: String) {
    self.accessToken = accessToken
  }
}

public struct RefreshTokenRequest: Encodable, Sendable {
  public let refreshToken: String

  public init(refreshToken: String) {
    self.refreshToken = refreshToken
  }
}
