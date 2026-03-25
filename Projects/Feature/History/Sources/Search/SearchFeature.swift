//
//  SearchFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/18/26.
//

import ComposableArchitecture
import DoriCore

@Reducer
public struct SearchFeature {
  public init() {}

  private enum CancelID {
    case search
  }

  // MARK: - State

  @ObservableState
  public struct State: Equatable, Sendable {
    public var searchQuery: String = ""
    public var searchResults: [Dori] = []
    public var isSearching: Bool = false

    public init() {}
  }

  // MARK: - Action

  public enum Action: Equatable, Sendable {
    case searchQueryChanged(String)
    case searchResponse([Dori])
    case clearSearchTapped
    case backTapped
    case partnerTapped(Dori)
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case partnerTapped(Dori)
      case dismissed
    }
  }

  // MARK: - Dependencies

  @Dependency(\.continuousClock) var clock
  @Dependency(\.historyAPIClient) var apiClient

  // MARK: - Reducer

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .searchQueryChanged(query):
        state.searchQuery = String(query.prefix(10))

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
          state.searchResults = []
          state.isSearching = false
          return .cancel(id: CancelID.search)
        }

        state.isSearching = true
        let searchPartners = apiClient.searchPartners
        let clock = self.clock
        return .run { send in
          try await clock.sleep(for: .milliseconds(300))
          let results = try await searchPartners(query)
          await send(.searchResponse(results))
        }
        .cancellable(id: CancelID.search, cancelInFlight: true)

      case let .searchResponse(results):
        state.searchResults = results
        state.isSearching = false
        return .none

      case .clearSearchTapped:
        state.searchQuery = ""
        state.searchResults = []
        state.isSearching = false
        return .cancel(id: CancelID.search)

      case .backTapped:
        return .send(.delegate(.dismissed))
        
      case let .partnerTapped(partner):
        return .send(.delegate(.partnerTapped(partner)))

      case .delegate:
        return .none
      }
    }
  }
}
