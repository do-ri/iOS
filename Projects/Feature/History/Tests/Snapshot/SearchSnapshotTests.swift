import ComposableArchitecture
import DoriCore
import DoriTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

@MainActor
final class SearchSnapshotTests: XCTestCase {
  private func makeView(state: SearchFeature.State) -> some View {
    SearchView(
      store: Store(initialState: state) {
        SearchFeature()
      }
    )
  }

  // MARK: - Empty (검색 시작 전)

  func test_search_empty_light() {
    assertSnapshot(
      of: makeView(state: SearchFeature.State()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_search_empty_dark() {
    assertSnapshot(
      of: makeView(state: SearchFeature.State()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Typed, no results

  private func typedNoResultsState() -> SearchFeature.State {
    var state = SearchFeature.State()
    state.searchQuery = "없는이름"
    state.searchResults = []
    return state
  }

  func test_search_typedNoResults_light() {
    assertSnapshot(
      of: makeView(state: typedNoResultsState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_search_typedNoResults_dark() {
    assertSnapshot(
      of: makeView(state: typedNoResultsState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Typed, with results

  private func typedWithResultsState() -> SearchFeature.State {
    var state = SearchFeature.State()
    state.searchQuery = "조"
    state.searchResults = Dori.mockList
    return state
  }

  func test_search_typedWithResults_light() {
    assertSnapshot(
      of: makeView(state: typedWithResultsState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_search_typedWithResults_dark() {
    assertSnapshot(
      of: makeView(state: typedWithResultsState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
