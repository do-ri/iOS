//
//  DoriListFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import ComposableArchitecture
import DoriCore

@Reducer
public struct DoriListFeature {
  public init() {}

  private static let pageSize = 20

  // MARK: - State

  @ObservableState
  public struct State: Equatable, Sendable {
    public var partners: [PartnerSummary] = []
    public var searchText: String = ""
    public var isLoading: Bool = false
    public var currentPage: Int = 0
    public var hasMorePages: Bool = true

    public var filteredPartners: [PartnerSummary] {
      if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
        return partners
      }
      return partners.filter {
        $0.partnerName.localizedCaseInsensitiveContains(searchText) ||
        $0.relationship.localizedCaseInsensitiveContains(searchText)
      }
    }

    public init() {}
  }

  // MARK: - Action

  public enum Action: Equatable, Sendable {
    case onAppear
    case fetchPartnersResponse(Result<[PartnerSummary], APIError>)
    case searchTextChanged(String)
    case refresh
    case fabTapped
    case partnerTapped(PartnerSummary)
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case partnerTapped(PartnerSummary)
      case fabTapped
    }
  }

  public struct APIError: Error, Equatable, Sendable {
    public let message: String
    public init(message: String) { self.message = message }
  }

  // MARK: - Dependencies

  @Dependency(\.historyAPIClient) var apiClient

  // MARK: - Reducer

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.partners.isEmpty else { return .none }
        return fetchPartners(state: &state)

      case let .fetchPartnersResponse(.success(partners)):
        state.isLoading = false
        if state.currentPage == 0 {
          state.partners = partners
        } else {
          state.partners.append(contentsOf: partners)
        }
        state.hasMorePages = partners.count >= Self.pageSize
        return .none

      case .fetchPartnersResponse(.failure):
        state.isLoading = false
        return .none

      case let .searchTextChanged(query):
        state.searchText = query
        return .none

      case .refresh:
        state.currentPage = 0
        state.hasMorePages = true
        return fetchPartners(state: &state)

      case let .partnerTapped(partner):
        return .send(.delegate(.partnerTapped(partner)))

      case .fabTapped:
        return .send(.delegate(.fabTapped))

      case .delegate:
        return .none
      }
    }
  }

  // MARK: - Private

  private func fetchPartners(state: inout State) -> Effect<Action> {
    state.isLoading = true
    let page = state.currentPage
    let size = Self.pageSize
    let fetch = apiClient.fetchPartners
    return .run { send in
      do {
        let result = try await fetch(page, size)
        await send(.fetchPartnersResponse(.success(result)))
      } catch {
        await send(.fetchPartnersResponse(.failure(APIError(message: error.localizedDescription))))
      }
    }
  }
}
