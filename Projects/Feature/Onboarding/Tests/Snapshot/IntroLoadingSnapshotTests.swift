import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureOnboarding

@MainActor
final class IntroLoadingSnapshotTests: XCTestCase {
  private func makeView() -> some View {
    var state = IntroFeature.State()
    state.isLoading = true
    return IntroView(
      store: Store(initialState: state) {
        IntroFeature()
      }
    )
  }

  func test_intro_loading_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_intro_loading_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
