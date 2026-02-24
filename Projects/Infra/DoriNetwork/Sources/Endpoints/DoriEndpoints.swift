//
//  DoriEndpoints.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/19/26.
//

import Foundation

public struct SearchPartnersEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori/search/partners"
  public let method: HTTPMethod = .GET
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  public init(query: String, baseURL: String = NetworkConfig.baseURL) {
    self.baseURL = baseURL
    self.queryParameters = ["query": query]
  }
}

public struct CreateDoriEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori"
  public let method: HTTPMethod = .POST
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String] = [:]
  public let body: Data?

  public init(request: DoriPostRequest, baseURL: String = NetworkConfig.baseURL) {
    self.baseURL = baseURL
    self.body = try? JSONEncoder().encode(request)
  }
}

public struct UpdateDoriEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori"
  public let method: HTTPMethod = .PUT
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data?

  public init(doriId: Int64, request: DoriUpdateRequest, baseURL: String = NetworkConfig.baseURL) {
    self.baseURL = baseURL
    self.queryParameters = ["doriId": String(doriId)]
    self.body = try? JSONEncoder().encode(request)
  }
}

public struct DoriListEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori/list"
  public let method: HTTPMethod = .GET
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  public init(request: DoriListRequest, baseURL: String = NetworkConfig.baseURL) {
    self.baseURL = baseURL
    self.queryParameters = [
      "direction": request.direction,
      "year": request.year,
      "month": request.month
    ]
  }
}
