//
//  MyPageView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/5/26.
//

import ComposableArchitecture
import DoriCore
import DoriDesignSystem
import FeatureNotification
import SwiftUI

public struct MyPageView: View {
  @Bindable var store: StoreOf<MyPageFeature>

  private static let versionString =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  private static let privacyPolicyURL = URL(
    string: "https://xonmin.notion.site/dori-privacy-policy?source=copy_link"
  )!

  public init(store: StoreOf<MyPageFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(path: navigationPathBinding) {
      ZStack {
        UIAsset.Colors.bgPrimary.color
          .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 24) {
          settingInfoView
          accountInfoView
          notificationInfoView
          if BuildEnvironment.current.isTestingEnabled {
            debugInfoView
          }

          Spacer()
        }
        .padding(.horizontal, 16)
      }
      .doriNavigationBar(.titleWithActions("마이페이지"))
      .overlay {
        if store.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bgScrim)
        }
      }
      .overlay {
        DoriCommonAlert(
          isPresented: logoutAlertBinding,
          title: "로그아웃 하시겠습니까?",
          secondaryButton: AlertButton(.no) {
            store.send(.logoutAlertDismissed)
          },
          primaryButton: AlertButton(.yes) {
            store.send(.logoutConfirmed)
          }
        )
        .opacity(store.isLogoutAlertPresented ? 1 : 0)
      }
      .overlay {
        DoriCommonAlert(
          isPresented: withdrawAlertBinding,
          title: "회원탈퇴",
          description: "정말 도리를 탈퇴하실건가요?\n재가입 시에도 이용 내역은 복구되지 않습니다.",
          secondaryButton: AlertButton(.no) {
            store.send(.withdrawAlertDismissed)
          },
          primaryButton: AlertButton(.yes) {
            store.send(.withdrawConfirmed)
          }
        )
        .opacity(store.isWithdrawAlertPresented ? 1 : 0)
      }
      .onAppear {
        store.send(.onAppear)
      }
      .navigationDestination(for: MyPageFeature.Route.self) { route in
        switch route {
        case .privacyPolicy:
          CommonWebView(
            navigationTitle: "개인정보처리방침",
            url: Self.privacyPolicyURL
          )
        case .notificationSettings:
          NotificationSettingsView(
            store: store.scope(
              state: \.notificationSettings,
              action: \.notificationSettings
            )
          )
        case .fcmPushTest:
          FCMPushTestView(
            store: store.scope(
              state: \.fcmPushTest,
              action: \.fcmPushTest
            )
          )
        }
      }
    }
    .doriToast(store.toastItem, alignment: .bottom) {
      store.send(.toastDismissed)
    }
  }

  private var settingInfoView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("정보")
        .pretendard(.subtitle(.m2))
        .foregroundStyle(.textSecondary)
      
      HStack {
        Text("앱 버전")
          .pretendard(.body(.r3))
          .foregroundStyle(.textPrimary)
        Spacer()
        Text(Self.versionString)
          .pretendard(.body(.r3))
          .foregroundStyle(.textDisabled)
      }
      .padding(.bottom, 12)
      
      NavigationRow("개인정보처리방침") {
        store.send(.privacyPolicyTapped)
      }
      .padding(.bottom, 29)
      
      
      Divider()
    }
  }
  
  private var accountInfoView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("계정")
        .pretendard(.subtitle(.m2))
        .foregroundStyle(.textSecondary)
      
      NavigationRow("로그아웃") {
        store.send(.logoutButtonTapped)
      }
      .padding(.bottom, 12)
      
      NavigationRow("탈퇴하기") {
        store.send(.withdrawButtonTapped)
      }
      
      Divider()
    }
  }
  
  private var notificationInfoView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("알림")
        .pretendard(.subtitle(.m2))
        .foregroundStyle(.textSecondary)

      NavigationRow("앱 알림 설정") {
        store.send(.notificationSettingsTapped)
      }

    }
  }

  private var debugInfoView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Divider()

      HStack {
        Text("디버깅 툴")
          .pretendard(.subtitle(.m2))
          .foregroundStyle(.textSecondary)
        Spacer()
        Text(BuildEnvironment.current.displayName)
          .pretendard(.body(.r3))
          .foregroundStyle(.textDisabled)
      }

      NavigationRow("FCM 푸시 테스트") {
        store.send(.fcmPushTestTapped)
      }
    }
  }
  
  private var logoutAlertBinding: Binding<Bool> {
    Binding(
      get: { store.isLogoutAlertPresented },
      set: { isPresented in
        if !isPresented {
          store.send(.logoutAlertDismissed)
        }
      }
    )
  }

  private var withdrawAlertBinding: Binding<Bool> {
    Binding(
      get: { store.isWithdrawAlertPresented },
      set: { isPresented in
        if !isPresented {
          store.send(.withdrawAlertDismissed)
        }
      }
    )
  }

  private var navigationPathBinding: Binding<[MyPageFeature.Route]> {
    Binding(
      get: { store.navigationPath },
      set: { store.send(.navigationPathChanged($0)) }
    )
  }
}

#Preview {
  MyPageView(
    store: Store(initialState: MyPageFeature.State()) {
      MyPageFeature()
    }
  )
}

struct NavigationRow: View {
  private let title: String
  private let action: () -> Void
  init(
    _ title: String,
    action: @escaping @MainActor () -> Void
  ) {
    self.title = title
    self.action = action
  }
  
  var body: some View {
    Button {
      action()
    } label: {
      HStack {
        Text(title)
          .pretendard(.body(.r3))
        Spacer()
        Image(systemName: "chevron.right")
      }
      .foregroundStyle(.textPrimary)
    }
  }
}
