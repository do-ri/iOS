import ComposableArchitecture
import DoriCore
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureAddDori

@MainActor
final class AddDoriPage3SnapshotTests: XCTestCase {
  /// 2025-05-01 09:00 KST — fixed date so baseline stable.
  private static let fixedEventDate = Date(timeIntervalSince1970: 1_746_057_600)

  private func makeView(state: AddDoriFeature.State) -> some View {
    AddDoriView(
      store: Store(initialState: state) {
        AddDoriFeature()
      }
    )
  }

  // MARK: - Amount error

  private func amountErrorState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 2
    state.amountInput.text = "9999999999"
    state.amountInput.state = .error(message: "*입력 한도")
    state.eventDate = Self.fixedEventDate
    return state
  }

  func test_page3_amountError_light() {
    assertSnapshot(
      of: makeView(state: amountErrorState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page3_amountError_dark() {
    assertSnapshot(
      of: makeView(state: amountErrorState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Date picker open (bgScrim)

  private func datePickerOpenState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 2
    state.isDatePickerVisible = true
    state.eventDate = Self.fixedEventDate
    return state
  }

  func test_page3_datePickerOpen_light() {
    assertSnapshot(
      of: makeView(state: datePickerOpenState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page3_datePickerOpen_dark() {
    assertSnapshot(
      of: makeView(state: datePickerOpenState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Amount typed (normal)

  private func amountTypedState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 2
    state.amountInput.text = "50000"
    state.eventDate = Self.fixedEventDate
    return state
  }

  func test_page3_amountTyped_light() {
    assertSnapshot(
      of: makeView(state: amountTypedState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page3_amountTyped_dark() {
    assertSnapshot(
      of: makeView(state: amountTypedState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Amount zero

  private func amountZeroState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 2
    state.amountInput.text = "0"
    state.eventDate = Self.fixedEventDate
    return state
  }

  func test_page3_amountZero_light() {
    assertSnapshot(
      of: makeView(state: amountZeroState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page3_amountZero_dark() {
    assertSnapshot(
      of: makeView(state: amountZeroState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
