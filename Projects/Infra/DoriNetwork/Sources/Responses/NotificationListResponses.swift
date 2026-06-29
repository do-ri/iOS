//
//  NotificationListResponses.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/11/26.
//

import Foundation

/// 알림함 단일 항목 (GET /notifications 의 data.items[])
///
/// 응답의 중첩 `data` 객체(type/doriId/daysLeft 등)는 현재 화면 범위(항목 탭 동작 없음)에서
/// 사용하지 않으므로 디코딩하지 않는다. Decodable 은 정의되지 않은 키를 무시한다.
public struct NotificationItemResponse: Decodable, Equatable, Sendable, Identifiable {
  public let id: Int
  public let typeCode: String
  public let title: String
  public let body: String
  public let targetType: String?
  public let targetId: Int?
  public let partnerId: Int?
  public let readAt: String?
  public let pushedAt: String
  public let createdAt: String

  public init(
    id: Int,
    typeCode: String,
    title: String,
    body: String,
    targetType: String? = nil,
    targetId: Int? = nil,
    partnerId: Int? = nil,
    readAt: String? = nil,
    pushedAt: String,
    createdAt: String
  ) {
    self.id = id
    self.typeCode = typeCode
    self.title = title
    self.body = body
    self.targetType = targetType
    self.targetId = targetId
    self.partnerId = partnerId
    self.readAt = readAt
    self.pushedAt = pushedAt
    self.createdAt = createdAt
  }
}

/// 알림함 cursor 페이지 (GET /notifications 의 data)
public struct NotificationPageResponse: Decodable, Equatable, Sendable {
  public let items: [NotificationItemResponse]
  public let size: Int
  public let nextCursor: String?
  public let hasNext: Bool

  public init(
    items: [NotificationItemResponse],
    size: Int,
    nextCursor: String?,
    hasNext: Bool
  ) {
    self.items = items
    self.size = size
    self.nextCursor = nextCursor
    self.hasNext = hasNext
  }
}
