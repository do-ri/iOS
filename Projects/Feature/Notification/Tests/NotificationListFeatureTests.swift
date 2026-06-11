//
//  NotificationListFeatureTests.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/11/26.
//

import ComposableArchitecture
import DoriNetwork
import Testing

@testable import FeatureNotification

@MainActor
struct NotificationListFeatureTests {

  // MARK: - Helpers

  private func makeItem(id: Int, readAt: String? = nil) -> NotificationItemResponse {
    NotificationItemResponse(
      id: id,
      typeCode: "DORI_ALERT",
      title: "결혼식 알림 \(id)",
      body: "내일 홍길동님의 결혼식 일정이 있어요!",
      targetType: "DORI",
      targetId: id,
      partnerId: 2,
      readAt: readAt,
      pushedAt: "2026-05-26T14:00:26.794863464",
      createdAt: "2026-05-26T14:00:26.794884463"
    )
  }

  // MARK: - 초기 로딩

  @Test
  func onAppear_첫페이지를_로드한다() async {
    let page = NotificationPageResponse(
      items: [makeItem(id: 10), makeItem(id: 9)],
      size: 20,
      nextCursor: "cursor-2",
      hasNext: true
    )
    let receivedCursor = LockIsolated<String??>(nil)

    let store = TestStore(initialState: NotificationListFeature.State()) {
      NotificationListFeature()
    } withDependencies: {
      $0.notificationListAPIClient.fetchNotifications = { cursor, _ in
        receivedCursor.setValue(cursor)
        return page
      }
    }

    await store.send(.onAppear) {
      $0.isLoading = true
    }

    await store.receive(\.notificationsResponse.success) {
      $0.isLoading = false
      $0.items = [self.makeItem(id: 10), self.makeItem(id: 9)]
      $0.nextCursor = "cursor-2"
      $0.hasNext = true
    }

    #expect(receivedCursor.value == .some(nil))  // 첫 페이지는 cursor 없음
  }

  @Test
  func onAppear_이미_로드된_경우_재요청하지_않는다() async {
    let store = TestStore(
      initialState: {
        var state = NotificationListFeature.State()
        state.items = [makeItem(id: 1)]
        return state
      }()
    ) {
      NotificationListFeature()
    }

    await store.send(.onAppear)  // items 비어있지 않음 → no effect
  }

  // MARK: - 무한 스크롤

  @Test
  func 마지막_항목_도달시_다음_페이지를_로드한다() async {
    let nextPage = NotificationPageResponse(
      items: [makeItem(id: 8)],
      size: 20,
      nextCursor: nil,
      hasNext: false
    )
    let receivedCursor = LockIsolated<String?>(nil)

    let lastItem = makeItem(id: 9)
    let store = TestStore(
      initialState: {
        var state = NotificationListFeature.State()
        state.items = [makeItem(id: 10), lastItem]
        state.nextCursor = "cursor-2"
        state.hasNext = true
        return state
      }()
    ) {
      NotificationListFeature()
    } withDependencies: {
      $0.notificationListAPIClient.fetchNotifications = { cursor, _ in
        receivedCursor.setValue(cursor)
        return nextPage
      }
    }

    await store.send(.loadNextPageIfNeeded(lastItem)) {
      $0.isLoading = true
    }

    await store.receive(\.notificationsResponse.success) {
      $0.isLoading = false
      $0.items = [self.makeItem(id: 10), self.makeItem(id: 9), self.makeItem(id: 8)]
      $0.nextCursor = nil
      $0.hasNext = false
    }

    #expect(receivedCursor.value == "cursor-2")  // 다음 페이지 cursor 전달
  }

  @Test
  func 마지막_항목이_아니면_로드하지_않는다() async {
    let firstItem = makeItem(id: 10)
    let store = TestStore(
      initialState: {
        var state = NotificationListFeature.State()
        state.items = [firstItem, makeItem(id: 9)]
        state.nextCursor = "cursor-2"
        state.hasNext = true
        return state
      }()
    ) {
      NotificationListFeature()
    }

    await store.send(.loadNextPageIfNeeded(firstItem))  // 마지막 아님 → no effect
  }

  @Test
  func hasNext가_false면_추가_로드하지_않는다() async {
    let lastItem = makeItem(id: 9)
    let store = TestStore(
      initialState: {
        var state = NotificationListFeature.State()
        state.items = [makeItem(id: 10), lastItem]
        state.hasNext = false
        return state
      }()
    ) {
      NotificationListFeature()
    }

    await store.send(.loadNextPageIfNeeded(lastItem))  // hasNext=false → no effect
  }

  // MARK: - 에러 처리

  @Test
  func 로드_실패시_에러메시지를_세팅한다() async {
    struct SomeError: Error {}

    let store = TestStore(initialState: NotificationListFeature.State()) {
      NotificationListFeature()
    } withDependencies: {
      $0.notificationListAPIClient.fetchNotifications = { _, _ in throw SomeError() }
    }

    await store.send(.onAppear) {
      $0.isLoading = true
    }

    await store.receive(\.notificationsResponse.failure) {
      $0.isLoading = false
      $0.errorMessage = SomeError().localizedDescription
    }
  }
}
