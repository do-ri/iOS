import DoriCore
import DoriTestSupport
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

@MainActor
final class TransactionRowSnapshotTests: XCTestCase {
  private func host(_ dori: Dori) -> some View {
    TransactionRowView(dori: dori)
      .padding(16)
      .frame(width: 393)
      .background(Color(uiColor: .systemBackground))
  }

  // MARK: - Judori (준 도리)

  func test_transactionRow_judori_light() {
    assertSnapshot(
      of: host(Dori.mockJudori),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_transactionRow_judori_dark() {
    assertSnapshot(
      of: host(Dori.mockJudori),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Baddori (받은 도리)

  func test_transactionRow_baddori_light() {
    assertSnapshot(
      of: host(Dori.mockBaddori),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_transactionRow_baddori_dark() {
    assertSnapshot(
      of: host(Dori.mockBaddori),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
