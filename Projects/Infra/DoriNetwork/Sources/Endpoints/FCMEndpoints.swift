//
//  FCMEndpoints.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/27/26.
//

import Foundation

public struct RegisterFCMTokenEndpoint: Endpoint {
  public let baseURL: String = NetworkConfig.baseURL
  public let path: String = "/fcm/token"
  public let method: HTTPMethod = .POST
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data?

  public init(token: String) {
    self.body = try? JSONEncoder().encode(FCMTokenRequest(token: token))
  }
}

public struct DeleteFCMTokenEndpoint: Endpoint {
  public let baseURL: String = NetworkConfig.baseURL
  public let path: String = "/fcm/token"
  public let method: HTTPMethod = .DELETE
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  public init(token: String) {
    self.queryParameters = ["token": token]
  }
}

private struct FCMTokenRequest: Encodable {
  let token: String
}
