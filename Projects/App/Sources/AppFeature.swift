//
//  AppFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import SwiftUI
import ComposableArchitecture
import FeatureOnboarding

@Reducer
struct AppFeature {
  @ObservableState
  struct State {
    enum Route: Equatable {
      case splash
      case intro
      case mainTab
    }

    var route: Route = .splash
    var splash = SplashFeature.State()
    var intro = IntroFeature.State()
    var mainTab = MainTabFeature.State()
  }

  enum Action {
    case splash(SplashFeature.Action)
    case intro(IntroFeature.Action)
    case mainTab(MainTabFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.splash, action: \.splash) {
      SplashFeature()
    }
    Scope(state: \.intro, action: \.intro) {
      IntroFeature()
    }
    Scope(state: \.mainTab, action: \.mainTab) {
      MainTabFeature()
    }
    Reduce { state, action in
      switch action {
      case .splash(.delegate(.authenticated)):
        state.route = .mainTab
        return .none

      case .splash(.delegate(.unauthenticated)):
        state.route = .intro
        return .none
      
      case .intro(.delegate(.loginSucceeded)):
        state.route = .mainTab
        return .none
        
      case .mainTab(.delegate(.needsAuthentication)):
        state.route = .intro
        return .none

      case .splash, .intro, .mainTab:
        return .none
      }
    }
  }
}

struct AppView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    switch store.route {
    case .splash:
      SplashView(store: store.scope(state: \.splash, action: \.splash))
    case .intro:
      IntroView(store: store.scope(state: \.intro, action: \.intro))
    case .mainTab:
      MainTabView(store: store.scope(state: \.mainTab, action: \.mainTab))
    }
  }
}
