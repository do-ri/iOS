//
//  NotificationListFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/11/26.
//

import ComposableArchitecture
import DoriNetwork
import Foundation

@Reducer
public struct NotificationListFeature {
  public init() {}

  private static let pageSize = 20

  // MARK: - State

  @ObservableState
  public struct State: Equatable, Sendable {
    @Presents public var notificationSettings: NotificationSettingsFeature.State?

    public var items: [NotificationItemResponse] = []
    public var nextCursor: String?
    public var hasNext: Bool = true
    public var isLoading: Bool = false
    public var errorMessage: String?

    public init() {}
  }

  // MARK: - Action

  public enum Action: Equatable, Sendable {
    case onAppear
    case loadNextPageIfNeeded(NotificationItemResponse)
    case notificationsResponse(Result<NotificationPageResponse, APIError>)
    case settingsButtonTapped
    case notificationSettings(PresentationAction<NotificationSettingsFeature.Action>)
  }

  public struct APIError: Error, Equatable, Sendable {
    public let message: String
    public init(message: String) { self.message = message }
  }

  // MARK: - Dependencies

  @Dependency(\.notificationListAPIClient) var apiClient

  // MARK: - Reducer

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.items.isEmpty, !state.isLoading else { return .none }
        return fetch(state: &state)

      case let .loadNextPageIfNeeded(item):
        guard state.hasNext, !state.isLoading else { return .none }
        guard item.id == state.items.last?.id else { return .none }
        return fetch(state: &state)

      case let .notificationsResponse(.success(page)):
        state.isLoading = false
        state.errorMessage = nil
        state.items.append(contentsOf: page.items)
        state.nextCursor = page.nextCursor
        state.hasNext = page.hasNext
        return .none

      case let .notificationsResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.message
        return .none

      case .settingsButtonTapped:
        state.notificationSettings = NotificationSettingsFeature.State()
        return .none

      case .notificationSettings(.presented(.delegate(.didTapBack))):
        state.notificationSettings = nil
        return .none

      case .notificationSettings:
        return .none
      }
    }
    .ifLet(\.$notificationSettings, action: \.notificationSettings) {
      NotificationSettingsFeature()
    }
  }

  // MARK: - Private

  private func fetch(state: inout State) -> Effect<Action> {
    state.isLoading = true
    let cursor = state.nextCursor
    let size = Self.pageSize
    let fetch = apiClient.fetchNotifications
    return .run { send in
      do {
        let page = try await fetch(cursor, size)
        await send(.notificationsResponse(.success(page)))
      } catch {
        await send(.notificationsResponse(.failure(APIError(message: error.localizedDescription))))
      }
    }
  }
}
