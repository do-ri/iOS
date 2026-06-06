import ComposableArchitecture
import DoriCore
import DoriTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureAddDori

@MainActor
final class AddDoriPage1SnapshotTests: XCTestCase {
  private func makeView(state: AddDoriFeature.State) -> some View {
    AddDoriView(
      store: Store(initialState: state) {
        AddDoriFeature()
      }
    )
  }

  // MARK: - Empty search query, no results

  private func emptySearchState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 0
    state.searchQuery = "박이름"
    state.searchResults = []
    return state
  }

  func test_page1_emptySearch_light() {
    assertSnapshot(
      of: makeView(state: emptySearchState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page1_emptySearch_dark() {
    assertSnapshot(
      of: makeView(state: emptySearchState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Search results populated

  private func searchResultsState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 0
    state.searchQuery = "조"
    state.searchResults = Dori.mockList
    return state
  }

  func test_page1_searchResults_light() {
    assertSnapshot(
      of: makeView(state: searchResultsState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page1_searchResults_dark() {
    assertSnapshot(
      of: makeView(state: searchResultsState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Partner selected

  private func selectedPartnerState() -> AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 0
    state.searchQuery = "조"
    state.searchResults = Dori.mockList
    state.selectedPartner = Dori.mockList.first
    return state
  }

  func test_page1_selected_light() {
    assertSnapshot(
      of: makeView(state: selectedPartnerState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_page1_selected_dark() {
    assertSnapshot(
      of: makeView(state: selectedPartnerState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
