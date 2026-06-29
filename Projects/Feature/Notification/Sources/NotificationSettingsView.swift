//
//  NotificationSettingsView.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/19/26.
//

import ComposableArchitecture
import DoriDesignSystem
import SwiftUI

public struct NotificationSettingsView: View {
  @Bindable var store: StoreOf<NotificationSettingsFeature>
  @Environment(\.scenePhase) private var scenePhase

  public init(store: StoreOf<NotificationSettingsFeature>) {
    self.store = store
  }

  private var allPushDescrition: String {
    store.isAllPushEnabled ? "앱 알림 받기" : "알림이 꺼져 있어요\n알림을 켜고 소식을 받아보세요"
  }

  public var body: some View {
    ZStack {
      UIAsset.Colors.bgPrimary.color
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          if !store.isSystemNotificationEnabled {
            systemNotificationDisabledBanner
          }

          // 전체 푸시 수신 (Type 1: HStack { VStack { title, description }, switch })
          notificationRowWithDescription(
            title: "앱 알림 받기",
            description: allPushDescrition,
            isOn: $store.isAllPushEnabled.sending(\.allPushToggled)
          )

          VStack(alignment: .leading, spacing: 24) {
            Divider()

            // 도리 알림 (Type 1)
            notificationRowWithDescription(
              title: "도리 알림",
              description: "등록한 일정에 맞춰 알려드려요",
              isOn: $store.isDoriAlertEnabled.sending(\.doriAlertToggled)
            )

            Divider()

            // 기록 알림 (Type 3: VStack { title, description } - 섹션 헤더)
            notificationSectionHeader(
              title: "기록 알림",
              description: "기록을 도와주는 알림이에요"
            )

            // 기록 리마인드 (Type 2: HStack { title, switch })
            notificationRowSimple(
              title: "기록 리마인드",
              isOn: $store.isRecordReminderEnabled.sending(\.recordReminderToggled)
            )

            // 월간 요약 (Type 2)
            notificationRowSimple(
              title: "월간 요약",
              isOn: $store.isMonthlyEnabled.sending(\.monthlyToggled)
            )

            Divider()

            // 관계 인사이트 알림 (Type 3 - 섹션 헤더)
            notificationSectionHeader(
              title: "관계 인사이트 알림",
              description: "관계 흐름을 분석해 알려드려요"
            )

            // 관계 균형 알림 (Type 2)
            notificationRowSimple(
              title: "관계 균형 알림",
              isOn: $store.isRelationBalanceEnabled.sending(\.relationBalanceToggled)
            )

            // 활동 요약 알림 (Type 2)
            notificationRowSimple(
              title: "활동 요약 알림",
              isOn: $store.isActivitySummaryEnabled.sending(\.activitySummaryToggled)
            )
          }
          .overlay {
            if !store.isAllPushEnabled {
              UIAsset.Colors.bgPrimary.color
                .opacity(0.6)
                .allowsHitTesting(true)
            }
          }
        }
        .padding(.top, 24)
        .padding(.leading, 16)
        .padding(.trailing, 20)
      }
    }
    .doriNavigationBar(
      DoriNavigationBarConfig.backWithTitle("앱 알림 설정") {
        store.send(.backButtonTapped)
      }
    )
    .onAppear { store.send(.onAppear) }
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase == .active {
        store.send(.scenePhaseBecameActive)
      }
    }
  }

  // MARK: - 기기 알림 OFF 배너

  @ViewBuilder
  private var systemNotificationDisabledBanner: some View {
    Button {
      store.send(.openSystemSettingsTapped)
      openSystemNotificationSettings()
    } label: {
      HStack(alignment: .top, spacing: 12) {
        
        Image(.pushDisableBell)
          .font(.system(size: 20))
          .foregroundStyle(.textSecondary)

        Text("기기알림은 켜시면 새로운 소식을\n확인할 수 있습니다.")
          .pretendard(.body(.r6))
          .foregroundStyle(.textSecondary)
          .frame(maxWidth: .infinity, alignment: .leading)

        HStack(spacing: 2) {
          Text("설정")
            .pretendard(.body(.m5))
            .foregroundStyle(Color.settingColor)
          Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.settingColor)
        }
      }
      .frame(maxWidth: .infinity)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
  }

  @MainActor
  private func openSystemNotificationSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }

  // MARK: - Type 1: HStack { VStack { title, description }, Spacer, switch }

  @ViewBuilder
  private func notificationRowWithDescription(
    title: String,
    description: String,
    isOn: Binding<Bool>
  ) -> some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .pretendard(.body(.m3))
          .foregroundStyle(.textPrimary)
        Text(description)
          .pretendard(.body(.r6))
          .foregroundStyle(.textSecondary)
      }

      Spacer()

      DoriToggleSwitch(isOn: isOn)
    }
  }

  // MARK: - Type 2: HStack { title, Spacer, switch }

  @ViewBuilder
  private func notificationRowSimple(
    title: String,
    isOn: Binding<Bool>
  ) -> some View {
    HStack {
      Text(title)
        .pretendard(.body(.r3))
        .foregroundStyle(.textPrimary)

      Spacer()

      DoriToggleSwitch(isOn: isOn)
    }
  }

  // MARK: - Type 3: VStack { title, description } (섹션 헤더, 스위치 없음)

  @ViewBuilder
  private func notificationSectionHeader(
    title: String,
    description: String
  ) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .pretendard(.body(.m3))
        .foregroundStyle(.textPrimary)
      Text(description)
        .pretendard(.body(.r6))
        .foregroundStyle(.textSecondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private extension Color {
  static let settingColor: Color = .init(red: 100/255, green: 130/255, blue: 173/255)
}

#Preview {
  NavigationStack {
    NotificationSettingsView(
      store: Store(initialState: NotificationSettingsFeature.State()) {
        NotificationSettingsFeature()
      }
    )
  }
}
