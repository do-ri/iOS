//
//  MyPageView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/5/26.
//

import ComposableArchitecture
import DoriDesignSystem
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
      VStack(alignment: .leading, spacing: 24) {
        settingInfoView
        accountInfoView
        
        Spacer()
      }
      .padding(.horizontal, 16)
      .background(.doriWhite)
      .navigationTitle("마이페이지")
      .toolbarTitleDisplayMode(.inline)
      .overlay {
        if store.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.2))
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
        .foregroundStyle(.grey600)
      
      HStack {
        Text("앱 버전")
          .pretendard(.body(.r3))
          .foregroundStyle(.doriBlack)
        Spacer()
        Text(Self.versionString)
          .pretendard(.body(.r3))
          .foregroundStyle(.grey400)
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
        .foregroundStyle(.grey600)
      
      NavigationRow("로그아웃") {
        store.send(.logoutButtonTapped)
      }
      .padding(.bottom, 12)
      
      NavigationRow("탈퇴하기") {
        store.send(.withdrawButtonTapped)
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
      .foregroundStyle(.doriBlack)
    }
  }
}
