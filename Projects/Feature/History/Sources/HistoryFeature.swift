//
//  HistoryFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import ComposableArchitecture
import SwiftUI
import DoriDesignSystem
import DoriNetwork
import FeatureAddDori

// MARK: - HistoryFeature

@Reducer
public struct HistoryFeature {
  public init() {}

  // MARK: - Path Reducer

  @Reducer
  public enum Path {
    case partnerHistory(PartnerDoriHistoryFeature)
    case partnerDoriDetail(PartnerDoriDetailFeature)
    case addDori(AddDoriFeature)
    case editDori(EditDoriFeature)
  }

  // MARK: - State

  @ObservableState
  public struct State {
    public var doriList: DoriListFeature.State = .init()
    public var path = StackState<Path.State>()
    public init() {}
  }

  // MARK: - Action

  public enum Action {
    case doriList(DoriListFeature.Action)
    case path(StackActionOf<Path>)
  }

  // MARK: - Reducer

  public var body: some ReducerOf<Self> {
    Scope(state: \.doriList, action: \.doriList) {
      DoriListFeature()
    }

    Reduce { state, action in
      switch action {

      // MARK: DoriList delegate

      case .doriList(.delegate(.partnerTapped(let partner))):
        state.path.append(
          .partnerHistory(
            PartnerDoriHistoryFeature.State(
              partnerId: partner.partnerId,
              partnerName: partner.partnerName,
              relationship: partner.relationship
            )
          )
        )
        return .none

      case .doriList(.delegate(.fabTapped)):
        state.path.append(.addDori(AddDoriFeature.State()))
        return .none

      case .doriList:
        return .none

      // MARK: Path delegate 처리

      // PartnerDoriHistory에서 doriTapped → Detail push
      case .path(.element(id: _, action: .partnerHistory(.doriTapped(let dori)))):
        state.path.append(.partnerDoriDetail(PartnerDoriDetailFeature.State(dori: dori)))
        return .none

      // PartnerDoriHistory에서 전체 삭제
      case .path(.element(id: _, action: .partnerHistory(.delegate(.allDoriDeleted)))):
        state.path.removeAll()
        return .send(.doriList(.refresh))

      // PartnerDoriDetail에서 editTapped → Edit push
      case .path(.element(id: _, action: .partnerDoriDetail(.delegate(.editTapped(let dori))))):
        state.path.append(.editDori(EditDoriFeature.State(dori: dori)))
        return .none

      // PartnerDoriDetail에서 단건 삭제 → History로 복귀
      case .path(.element(id: _, action: .partnerDoriDetail(.delegate(.doriDeleted)))):
        state.path.removeLast()
        return .none

      // AddDori 완료 → 리스트로 복귀
      case .path(.element(id: _, action: .addDori(.delegate(.doriCreated(_))))):
        state.path.removeAll()
        return .send(.doriList(.refresh))

      // AddDori dismiss
      case .path(.element(id: _, action: .addDori(.delegate(.dismissed)))):
        state.path.removeAll()
        return .none

      // EditDori 완료 → 리스트로 복귀
      case .path(.element(id: _, action: .editDori(.delegate(.doriUpdated(_))))):
        state.path.removeAll()
        return .send(.doriList(.refresh))

      case .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
  }
}

// MARK: - HistoryView

public struct HistoryView: View {
  @Bindable var store: StoreOf<HistoryFeature>

  public init(store: StoreOf<HistoryFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(
      path: $store.scope(state: \.path, action: \.path)
    ) {
      DoriListView(
        store: store.scope(state: \.doriList, action: \.doriList)
      )
    } destination: { store in
      switch store.case {
      case .partnerHistory(let historyStore):
        PartnerDoriHistoryView(store: historyStore)
      case .partnerDoriDetail(let detailStore):
        PartnerDoriDetailView(store: detailStore)
      case .addDori(let addDoriStore):
        AddDoriView(store: addDoriStore)
      case .editDori(let editDoriStore):
        EditDoriView(store: editDoriStore)
      }
    }
  }
}

#Preview {
  HistoryView(
    store: Store(initialState: HistoryFeature.State()) {
      HistoryFeature()
    } withDependencies: {
      $0.historyAPIClient = .previewValue
    }
  )
}
