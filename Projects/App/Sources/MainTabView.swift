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
  struct State: Equatable {
    var selectedTab: Tab = .calendar
    var calendar = CalendarFeature.State()
    var history = HistoryFeature.State()
    var myPage = MyPageFeature.State()

    enum Tab: Equatable {
      case calendar, history, myPage
    }
  }

  enum Action: Equatable {
    case tabSelected(State.Tab)
    case calendar(CalendarFeature.Action)
    case history(HistoryFeature.Action)
    case myPage(MyPageFeature.Action)
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

      case .calendar, .history, .myPage:
        return .none
      }
    }
  }
}

struct MainTabView: View {
  @Bindable var store: StoreOf<MainTabFeature>

  var body: some View {
    TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
      CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
        .tag(MainTabFeature.State.Tab.calendar)
        .tabItem { Label("캘린더", systemImage: "calendar") }

      HistoryView(store: store.scope(state: \.history, action: \.history))
        .tag(MainTabFeature.State.Tab.history)
        .tabItem { Label("내역", systemImage: "list.bullet.rectangle") }

      MyPageView(store: store.scope(state: \.myPage, action: \.myPage))
        .tag(MainTabFeature.State.Tab.myPage)
        .tabItem { Label("마이페이지", systemImage: "person.circle") }
    }
  }
}

#Preview {
  MainTabView(
    store: Store(initialState: MainTabFeature.State()) {
      MainTabFeature()
    }
  )
}
