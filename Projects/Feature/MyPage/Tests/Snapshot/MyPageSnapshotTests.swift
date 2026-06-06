import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureMyPage

@MainActor
final class MyPageSnapshotTests: XCTestCase {
  private func makeView() -> some View {
    MyPageView(
      store: Store(initialState: MyPageFeature.State()) {
        MyPageFeature()
      }
    )
  }

  func test_myPage_default_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_myPage_default_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
