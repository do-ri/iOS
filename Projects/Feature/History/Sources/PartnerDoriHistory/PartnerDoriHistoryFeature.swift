//
//  PartnerDoriHistoryFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import ComposableArchitecture
import DoriDesignSystem
import DoriNetwork
import DoriCore

public enum DoriFilter: String, CaseIterable, Equatable, Sendable {
  case all = "전체"
  case judori = "주도리"
  case baddori = "받도리"
}

@Reducer
public struct PartnerDoriHistoryFeature {
  public init() {}

  // MARK: - State

  @ObservableState
  public struct State: Equatable, Sendable {
    public var partnerId: Int64
    public var partnerName: String
    public var relationship: String
    public var inDoriTotalAmount: Int64 = 0
    public var outDoriTotalAmount: Int64 = 0
    public var inDoriList: [Dori] = []
    public var outDoriList: [Dori] = []
    public var isLoading: Bool = false
    public var filter: DoriFilter = .all
    public var showDeleteAlert: Bool = false
    public var showFilterSheet: Bool = false
    public var toast: DoriToast? = nil
    @Presents public var doriDetail: PartnerDoriDetailFeature.State?

    public var doriByDate: [(date: String, doris: [Dori])] {
      let filtered: [Dori]
      switch filter {
      case .all: filtered = inDoriList + outDoriList
      case .judori: filtered = outDoriList
      case .baddori: filtered = inDoriList
      }
      let sorted = filtered.sorted { $0.eventDate > $1.eventDate }
      let grouped = Dictionary(grouping: sorted) { $0.eventDate }
      return grouped.keys
        .sorted(by: >)
        .map { date in (date: date, doris: grouped[date] ?? []) }
    }

    public init(
      partnerId: Int64,
      partnerName: String,
      relationship: String
    ) {
      self.partnerId = partnerId
      self.partnerName = partnerName
      self.relationship = relationship
    }
  }

  // MARK: - Action

  public enum Action: Equatable, Sendable {
    case onAppear
    case fetchResponse(Result<PartnerDoriList, APIError>)
    case filterChanged(DoriFilter)
    case bulkDeleteTapped
    case setDeleteAlert(Bool)
    case confirmDeleteTapped
    case bulkDeleteResponse(Result<[Int64], APIError>)
    case doriTapped(Dori)
    case toastDismissed
    case setFilterSheet(Bool)
    case doriDetail(PresentationAction<PartnerDoriDetailFeature.Action>)
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case allDoriDeleted
      case editTapped(Dori)
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
        state.isLoading = true
        let partnerId = state.partnerId
        let fetch = apiClient.fetchPartnerDoriList
        return .run { send in
          do {
            let result = try await fetch(partnerId)
            await send(.fetchResponse(.success(result)))
          } catch {
            await send(.fetchResponse(.failure(APIError(message: error.localizedDescription))))
          }
        }

      case let .fetchResponse(.success(response)):
        state.isLoading = false
        state.inDoriTotalAmount = response.inDoriTotalAmount
        state.outDoriTotalAmount = response.outDoriTotalAmount
        state.inDoriList = response.inDoriList
        state.outDoriList = response.outDoriList
        return .none

      case .fetchResponse(.failure):
        state.isLoading = false
        return .none

      case let .filterChanged(filter):
        state.filter = filter
        state.showFilterSheet = false
        return .none

      case .bulkDeleteTapped:
        let allIds = (state.inDoriList + state.outDoriList).map { $0.doriId }
        guard !allIds.isEmpty else { return .none }
        state.showDeleteAlert = true
        return .none

      case let .setDeleteAlert(value):
        state.showDeleteAlert = value
        return .none

      case .confirmDeleteTapped:
        state.showDeleteAlert = false
        let allIds = (state.inDoriList + state.outDoriList).map { $0.doriId }
        let bulkDelete = apiClient.bulkDeleteDori
        return .run { send in
          do {
            let result = try await bulkDelete(allIds)
            await send(.bulkDeleteResponse(.success(result)))
          } catch {
            await send(.bulkDeleteResponse(.failure(APIError(message: error.localizedDescription))))
          }
        }

      case .bulkDeleteResponse(.success):
        state.inDoriList = []
        state.outDoriList = []
        state.inDoriTotalAmount = 0
        state.outDoriTotalAmount = 0
        state.toast = DoriToast(type: .success, message: "모든 내역이 삭제되었습니다.")
        return .send(.delegate(.allDoriDeleted))

      case .bulkDeleteResponse(.failure):
        return .none

      case let .doriTapped(dori):
        state.doriDetail = PartnerDoriDetailFeature.State(dori: dori)
        return .none

      case .toastDismissed:
        state.toast = nil
        return .none

      case let .setFilterSheet(value):
        state.showFilterSheet = value
        return .none

      // doriDetail 위임 처리
      case .doriDetail(.presented(.delegate(.editTapped(let dori)))):
        return .send(.delegate(.editTapped(dori)))

      case .doriDetail(.presented(.delegate(.doriDeleted))):
        let removedId = state.doriDetail?.doriId
        state.doriDetail = nil
        if let id = removedId {
          state.inDoriList.removeAll { $0.doriId == id }
          state.outDoriList.removeAll { $0.doriId == id }
        }
        return .none

      case .doriDetail:
        return .none

      case .delegate:
        return .none
      }
    }
    .ifLet(\.$doriDetail, action: \.doriDetail) {
      PartnerDoriDetailFeature()
    }
  }
}
