import ComposableArchitecture
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureCalendar

@MainActor
final class CalendarGridSnapshotTests: XCTestCase {
  /// 2025-05-01 00:00 UTC — fixed currentMonth so baseline is stable across runs
  /// and aligns with `Dori.mockJudori.eventDate = "2025-05-01"`.
  private static let fixedMonth = Date(timeIntervalSince1970: 1_746_057_600)

  private func makeView() -> some View {
    CalendarView(
      store: Store(initialState: CalendarFeature.State(currentMonth: Self.fixedMonth)) {
        CalendarFeature()
      }
    )
  }

  func test_calendarGrid_emptyMonth_light() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_calendarGrid_emptyMonth_dark() {
    assertSnapshot(
      of: makeView(),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
