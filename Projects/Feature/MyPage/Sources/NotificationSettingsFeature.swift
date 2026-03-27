//
//  NotificationSettingsFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/19/26.
//

import ComposableArchitecture

@Reducer
public struct NotificationSettingsFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable, Sendable {
    public var isAllPushEnabled: Bool
    public var isDoriAlertEnabled: Bool
    public var isRecordReminderEnabled: Bool
    public var isMonthlyEnabled: Bool
    public var isRelationBalanceEnabled: Bool
    public var isActivitySummaryEnabled: Bool

    public init(
      isAllPushEnabled: Bool = false,
      isDoriAlertEnabled: Bool = false,
      isRecordReminderEnabled: Bool = false,
      isMonthlyEnabled: Bool = false,
      isRelationBalanceEnabled: Bool = false,
      isActivitySummaryEnabled: Bool = false
    ) {
      self.isAllPushEnabled = isAllPushEnabled
      self.isDoriAlertEnabled = isDoriAlertEnabled
      self.isRecordReminderEnabled = isRecordReminderEnabled
      self.isMonthlyEnabled = isMonthlyEnabled
      self.isRelationBalanceEnabled = isRelationBalanceEnabled
      self.isActivitySummaryEnabled = isActivitySummaryEnabled
    }
  }

  public enum Action: Equatable, Sendable {
    case allPushToggled(Bool)
    case doriAlertToggled(Bool)
    case recordReminderToggled(Bool)
    case monthlyToggled(Bool)
    case relationBalanceToggled(Bool)
    case activitySummaryToggled(Bool)
    case backButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case didTapBack
    }
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .allPushToggled(let value):
      state.isAllPushEnabled = value
      return .none

    case .doriAlertToggled(let value):
      state.isDoriAlertEnabled = value
      return .none

    case .recordReminderToggled(let value):
      state.isRecordReminderEnabled = value
      return .none

    case .monthlyToggled(let value):
      state.isMonthlyEnabled = value
      return .none

    case .relationBalanceToggled(let value):
      state.isRelationBalanceEnabled = value
      return .none

    case .activitySummaryToggled(let value):
      state.isActivitySummaryEnabled = value
      return .none

    case .backButtonTapped:
      return .send(.delegate(.didTapBack))

    case .delegate:
      return .none
    }
  }
}
