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

  public init(accessToken: String, baseURL: String = NetworkConfig.baseURL) {
    self.baseURL = baseURL
    self.body = try? JSONEncoder().encode(KakaoLoginRequest(accessToken: accessToken))
  }
}
