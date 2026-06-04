import DoriCore
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureCalendar

@MainActor
final class DayDetailSheetSnapshotTests: XCTestCase {
  /// 2025-05-01 00:00 UTC — baseline 안정성
  private static let fixedDate = Date(timeIntervalSince1970: 1_746_057_600)

  // MARK: - Empty doris (해당 일 거래 없음)

  private func emptyView() -> some View {
    DayDetailSheet(date: Self.fixedDate, doris: [])
      .frame(width: 393, height: 600)
      .background(Color(uiColor: .systemBackground))
  }

  func test_dayDetailSheet_empty_light() {
    assertSnapshot(
      of: emptyView(),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_dayDetailSheet_empty_dark() {
    assertSnapshot(
      of: emptyView(),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
