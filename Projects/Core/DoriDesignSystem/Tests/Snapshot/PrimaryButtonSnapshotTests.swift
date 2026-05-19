import SnapshotTesting
import SwiftUI
import XCTest

@testable import DoriDesignSystem

@MainActor
final class PrimaryButtonSnapshotTests: XCTestCase {
  private func host(@ViewBuilder _ content: () -> some View) -> some View {
    content()
      .padding(16)
      .frame(width: 320)
      .background(UIAsset.Colors.bgPrimary.color)
  }

  func test_enabled_light() {
    assertSnapshot(
      of: host { PrimaryButton(title: "저장") },
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_enabled_dark() {
    assertSnapshot(
      of: host { PrimaryButton(title: "저장") },
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  func test_disabled_light() {
    assertSnapshot(
      of: host { PrimaryButton(title: "저장").isEnable(false) },
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_disabled_dark() {
    assertSnapshot(
      of: host { PrimaryButton(title: "저장").isEnable(false) },
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
