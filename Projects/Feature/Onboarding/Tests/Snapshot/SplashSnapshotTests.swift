import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureOnboarding

@MainActor
final class SplashSnapshotTests: XCTestCase {
  private func makeView() -> some View {
    SplashView(
      store: Store(initialState: SplashFeature.State()) {
        SplashFeature()
      }
    )
  }

  func test_splash_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_splash_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
