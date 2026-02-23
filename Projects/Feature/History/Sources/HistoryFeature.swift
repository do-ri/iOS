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

  // MARK: - State

  @ObservableState
  public struct State {
    public var doriList: DoriListFeature.State = .init()
    @Presents public var partnerHistory: PartnerDoriHistoryFeature.State?
    @Presents public var addDori: AddDoriFeature.State?
    @Presents public var editDori: EditDoriFeature.State?
    public init() {}
  }

  // MARK: - Action

  public enum Action {
    case doriList(DoriListFeature.Action)
    case partnerHistory(PresentationAction<PartnerDoriHistoryFeature.Action>)
    case addDori(PresentationAction<AddDoriFeature.Action>)
    case editDori(PresentationAction<EditDoriFeature.Action>)
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
        state.partnerHistory = PartnerDoriHistoryFeature.State(
          partnerId: partner.partnerId,
          partnerName: partner.partnerName,
          relationship: partner.relationship
        )
        return .none

      case .doriList(.delegate(.fabTapped)):
        state.addDori = AddDoriFeature.State()
        return .none

      case .doriList:
        return .none

      // MARK: PartnerDoriHistory delegate

      case .partnerHistory(.presented(.delegate(.allDoriDeleted))):
        state.partnerHistory = nil
        return .send(.doriList(.refresh))

      case .partnerHistory(.presented(.delegate(.editTapped(let dori)))):
        state.editDori = EditDoriFeature.State(dori: dori)
        return .none

      case .partnerHistory:
        return .none

      // MARK: AddDori

      case .addDori(.presented(.delegate(.doriCreated(_)))):
        state.addDori = nil
        return .send(.doriList(.refresh))

      case .addDori(.presented(.delegate(.dismissed))):
        state.addDori = nil
        return .none

      case .addDori:
        return .none

      // MARK: EditDori

      case .editDori(.presented(.delegate(.doriUpdated(_)))):
        state.editDori = nil
        state.partnerHistory = nil
        return .send(.doriList(.refresh))

      case .editDori:
        return .none
      }
    }
    .ifLet(\.$partnerHistory, action: \.partnerHistory) {
      PartnerDoriHistoryFeature()
    }
    .ifLet(\.$addDori, action: \.addDori) {
      AddDoriFeature()
    }
    .ifLet(\.$editDori, action: \.editDori) {
      EditDoriFeature()
    }
  }
}

// MARK: - HistoryView

public struct HistoryView: View {
  @Bindable var store: StoreOf<HistoryFeature>

  public init(store: StoreOf<HistoryFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      DoriListView(
        store: store.scope(state: \.doriList, action: \.doriList)
      )
      .navigationDestination(
        item: $store.scope(state: \.partnerHistory, action: \.partnerHistory)
      ) { historyStore in
        PartnerDoriHistoryView(store: historyStore)
      }
      .navigationDestination(
        item: $store.scope(state: \.addDori, action: \.addDori)
      ) { addDoriStore in
        AddDoriView(store: addDoriStore)
      }
      .navigationDestination(
        item: $store.scope(state: \.editDori, action: \.editDori)
      ) { editDoriStore in
        NavigationStack {
          EditDoriView(store: editDoriStore)
        }
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
