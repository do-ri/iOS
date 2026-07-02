//
//  NotificationListAPIClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/11/26.
//

import ComposableArchitecture
import DoriNetwork
import Foundation

// MARK: - API Client

@DependencyClient
public struct NotificationListAPIClient: Sendable {
  /// 알림함 목록 조회. cursor 가 nil 이면 첫 페이지.
  public var fetchNotifications: @Sendable (_ cursor: String?, _ size: Int) async throws -> NotificationPageResponse
}

enum NotificationListAPIClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "NotificationListAPIClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    }
  }
}

extension NotificationListAPIClient: DependencyKey {
  public static let liveValue = Self(
    fetchNotifications: { _, _ in throw NotificationListAPIClientError.unconfigured }
  )
}

extension NotificationListAPIClient: TestDependencyKey {
  public static let previewValue = Self(
    fetchNotifications: { _, _ in
      NotificationPageResponse(
        items: [
          NotificationItemResponse(
            id: 10,
            typeCode: "DORI_ALERT",
            title: "결혼식 알림",
            body: "내일 홍길동님의 결혼식 일정이 있어요!",
            targetType: "DORI",
            targetId: 10,
            partnerId: 2,
            readAt: nil,
            pushedAt: "2026-05-26T14:00:26.794863464",
            createdAt: "2026-05-26T14:00:26.794884463"
          )
        ],
        size: 20,
        nextCursor: nil,
        hasNext: false
      )
    }
  )

  public static let testValue = Self()
}

public extension NotificationListAPIClient {
  static func live(networkService: any NetworkService) -> Self {
    Self(
      fetchNotifications: { cursor, size in
        let endpoint = FetchNotificationsEndpoint(cursor: cursor, size: size)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<NotificationPageResponse>.self
        )
        if let apiError = response.error {
          throw NotificationListAPIClientError.backendError(
            apiError.message ?? "알림 목록 조회에 실패했습니다."
          )
        }
        guard response.success, let data = response.data else {
          throw NotificationListAPIClientError.invalidResponse
        }
        return data
      }
    )
  }
}

public extension DependencyValues {
  var notificationListAPIClient: NotificationListAPIClient {
    get { self[NotificationListAPIClient.self] }
    set { self[NotificationListAPIClient.self] = newValue }
  }
}
