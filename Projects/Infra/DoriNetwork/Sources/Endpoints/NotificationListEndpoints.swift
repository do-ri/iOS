//
//  NotificationListEndpoints.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/11/26.
//

import Foundation

/// 알림함 목록 조회 (GET /notifications)
/// SENT 알림만 노출, 최신순, cursor 페이징.
public struct FetchNotificationsEndpoint: Endpoint {
  public let baseURL: String
  public let path: String = "/notifications"
  public let method: HTTPMethod = .GET
  public let headers: [String: String] = [:]
  public let queryParameters: [String: String]
  public let body: Data? = nil

  /// - Parameters:
  ///   - cursor: 이전 응답의 nextCursor. 첫 페이지는 nil (쿼리에서 생략).
  ///   - size: 페이지 크기 (기본 20).
  public init(
    cursor: String?,
    size: Int,
    baseURL: String = NetworkConfig.baseURL
  ) {
    self.baseURL = baseURL
    var query = ["size": String(size)]
    if let cursor {
      query["cursor"] = cursor
    }
    self.queryParameters = query
  }
}
