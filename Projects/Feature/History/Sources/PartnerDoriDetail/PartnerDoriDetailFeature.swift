//
//  PartnerDoriDetailFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import ComposableArchitecture
import DoriDesignSystem
import DoriNetwork
import DoriCore

@Reducer
public struct PartnerDoriDetailFeature {
  public init() {}

  // MARK: - State

  @ObservableState
  public struct State: Equatable, Sendable {
    public var doriId: Int64
    public var doriDetail: Dori?
    public var isLoading: Bool = false
    public var showDeleteAlert: Bool = false
    public var toast: DoriToast? = nil

    public init(dori: Dori) {
      self.doriId = dori.doriId
      self.doriDetail = dori
    }
  }

  // MARK: - Action

  public enum Action: Equatable, Sendable {
    case onAppear
    case fetchDetailResponse(Result<Dori, APIError>)
    case editTapped
    case deleteTapped
    case setDeleteAlert(Bool)
    case confirmDeleteTapped
    case deleteResponse(Result<Bool, APIError>)
    case toastDismissed
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case editTapped(Dori)
      case doriDeleted
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
        return .none

      case let .fetchDetailResponse(.success(dori)):
        state.isLoading = false
        state.doriDetail = dori
        return .none

      case .fetchDetailResponse(.failure):
        state.isLoading = false
        return .none

      case .editTapped:
        guard let dori = state.doriDetail else { return .none }
        return .send(.delegate(.editTapped(dori)))

      case .deleteTapped:
        state.showDeleteAlert = true
        return .none

      case let .setDeleteAlert(value):
        state.showDeleteAlert = value
        return .none

      case .confirmDeleteTapped:
        state.showDeleteAlert = false
        let doriId = state.doriId
        let delete = apiClient.deleteDori
        return .run { send in
          do {
            try await delete(doriId)
            await send(.deleteResponse(.success(true)))
          } catch {
            await send(.deleteResponse(.failure(APIError(message: error.localizedDescription))))
          }
        }

      case .deleteResponse(.success):
        state.toast = DoriToast(type: .success, message: "해당 내역이 삭제되었습니다.")
        return .send(.delegate(.doriDeleted))

      case .deleteResponse(.failure):
        return .none

      case .toastDismissed:
        state.toast = nil
        return .none

      case .delegate:
        return .none
      }
    }
  }
}
