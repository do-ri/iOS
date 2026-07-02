import ComposableArchitecture
import FeatureNotification
import SnapshotTesting
import SwiftUI
import XCTest

@testable import FeatureMyPage

@MainActor
final class NotificationSettingsSnapshotTests: XCTestCase {
  private func makeView(state: NotificationSettingsFeature.State) -> some View {
    NotificationSettingsView(
      store: Store(initialState: state) {
        NotificationSettingsFeature()
      }
    )
  }

  // MARK: - All push on

  private static let allOnState = NotificationSettingsFeature.State(
    isSystemNotificationEnabled: true,
    isAllPushEnabled: true,
    isDoriAlertEnabled: true,
    isRecordReminderEnabled: true,
    isMonthlyEnabled: true,
    isRelationBalanceEnabled: true,
    isActivitySummaryEnabled: true
  )

  func test_notificationSettings_allOn_light() {
    assertSnapshot(
      of: makeView(state: Self.allOnState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_notificationSettings_allOn_dark() {
    assertSnapshot(
      of: makeView(state: Self.allOnState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - All push off

  private static let allOffState = NotificationSettingsFeature.State(
    isSystemNotificationEnabled: true,
    isAllPushEnabled: false,
    isDoriAlertEnabled: false,
    isRecordReminderEnabled: false,
    isMonthlyEnabled: false,
    isRelationBalanceEnabled: false,
    isActivitySummaryEnabled: false
  )

  func test_notificationSettings_allOff_light() {
    assertSnapshot(
      of: makeView(state: Self.allOffState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_notificationSettings_allOff_dark() {
    assertSnapshot(
      of: makeView(state: Self.allOffState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }

  // MARK: - Partial enabled (master on, 일부 자식 토글만 on)

  private static let partialEnabledState = NotificationSettingsFeature.State(
    isSystemNotificationEnabled: true,
    isAllPushEnabled: true,
    isDoriAlertEnabled: true,
    isRecordReminderEnabled: false,
    isMonthlyEnabled: true,
    isRelationBalanceEnabled: false,
    isActivitySummaryEnabled: true
  )

  func test_notificationSettings_partialEnabled_light() {
    assertSnapshot(
      of: makeView(state: Self.partialEnabledState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .light)
      )
    )
  }

  func test_notificationSettings_partialEnabled_dark() {
    assertSnapshot(
      of: makeView(state: Self.partialEnabledState),
      as: .image(
        layout: .fixed(width: 393, height: 852),
        traits: UITraitCollection(userInterfaceStyle: .dark)
      )
    )
  }
}
