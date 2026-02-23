//
//  HistoryEndpoints.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import Foundation

public struct FetchPartnersEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori/partners"
  public let method: HTTPMethod = .GET
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  public init(
    page: Int,
    size: Int,
    baseURL: String = NetworkConfig.baseURL
  ) {
    self.baseURL = baseURL
    self.queryParameters = [
      "page": String(page),
      "size": String(size)
    ]
  }
}

public struct FetchPartnerDoriListEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori/list/partner"
  public let method: HTTPMethod = .GET
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  public init(
    partnerId: Int64,
    baseURL: String = NetworkConfig.baseURL
  ) {
    self.baseURL = baseURL
    self.queryParameters = ["partnerId": String(partnerId)]
  }
}

public struct FetchDoriDetailEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori/detail"
  public let method: HTTPMethod = .GET
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  public init(
    doriId: Int64,
    baseURL: String = NetworkConfig.baseURL
  ) {
    self.baseURL = baseURL
    self.queryParameters = ["doriId": String(doriId)]
  }
}

public struct DeleteDoriEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori"
  public let method: HTTPMethod = .DELETE
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  public init(
    doriId: Int64,
    baseURL: String = NetworkConfig.baseURL
  ) {
    self.baseURL = baseURL
    self.queryParameters = ["doriId": String(doriId)]
  }
}

public struct BulkDeleteDoriEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/dori/bulk"
  public let method: HTTPMethod = .DELETE
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  public init(
    doriIds: [Int64],
    baseURL: String = NetworkConfig.baseURL
  ) {
    self.baseURL = baseURL
    self.queryParameters = ["doriIds": doriIds.map(String.init).joined(separator: ",")]
  }
}
