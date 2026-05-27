import ComposableArchitecture
import DoriCore
import DoriTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

@MainActor
final class EditDoriSnapshotTests: XCTestCase {
  private func makeView(state: EditDoriFeature.State) -> some View {
    EditDoriView(
      store: Store(initialState: state) {
        EditDoriFeature()
      }
    )
  }

  // MARK: - Default

  func test_editDori_default_light() {
    assertSnapshot(
      of: makeView(state: EditDoriFeature.State(dori: .mockJudori)),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_editDori_default_dark() {
    assertSnapshot(
      of: makeView(state: EditDoriFeature.State(dori: .mockJudori)),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Date picker open (bgScrim)

  private func datePickerOpenState() -> EditDoriFeature.State {
    var state = EditDoriFeature.State(dori: .mockJudori)
    state.isDatePickerVisible = true
    return state
  }

  func test_editDori_datePickerOpen_light() {
    assertSnapshot(
      of: makeView(state: datePickerOpenState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_editDori_datePickerOpen_dark() {
    assertSnapshot(
      of: makeView(state: datePickerOpenState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
