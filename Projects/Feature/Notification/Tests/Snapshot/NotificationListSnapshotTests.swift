import ComposableArchitecture
import DoriNetwork
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureNotification

@MainActor
final class NotificationListSnapshotTests: XCTestCase {
  private static let mockItems: [NotificationItemResponse] = [
    NotificationItemResponse(
      id: 1,
      typeCode: "DORI_ALERT",
      title: "결혼식 알림",
      body: "내일 홍길동님의 결혼식 일정이 있어요!",
      targetType: "DORI",
      targetId: 10,
      partnerId: 2,
      readAt: nil,
      pushedAt: "2026-05-26T14:00:26.794863464",
      createdAt: "2026-05-26T14:00:26.794884463"
    ),
    NotificationItemResponse(
      id: 2,
      typeCode: "DORI_ALERT",
      title: "생일 알림",
      body: "오늘은 이순신님의 생일이에요. 도리를 보내보는 건 어떨까요?",
      targetType: "DORI",
      targetId: 11,
      partnerId: 3,
      readAt: "2026-05-25T10:00:00",
      pushedAt: "2026-05-25T09:00:00.000000000",
      createdAt: "2026-05-25T09:00:00.000000000"
    ),
    NotificationItemResponse(
      id: 3,
      typeCode: "DORI_ALERT",
      title: "돌잔치 알림",
      body: "강감찬님 자녀의 돌잔치가 3일 후에 있어요!",
      targetType: "DORI",
      targetId: 12,
      partnerId: 4,
      readAt: nil,
      pushedAt: "2026-05-24T08:30:00.000000000",
      createdAt: "2026-05-24T08:30:00.000000000"
    )
  ]

  private func makeEmptyView() -> some View {
    NavigationStack {
      NotificationListView(
        store: Store(initialState: NotificationListFeature.State()) {
          NotificationListFeature()
        } withDependencies: {
          $0.notificationListAPIClient = .previewValue
        }
      )
    }
  }

  private func makePopulatedView() -> some View {
    var state = NotificationListFeature.State()
    state.items = Self.mockItems
    state.hasNext = false

    return NavigationStack {
      NotificationListView(
        store: Store(initialState: state) {
          NotificationListFeature()
        } withDependencies: {
          $0.notificationListAPIClient = .testValue
        }
      )
    }
  }

  func test_notificationList_empty_light() {
    assertSnapshot(
      of: makeEmptyView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_notificationList_empty_dark() {
    assertSnapshot(
      of: makeEmptyView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  func test_notificationList_populated_light() {
    assertSnapshot(
      of: makePopulatedView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_notificationList_populated_dark() {
    assertSnapshot(
      of: makePopulatedView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
