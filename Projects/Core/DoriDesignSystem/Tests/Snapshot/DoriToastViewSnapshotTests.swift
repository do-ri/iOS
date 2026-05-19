import SnapshotTesting
import SwiftUI
import XCTest

@testable import DoriDesignSystem

@MainActor
final class DoriToastViewSnapshotTests: XCTestCase {
  private static let stableID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

  private func toast(_ type: ToastType, message: String) -> some View {
    DoriToastView(
      toast: DoriToast(id: Self.stableID, type: type, message: message)
    )
    .frame(width: 390)
    .background(UIAsset.Colors.bgPrimary.color)
  }

  func test_success_light() {
    assertSnapshot(
      of: toast(.success, message: "저장되었습니다"),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_success_dark() {
    assertSnapshot(
      of: toast(.success, message: "저장되었습니다"),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  func test_error_light() {
    assertSnapshot(
      of: toast(.error, message: "처리에 실패했습니다"),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_error_dark() {
    assertSnapshot(
      of: toast(.error, message: "처리에 실패했습니다"),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  func test_info_light() {
    assertSnapshot(
      of: toast(.info, message: "안내 메시지"),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_info_dark() {
    assertSnapshot(
      of: toast(.info, message: "안내 메시지"),
      as: .image(
        layout: .sizeThatFits,
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
