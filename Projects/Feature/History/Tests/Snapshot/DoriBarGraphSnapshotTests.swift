import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureHistory

@MainActor
final class DoriBarGraphSnapshotTests: XCTestCase {
  private struct Host: View {
    let givenAmount: Int
    let receivedAmount: Int
    var body: some View {
      DoriBarGraphView(givenAmount: givenAmount, receivedAmount: receivedAmount)
        .padding(16)
        .frame(width: 360)
        .background(Color(uiColor: .systemBackground))
    }
  }

  // MARK: - Zero (양쪽 0)

  func test_doriBarGraph_zero_light() {
    assertSnapshot(
      of: Host(givenAmount: 0, receivedAmount: 0),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriBarGraph_zero_dark() {
    assertSnapshot(
      of: Host(givenAmount: 0, receivedAmount: 0),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Judori heavy (준 금액 >> 받은 금액)

  func test_doriBarGraph_judoriHeavy_light() {
    assertSnapshot(
      of: Host(givenAmount: 200_000, receivedAmount: 30_000),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriBarGraph_judoriHeavy_dark() {
    assertSnapshot(
      of: Host(givenAmount: 200_000, receivedAmount: 30_000),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Balanced (양쪽 비슷)

  func test_doriBarGraph_balanced_light() {
    assertSnapshot(
      of: Host(givenAmount: 100_000, receivedAmount: 100_000),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriBarGraph_balanced_dark() {
    assertSnapshot(
      of: Host(givenAmount: 100_000, receivedAmount: 100_000),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
