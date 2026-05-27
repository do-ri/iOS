import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureAddDori

@MainActor
final class AddDoriRootSnapshotTests: XCTestCase {
  private func makeView() -> some View {
    AddDoriView(
      store: Store(initialState: AddDoriFeature.State()) {
        AddDoriFeature()
      }
    )
  }

  func test_addDoriRoot_step1_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_addDoriRoot_step1_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
