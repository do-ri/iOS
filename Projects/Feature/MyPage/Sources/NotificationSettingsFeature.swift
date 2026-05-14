//
//  NotificationSettingsFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/19/26.
//

import ComposableArchitecture
import DoriNetwork
import Foundation
import UserNotifications

@Reducer
public struct NotificationSettingsFeature {
  @Dependency(\.notificationSettingsAPIClient) var notificationSettingsAPIClient

  public init() {}

  // 서버 typeCode 정의 (Swagger /notifications/settings)
  public enum NotificationTypeCode: String, Sendable {
    case doriAlert = "DORI_ALERT"
    case recordRemind = "RECORD_REMIND"
    case monthlySummary = "MONTHLY_SUMMARY"
    case relationBalance = "RELATION_BALANCE"
    case activitySummary = "ACTIVITY_SUMMARY"
  }

  @ObservableState
  public struct State: Equatable, Sendable {
    public var isSystemNotificationEnabled: Bool
    public var isAllPushEnabled: Bool
    public var isDoriAlertEnabled: Bool
    public var isRecordReminderEnabled: Bool
    public var isMonthlyEnabled: Bool
    public var isRelationBalanceEnabled: Bool
    public var isActivitySummaryEnabled: Bool
    public var isLoading: Bool
    public var errorMessage: String?

    public init(
      isSystemNotificationEnabled: Bool = true,
      isAllPushEnabled: Bool = false,
      isDoriAlertEnabled: Bool = false,
      isRecordReminderEnabled: Bool = false,
      isMonthlyEnabled: Bool = false,
      isRelationBalanceEnabled: Bool = false,
      isActivitySummaryEnabled: Bool = false,
      isLoading: Bool = false,
      errorMessage: String? = nil
    ) {
      self.isSystemNotificationEnabled = isSystemNotificationEnabled
      self.isAllPushEnabled = isAllPushEnabled
      self.isDoriAlertEnabled = isDoriAlertEnabled
      self.isRecordReminderEnabled = isRecordReminderEnabled
      self.isMonthlyEnabled = isMonthlyEnabled
      self.isRelationBalanceEnabled = isRelationBalanceEnabled
      self.isActivitySummaryEnabled = isActivitySummaryEnabled
      self.isLoading = isLoading
      self.errorMessage = errorMessage
    }
  }

  public enum Action: Equatable, Sendable {
    case onAppear
    case scenePhaseBecameActive
    case systemNotificationStatusUpdated(Bool)
    case openSystemSettingsTapped
    case settingsLoaded([NotificationSettingResponse])
    case settingsLoadFailed(String)
    case allPushToggled(Bool)
    case doriAlertToggled(Bool)
    case recordReminderToggled(Bool)
    case monthlyToggled(Bool)
    case relationBalanceToggled(Bool)
    case activitySummaryToggled(Bool)
    case updateFailed(typeCode: String, previousValue: Bool, message: String)
    case backButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case didTapBack
    }
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .onAppear:
      state.isLoading = true
      state.errorMessage = nil
      let client = notificationSettingsAPIClient
      return .merge(
        .run { send in
          do {
            let settings = try await client.fetchSettings()
            await send(.settingsLoaded(settings))
          } catch {
            await send(.settingsLoadFailed(error.localizedDescription))
          }
        },
        .run { send in
          let enabled = await Self.fetchSystemNotificationEnabled()
          await send(.systemNotificationStatusUpdated(enabled))
        }
      )

    case .scenePhaseBecameActive:
      return .run { send in
        let enabled = await Self.fetchSystemNotificationEnabled()
        await send(.systemNotificationStatusUpdated(enabled))
      }

    case .systemNotificationStatusUpdated(let enabled):
      state.isSystemNotificationEnabled = enabled
      return .none

    case .openSystemSettingsTapped:
      return .none

    case .settingsLoaded(let settings):
      state.isLoading = false
      for setting in settings {
        applySetting(typeCode: setting.typeCode, enabled: setting.enabled, state: &state)
      }
      return .none

    case .settingsLoadFailed(let message):
      state.isLoading = false
      state.errorMessage = message
      return .none

    case .allPushToggled(let value):
      // TODO: OS 시스템 알림 설정과 연동 (UNUserNotificationCenter / 시스템 설정 화면 이동)
      state.isAllPushEnabled = value
      return .none

    case .doriAlertToggled(let value):
      let previous = state.isDoriAlertEnabled
      state.isDoriAlertEnabled = value
      return updateSetting(.doriAlert, enabled: value, previousValue: previous)

    case .recordReminderToggled(let value):
      let previous = state.isRecordReminderEnabled
      state.isRecordReminderEnabled = value
      return updateSetting(.recordRemind, enabled: value, previousValue: previous)

