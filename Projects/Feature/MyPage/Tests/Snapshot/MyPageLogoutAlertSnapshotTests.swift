import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureMyPage

@MainActor
final class MyPageLogoutAlertSnapshotTests: XCTestCase {
  private func makeView() -> some View {
    MyPageView(
      store: Store(
        initialState: MyPageFeature.State(isLogoutAlertPresented: true)
      ) {
        MyPageFeature()
      }
    )
  }

  func test_myPage_logoutAlert_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_myPage_logoutAlert_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
