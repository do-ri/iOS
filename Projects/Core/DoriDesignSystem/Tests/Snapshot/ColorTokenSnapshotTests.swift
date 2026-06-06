import SnapshotTesting
import SwiftUI
import XCTest

@testable import DoriDesignSystem

@MainActor
final class ColorTokenSnapshotTests: XCTestCase {
  func test_swatchSheet_light() {
    assertSnapshot(
      of: ColorSwatchSheet(),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_swatchSheet_dark() {
    assertSnapshot(
      of: ColorSwatchSheet(),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
