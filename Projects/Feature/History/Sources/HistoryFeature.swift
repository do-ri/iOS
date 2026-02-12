//
//  HistoryFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct HistoryFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable, Sendable {
    public init() {}
  }

  public enum Action: Equatable, Sendable {
    case onAppear
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .onAppear:
      return .none
    }
  }
}

public struct HistoryView: View {
  let store: StoreOf<HistoryFeature>

  public init(store: StoreOf<HistoryFeature>) {
    self.store = store
  }

  public var body: some View {
    Text("내역")
      .onAppear { store.send(.onAppear) }
  }
}
