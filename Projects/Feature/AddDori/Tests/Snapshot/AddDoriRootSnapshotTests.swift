import ComposableArchitecture
import DoriCore
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureAddDori

@MainActor
final class AddDoriRootSnapshotTests: XCTestCase {
  /// 2025-05-01 09:00 KST — fixed date so baseline stable.
  private static let fixedEventDate = Date(timeIntervalSince1970: 1_746_057_600)

  private func makeView(state: AddDoriFeature.State = AddDoriFeature.State()) -> some View {
    AddDoriView(
      store: Store(initialState: state) {
        AddDoriFeature()
      }
    )
  }

  // MARK: - Step 1 (root entry)

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

  // MARK: - Step 3 (final page)

  private func step3State() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 2
    state.searchQuery = "조카"
    state.selectedRelationship = .family
    state.selectedEventType = .birthday
    state.amountInput.text = "50000"
    state.eventDate = Self.fixedEventDate
    return state
  }

  func test_addDoriRoot_step3_light() {
    assertSnapshot(
      of: makeView(state: step3State()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_addDoriRoot_step3_dark() {
    assertSnapshot(
      of: makeView(state: step3State()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
