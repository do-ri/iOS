import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureOnboarding

@MainActor
final class IntroSnapshotTests: XCTestCase {
  private func makeView() -> some View {
    IntroView(
      store: Store(initialState: IntroFeature.State()) {
        IntroFeature()
      }
    )
  }

  func test_intro_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_intro_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
