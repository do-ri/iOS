import DoriCore
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureCalendar

@MainActor
final class DoriSegmentControlSnapshotTests: XCTestCase {
  private struct Host: View {
    @State var selectedType: TransactionType
    var body: some View {
      DoriSegmentControl(selectedType: $selectedType)
        .padding(16)
        .frame(width: 360)
        .background(Color(uiColor: .systemBackground))
    }
  }

  // MARK: - Judori selected

  func test_doriSegmentControl_judori_light() {
    assertSnapshot(
      of: Host(selectedType: .judori),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriSegmentControl_judori_dark() {
    assertSnapshot(
      of: Host(selectedType: .judori),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Baddori selected

  func test_doriSegmentControl_baddori_light() {
    assertSnapshot(
      of: Host(selectedType: .baddori),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriSegmentControl_baddori_dark() {
    assertSnapshot(
      of: Host(selectedType: .baddori),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
