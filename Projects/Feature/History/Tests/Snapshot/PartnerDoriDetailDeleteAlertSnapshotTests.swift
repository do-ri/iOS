import ComposableArchitecture
import DoriCore
import DoriTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

/// PLAN(3) P2 의 `test_editDori_deleteAlert` 는 실제 deleteAlert state 가
/// PartnerDoriDetailFeature 에 있어 본 파일에서 검증.
@MainActor
final class PartnerDoriDetailDeleteAlertSnapshotTests: XCTestCase {
  private func makeView(state: PartnerDoriDetailFeature.State) -> some View {
    PartnerDoriDetailView(
      store: Store(initialState: state) {
        PartnerDoriDetailFeature()
      }
    )
  }

  private func deleteAlertState() -> PartnerDoriDetailFeature.State {
    var state = PartnerDoriDetailFeature.State(dori: .mockJudori)
    state.showDeleteAlert = true
    return state
  }

  func test_partnerDoriDetail_deleteAlert_light() {
    assertSnapshot(
      of: makeView(state: deleteAlertState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_partnerDoriDetail_deleteAlert_dark() {
    assertSnapshot(
      of: makeView(state: deleteAlertState()),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
