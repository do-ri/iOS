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

public struct AppleLoginUserInfo: Equatable, Sendable {
  public let firstName: String?
  public let lastName: String?
  public let email: String?

  public init(
    firstName: String? = nil,
    lastName: String? = nil,
    email: String? = nil
  ) {
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
  }
}

public struct AppleLoginEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/auth/login/apple"
  public let method: HTTPMethod = .POST
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data?

  public init(
    identityToken: String,
    user: AppleLoginUserInfo? = nil,
    baseURL: String = NetworkConfig.baseURL
  ) {
    self.baseURL = baseURL

    var params: [String: any Sendable] = ["identityToken": identityToken]
    if let user {
      var userDict: [String: any Sendable] = [:]
      var nameDict: [String: any Sendable] = [:]
      if let firstName = user.firstName { nameDict["firstName"] = firstName }
      if let lastName = user.lastName { nameDict["lastName"] = lastName }
      if !nameDict.isEmpty { userDict["name"] = nameDict }
      if let email = user.email { userDict["email"] = email }
      if !userDict.isEmpty { params["user"] = userDict }
    }
    let parameters = params as Parameters
    self.body = try? JSONSerialization.data(withJSONObject: parameters)
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
