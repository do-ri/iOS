//
//  FCMPushTestView.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/27/26.
//

import ComposableArchitecture
import DoriDesignSystem
import SwiftUI

public struct FCMPushTestView: View {
  @Bindable var store: StoreOf<FCMPushTestFeature>

  public init(store: StoreOf<FCMPushTestFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      UIAsset.Colors.bgPrimary.color
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          userIdField
          titleField
          bodyField
          sendButton
          Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
      }

      if store.isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.bgScrim)
      }
    }
    .doriNavigationBar(
      DoriNavigationBarConfig.backWithTitle("FCM 푸시 테스트") {
        store.send(.backButtonTapped)
      }
    )
    .onAppear {
      store.send(.onAppear)
    }
    .doriToast(store.toastItem, alignment: .bottom) {
      store.send(.toastDismissed)
    }
  }

  private var userIdField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("userID")
        .pretendard(.subtitle(.m2))
        .foregroundStyle(.textSecondary)

      HStack {
        Text(store.userId == nil ? "불러오는 중..." : store.userIdDisplayText)
          .pretendard(.body(.r3))
          .foregroundStyle(store.userId == nil ? .grey400 : .doriBlack)
        Spacer()
      }
      .frame(height: 46)
      .padding(.horizontal, 16)
      .background(RoundedRectangle(cornerRadius: 10).fill(.bgPrimary))
      .overlay(RoundedRectangle(cornerRadius: 10).stroke(.borderInput, lineWidth: 1))
    }
  }

  private var titleField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("title")
        .pretendard(.subtitle(.m2))
        .foregroundStyle(.textSecondary)

      DoriTextField(
        "제목을 입력하세요",
        memo: $store.title.sending(\.titleChanged)
      )
    }
  }

  private var bodyField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("body")
        .pretendard(.subtitle(.m2))
        .foregroundStyle(.textSecondary)

      DoriExpandingTextView(
        "내용을 입력하세요",
        text: $store.body.sending(\.bodyChanged)
      )
    }
  }

  private var sendButton: some View {
    PrimaryButton(title: "전송") {
      store.send(.sendButtonTapped)
    }
    .isEnable(store.userId != nil && !store.isLoading)
    .padding(.top, 8)
  }
}

#Preview {
  FCMPushTestView(
    store: Store(initialState: FCMPushTestFeature.State()) {
      FCMPushTestFeature()
    } withDependencies: {
      $0.fcmPushTestAPIClient = .previewValue
    }
  )
}
