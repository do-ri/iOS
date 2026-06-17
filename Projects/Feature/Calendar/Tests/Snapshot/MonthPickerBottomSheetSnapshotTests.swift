import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureCalendar

@MainActor
final class MonthPickerBottomSheetSnapshotTests: XCTestCase {
  /// 2026-03-01 00:00 UTC — fixed date so baseline is stable across runs
  private static let fixedDate: Date = {
    var components = DateComponents()
    components.year = 2026
    components.month = 3
    components.day = 1
    components.hour = 0
    components.minute = 0
    components.second = 0
    components.timeZone = TimeZone(identifier: "UTC")
    return Calendar.current.date(from: components)!
  }()

  private func makeView() -> some View {
    MonthPickerBottomSheet(
      selectedDate: Self.fixedDate,
      onDateChanged: { _ in },
      onConfirm: {}
    )
    .frame(width: 393)
  }

  func test_monthPickerBottomSheet_default() {
    assertSnapshotPair(of: makeView(), layout: .sizeThatFits)
  }
}
