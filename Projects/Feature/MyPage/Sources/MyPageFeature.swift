//
//  MyPageFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct MyPageFeature {
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

public struct MyPageView: View {
  let store: StoreOf<MyPageFeature>

  public init(store: StoreOf<MyPageFeature>) {
    self.store = store
  }

  public var body: some View {
    Text("마이페이지")
      .onAppear { store.send(.onAppear) }
  }
}
