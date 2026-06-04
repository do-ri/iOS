import ComposableArchitecture
import DoriCore
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureAddDori

@MainActor
final class AddDoriPage2SnapshotTests: XCTestCase {
  private func makeView(state: AddDoriFeature.State) -> some View {
    AddDoriView(
      store: Store(initialState: state) {
        AddDoriFeature()
      }
    )
  }

  // MARK: - Default page2 (friend + wedding)

  private func defaultState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 1
    state.searchQuery = "조카"
    state.selectedRelationship = .friend
    state.selectedEventType = .wedding
    return state
  }

  func test_page2_default_light() {
    assertSnapshot(
      of: makeView(state: defaultState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page2_default_dark() {
    assertSnapshot(
      of: makeView(state: defaultState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Birthday event type selected

  private func birthdayState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 1
    state.searchQuery = "조카"
    state.selectedRelationship = .family
    state.selectedEventType = .birthday
    return state
  }

  func test_page2_selected_birthday_light() {
    assertSnapshot(
      of: makeView(state: birthdayState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page2_selected_birthday_dark() {
    assertSnapshot(
      of: makeView(state: birthdayState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Custom event input (other + typed)

  private func customEventState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 1
    state.searchQuery = "조카"
    state.selectedRelationship = .other
    state.customRelationship = "이웃"
    state.selectedEventType = .other
    state.customEventType = "이사"
    return state
  }

  func test_page2_customEventInput_light() {
    assertSnapshot(
      of: makeView(state: customEventState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page2_customEventInput_dark() {
    assertSnapshot(
      of: makeView(state: customEventState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