    case .monthlyToggled(let value):
      let previous = state.isMonthlyEnabled
      state.isMonthlyEnabled = value
      return updateSetting(.monthlySummary, enabled: value, previousValue: previous)

    case .relationBalanceToggled(let value):
      let previous = state.isRelationBalanceEnabled
      state.isRelationBalanceEnabled = value
      return updateSetting(.relationBalance, enabled: value, previousValue: previous)

    case .activitySummaryToggled(let value):
      let previous = state.isActivitySummaryEnabled
      state.isActivitySummaryEnabled = value
      return updateSetting(.activitySummary, enabled: value, previousValue: previous)

    case .updateFailed(let typeCode, let previousValue, let message):
      // 실패 시 토글 롤백
      applySetting(typeCode: typeCode, enabled: previousValue, state: &state)
      state.errorMessage = message
      // TODO: Toast 노출 등 사용자 피드백 처리
      return .none

    case .backButtonTapped:
      return .send(.delegate(.didTapBack))

    case .delegate:
      return .none
    }
  }

  private static func fetchSystemNotificationEnabled() async -> Bool {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    switch settings.authorizationStatus {
    case .authorized, .provisional, .ephemeral:
      return true
    case .notDetermined, .denied:
      return false
    @unknown default:
      return false
    }
  }

  private func updateSetting(
    _ type: NotificationTypeCode,
    enabled: Bool,
    previousValue: Bool
  ) -> Effect<Action> {
    let client = notificationSettingsAPIClient
    let typeCode = type.rawValue
    return .run { send in
      do {
        try await client.updateSetting(typeCode, enabled)
      } catch {
        await send(
          .updateFailed(
            typeCode: typeCode,
            previousValue: previousValue,
            message: error.localizedDescription
          )
        )
      }
    }
  }

  private func applySetting(
    typeCode: String,
    enabled: Bool,
    state: inout State
  ) {
    guard let type = NotificationTypeCode(rawValue: typeCode) else { return }
    switch type {
    case .doriAlert:
      state.isDoriAlertEnabled = enabled
    case .recordRemind:
      state.isRecordReminderEnabled = enabled
    case .monthlySummary:
      state.isMonthlyEnabled = enabled
    case .relationBalance:
      state.isRelationBalanceEnabled = enabled
    case .activitySummary:
      state.isActivitySummaryEnabled = enabled
    }
  }
}

// MARK: - API Client

@DependencyClient
public struct NotificationSettingsAPIClient: Sendable {
  public var fetchSettings: @Sendable () async throws -> [NotificationSettingResponse]
  public var updateSetting: @Sendable (_ typeCode: String, _ enabled: Bool) async throws -> Void
}

private enum NotificationSettingsAPIClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "NotificationSettingsAPIClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    }
  }
}

extension NotificationSettingsAPIClient: DependencyKey {
  public static let liveValue = Self(
    fetchSettings: { throw NotificationSettingsAPIClientError.unconfigured },
    updateSetting: { _, _ in throw NotificationSettingsAPIClientError.unconfigured }
  )
}

extension NotificationSettingsAPIClient: TestDependencyKey {
  public static let previewValue = Self(
    fetchSettings: { [] },
    updateSetting: { _, _ in }
  )

  public static let testValue = Self()
}

public extension NotificationSettingsAPIClient {
  static func live(networkService: any NetworkService) -> Self {
    Self(
      fetchSettings: {
        let endpoint = FetchNotificationSettingsEndpoint()
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<[NotificationSettingResponse]>.self
        )
        if let apiError = response.error {
          throw NotificationSettingsAPIClientError.backendError(
            apiError.message ?? "알림 설정 조회에 실패했습니다."
          )
        }
        guard response.success, let data = response.data else {
          throw NotificationSettingsAPIClientError.invalidResponse
        }
        return data
      },
      updateSetting: { typeCode, enabled in
        let endpoint = UpdateNotificationSettingEndpoint(
          typeCode: typeCode,
          enabled: enabled
        )
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<EmptyResponse>.self
        )
        if let apiError = response.error {
          throw NotificationSettingsAPIClientError.backendError(
            apiError.message ?? "알림 설정 변경에 실패했습니다."
          )
        }
        guard response.success else {
          throw NotificationSettingsAPIClientError.invalidResponse
        }
      }
    )
  }
}

public extension DependencyValues {
  var notificationSettingsAPIClient: NotificationSettingsAPIClient {
    get { self[NotificationSettingsAPIClient.self] }
    set { self[NotificationSettingsAPIClient.self] = newValue }
  }
}
