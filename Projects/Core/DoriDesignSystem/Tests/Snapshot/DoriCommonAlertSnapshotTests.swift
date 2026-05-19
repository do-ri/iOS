import SnapshotTesting
import SwiftUI
import XCTest

@testable import DoriDesignSystem

@MainActor
final class DoriCommonAlertSnapshotTests: XCTestCase {
  private func alert() -> some View {
    DoriCommonAlert(
      isPresented: .constant(true),
      title: "로그아웃 하시겠습니까?",
      secondaryButton: AlertButton(.no) {},
      primaryButton: AlertButton(.yes) {}
    )
    .frame(width: 390, height: 800)
  }

  func test_alert_light() {
    assertSnapshot(
      of: alert(),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_alert_dark() {
    assertSnapshot(
      of: alert(),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
