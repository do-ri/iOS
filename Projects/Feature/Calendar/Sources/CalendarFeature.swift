//
//  CalendarFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct CalendarFeature {
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

public struct CalendarView: View {
  let store: StoreOf<CalendarFeature>

  public init(store: StoreOf<CalendarFeature>) {
    self.store = store
  }

  public var body: some View {
    Text("캘린더")
      .onAppear { store.send(.onAppear) }
  }
}
