//
//  NotificationListView.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/11/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem
import DoriNetwork

public struct NotificationListView: View {
  @Bindable var store: StoreOf<NotificationListFeature>
  @Environment(\.dismiss) private var dismiss

  public init(store: StoreOf<NotificationListFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(store.items) { item in
          NotificationRowView(item: item)
            .onAppear {
              store.send(.loadNextPageIfNeeded(item))
            }

          Rectangle()
            .fill(.borderDefault)
            .frame(height: 0.5)
        }

        if store.isLoading && !store.items.isEmpty {
          ProgressView()
            .padding(.vertical, 16)
        }
      }
    }
    .overlay {
      if store.items.isEmpty {
        if store.isLoading {
          ProgressView()
        } else {
          DoriEmptyView(.notificationList)
        }
      }
    }
    .background(.bgPrimary)
    .doriNavigationBar(
      .backWithTitleAndActions(
        "알림",
        onBack: { dismiss() },
        trailing: [
          .iconButton(
            image: UIAsset.Icons.notificationSetting.image.renderingMode(.template),
            action: { store.send(.settingsButtonTapped) }
          )
        ]
      )
    )
    .navigationDestination(
      item: $store.scope(state: \.notificationSettings, action: \.notificationSettings)
    ) { settingsStore in
      NotificationSettingsView(store: settingsStore)
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}

// MARK: - Preview

#Preview {
  NavigationStack {
    NotificationListView(
      store: Store(initialState: NotificationListFeature.State()) {
        NotificationListFeature()
      } withDependencies: {
        $0.notificationListAPIClient = .previewValue
      }
    )
  }
}
