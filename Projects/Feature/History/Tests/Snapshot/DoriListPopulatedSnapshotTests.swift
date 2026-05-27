import ComposableArchitecture
import DoriCore
import DoriTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

@MainActor
final class DoriListPopulatedSnapshotTests: XCTestCase {
  private func makeView() -> some View {
    var state = DoriListFeature.State()
    state.partners = PartnerSummary.mockList
    return DoriListView(
      store: Store(initialState: state) {
        DoriListFeature()
      }
    )
  }

  func test_doriList_populated_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriList_populated_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
