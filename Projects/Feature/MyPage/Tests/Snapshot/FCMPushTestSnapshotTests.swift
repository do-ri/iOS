import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureMyPage

@MainActor
final class FCMPushTestSnapshotTests: XCTestCase {
  private func makeView(state: FCMPushTestFeature.State) -> some View {
    FCMPushTestView(
      store: Store(initialState: state) {
        FCMPushTestFeature()
      }
    )
  }

  // MARK: - Default (대기 상태)

  private static let defaultState = FCMPushTestFeature.State(
    userId: 1,
    title: "테스트 푸시",
    body: "본문 메시지",
    isLoading: false
  )

  func test_fcmPushTest_default_light() {
    assertSnapshot(
      of: makeView(state: Self.defaultState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_fcmPushTest_default_dark() {
    assertSnapshot(
      of: makeView(state: Self.defaultState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Loading

  private static let loadingState = FCMPushTestFeature.State(
    userId: 1,
    title: "테스트 푸시",
    body: "본문 메시지",
    isLoading: true
  )

  func test_fcmPushTest_loading_light() {
    assertSnapshot(
      of: makeView(state: Self.loadingState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_fcmPushTest_loading_dark() {
    assertSnapshot(
      of: makeView(state: Self.loadingState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
