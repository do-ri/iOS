import ComposableArchitecture
import DoriCore
import DoriTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

@MainActor
final class PartnerDoriHistorySnapshotTests: XCTestCase {
  private func makeView(state: PartnerDoriHistoryFeature.State) -> some View {
    PartnerDoriHistoryView(
      store: Store(initialState: state) {
        PartnerDoriHistoryFeature()
      }
    )
  }

  private func baseState(filter: DoriFilter) -> PartnerDoriHistoryFeature.State {
    var state = PartnerDoriHistoryFeature.State(
      partnerId: 100,
      partnerName: "조카 1",
      relationship: "가족"
    )
    state.inDoriList = [.mockJudori]
    state.outDoriList = [.mockBaddori]
    state.inDoriTotalAmount = 80_000
    state.outDoriTotalAmount = 50_000
    state.filter = filter
    return state
  }

  // MARK: - All (judori + baddori)

  func test_partnerDoriHistory_all_light() {
    assertSnapshot(
      of: makeView(state: baseState(filter: .all)),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_partnerDoriHistory_all_dark() {
    assertSnapshot(
      of: makeView(state: baseState(filter: .all)),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Judori only

  func test_partnerDoriHistory_judoriOnly_light() {
    assertSnapshot(
      of: makeView(state: baseState(filter: .judori)),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_partnerDoriHistory_judoriOnly_dark() {
    assertSnapshot(
      of: makeView(state: baseState(filter: .judori)),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Baddori only

  func test_partnerDoriHistory_baddoriOnly_light() {
    assertSnapshot(
      of: makeView(state: baseState(filter: .baddori)),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_partnerDoriHistory_baddoriOnly_dark() {
    assertSnapshot(
      of: makeView(state: baseState(filter: .baddori)),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
