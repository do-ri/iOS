//
//  MainTabView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import SwiftUI
import ComposableArchitecture
import FeatureCalendar
import FeatureHistory
import FeatureMyPage

@Reducer
struct MainTabFeature {
  @ObservableState
  struct State {
    var selectedTab: Tab = .calendar
    var calendar = CalendarFeature.State()
    var history = HistoryFeature.State()
    var myPage = MyPageFeature.State()

    enum Tab: Equatable {
      case calendar, history, myPage
    }

    // 파생 상태: 모든 탭이 root depth면 TabBar 표시
    var isTabBarVisible: Bool {
      history.path.isEmpty &&
      calendar.addDori == nil &&
      myPage.navigationPath.isEmpty
    }
  }

  enum Action {
    case tabSelected(State.Tab)
    case calendar(CalendarFeature.Action)
    case history(HistoryFeature.Action)
    case myPage(MyPageFeature.Action)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case needsAuthentication
    }
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.calendar, action: \.calendar) {
      CalendarFeature()
    }
    Scope(state: \.history, action: \.history) {
      HistoryFeature()
    }
    Scope(state: \.myPage, action: \.myPage) {
      MyPageFeature()
    }
    Reduce { state, action in
      switch action {
      case let .tabSelected(tab):
        state.selectedTab = tab
        return .none

      case .myPage(.delegate(.didLogout)):
        return .send(.delegate(.needsAuthentication))

      case .myPage(.delegate(.didWithdraw)):
        return .send(.delegate(.needsAuthentication))

      case .myPage(.delegate(.authExpired)):
        return .send(.delegate(.needsAuthentication))

      case .calendar, .history, .myPage, .delegate:
        return .none
      }
    }
  }
}

struct MainTabView: View {
  @Bindable var store: StoreOf<MainTabFeature>

  var body: some View {
    VStack(spacing: 0) {
      // Content
      Group {
        switch store.selectedTab {
        case .calendar:
          CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
        case .history:
          HistoryView(store: store.scope(state: \.history, action: \.history))
        case .myPage:
          MyPageView(store: store.scope(state: \.myPage, action: \.myPage))
        }
      }

      // TabBar
      if store.isTabBarVisible {
        CustomTabBar(
          selectedTab: $store.selectedTab.sending(\.tabSelected)
        )
        .transition(.move(edge: .bottom))
      }
    }
    .ignoresSafeArea(.keyboard)
    .animation(.easeInOut(duration: 0.2), value: store.isTabBarVisible)
  }
}

#Preview {
  MainTabView(
    store: Store(initialState: MainTabFeature.State()) {
      MainTabFeature()
    }
  )
}
