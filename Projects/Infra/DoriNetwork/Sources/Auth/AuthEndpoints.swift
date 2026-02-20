//
//  AuthEndpoints.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation

public struct KakaoLoginEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/auth/login/kakao"
  public let method: HTTPMethod = .POST
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data?

  public init(
    accessToken: String,
    baseURL: String = NetworkConfig.baseURL
  ) {
    self.baseURL = baseURL
    self.body = try? JSONEncoder().encode(KakaoLoginRequest(accessToken: accessToken))
  }
}

// MARK: - Auth Endpoints (logout / withdraw / refresh)

public struct LogoutEndpoint: Endpoint {
  public let baseURL: String = NetworkConfig.baseURL
  public let path: String = "/auth/logout"
  public let method: HTTPMethod = .POST
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data?

  public init(refreshToken: String) {
    self.body = try? JSONEncoder().encode(RefreshTokenRequest(refreshToken: refreshToken))
  }
}

public struct WithdrawEndpoint: Endpoint {
  public let baseURL: String = NetworkConfig.baseURL
  public let path: String = "/auth/withdraw"
  public let method: HTTPMethod = .POST
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data? = nil

  public init() {}
}

public struct RefreshEndpoint: Endpoint {
  public let baseURL: String = NetworkConfig.baseURL
  public let path: String = "/auth/refresh"
  public let method: HTTPMethod = .POST
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data?

  public init(refreshToken: String) {
    self.body = try? JSONEncoder().encode(RefreshTokenRequest(refreshToken: refreshToken))
  }
}
