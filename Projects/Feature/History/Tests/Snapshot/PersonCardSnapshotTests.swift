import DoriCore
import DoriTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

@MainActor
final class PersonCardSnapshotTests: XCTestCase {
  private func host(_ partner: PartnerSummary) -> some View {
    PersonCardView(partner: partner)
      .padding(16)
      .frame(width: 393)
      .background(Color(uiColor: .systemBackground))
  }

  // MARK: - Collapsed (default)
  //
  // expanded 상태는 PersonCardView 내부 @State 이므로 외부에서 직접 토글 불가.
  // expanded baseline 은 컴포넌트가 binding 받도록 리팩터 후 별도 PR 에서 추가.

  func test_personCard_collapsed_light() {
    assertSnapshot(
      of: host(PartnerSummary.mock),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_personCard_collapsed_dark() {
    assertSnapshot(
      of: host(PartnerSummary.mock),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
