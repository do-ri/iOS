import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureMyPage

@MainActor
final class DoriToggleSwitchSnapshotTests: XCTestCase {
  private func makeView(isOn: Bool) -> some View {
    DoriToggleSwitch(isOn: .constant(isOn))
      .padding(16)
  }

  func test_doriToggleSwitch_on_light() {
    assertSnapshot(
      of: makeView(isOn: true),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriToggleSwitch_on_dark() {
    assertSnapshot(
      of: makeView(isOn: true),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  func test_doriToggleSwitch_off_light() {
    assertSnapshot(
      of: makeView(isOn: false),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_doriToggleSwitch_off_dark() {
    assertSnapshot(
      of: makeView(isOn: false),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
