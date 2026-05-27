import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

@MainActor
final class DoriListSnapshotTests: XCTestCase {
  private func makeView() -> some View {
    DoriListView(
      store: Store(initialState: DoriListFeature.State()) {
        DoriListFeature()
      }
    )
  }

  func test_doriList_empty_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriList_empty_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
