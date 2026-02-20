//
//  HistoryFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import ComposableArchitecture
import SwiftUI
import DoriDesignSystem
import FeatureAddDori

@Reducer
public struct HistoryFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable, Sendable {
    @Presents public var addDori: AddDoriFeature.State?

    public init() {}
  }

  public enum Action: Equatable, Sendable {
    case onAppear
    case fabTapped
    case addDori(PresentationAction<AddDoriFeature.Action>)
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .fabTapped:
        state.addDori = AddDoriFeature.State(mode: .create)
        return .none

      case .addDori(.presented(.delegate(.doriCreated))):
        state.addDori = nil
        return .none

      case .addDori(.presented(.delegate(.dismissed))):
        state.addDori = nil
        return .none

      case .addDori:
        return .none
      }
    }
    .ifLet(\.$addDori, action: \.addDori) {
      AddDoriFeature()
    }
  }
}

public struct HistoryView: View {
  @Bindable var store: StoreOf<HistoryFeature>

  public init(store: StoreOf<HistoryFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      ZStack(alignment: .bottomTrailing) {
        Text("내역")
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
          )

        FloatingActionButton {
          store.send(.fabTapped)
        }
        .padding(20)
      }
      .onAppear { store.send(.onAppear) }
      .navigationDestination(
        item: $store.scope(
          state: \.addDori,
          action: \.addDori
        )
      ) { addDoriStore in
        AddDoriView(store: addDoriStore)
      }
    }
  }
}
