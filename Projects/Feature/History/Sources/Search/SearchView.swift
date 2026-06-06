//
//  SearchView.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/18/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem
import DoriCore
import FeatureAddDori

public struct SearchView: View {
  @Bindable var store: StoreOf<SearchFeature>
  @State private var localNameText: String = ""

  public init(store: StoreOf<SearchFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 0) {
      contentView
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.bgPrimary)
    .onChange(of: localNameText) { _, newValue in
      let truncated = String(newValue.prefix(10))
      if localNameText != truncated {
        localNameText = truncated
      }
      store.send(.searchQueryChanged(truncated))
    }
    .onChange(of: store.searchQuery) { _, newValue in
      if localNameText != newValue {
        localNameText = newValue
      }
    }
    .doriNavigationBar(
      DoriNavigationBarConfig(
        leading: .backButton(action: { store.send(.backTapped) }),
        center: .searchField(
          text: $localNameText,
          placeholder: "이름을 입력하세요",
          onClear: { store.send(.clearSearchTapped) }
        ),
        trailing: []
      )
    )
  }

  @ViewBuilder
  private var contentView: some View {
    if store.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
      Spacer()
    } else if store.searchResults.isEmpty && !store.isSearching {
      DoriEmptyView(.doriHistory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      ScrollView {
        LazyVStack(spacing: 34) {
          ForEach(
            Array(store.searchResults.enumerated()),
            id: \.offset
          ) { _, partner in
            PartnerSearchResultRow(
              searchQuery: $store.searchQuery.sending(\.searchQueryChanged),
              partner: partner
            )
            .contentShape(Rectangle())
            .onTapGesture {
              store.send(.partnerTapped(partner))
            }
            .padding(.horizontal, 16)
          }
        }
        .padding(.vertical, 8)
      }
    }
  }
}

// MARK: - Preview

#Preview("검색 결과 있음") {
  let state: SearchFeature.State = {
    var s = SearchFeature.State()
    s.searchQuery = "조"
    s.searchResults = [
      Dori(
        doriId: 100,
        userId: 1,
        partnerId: 100,
        direction: .judori,
        partnerName: "조카 1",
        relationship: "가족",
        eventType: "생일",
        amount: 50_000,
        eventDate: "2025-05-01",
        isVisited: true,
        memo: "",
        createdAt: "2026-02-17T09:00:00"
      ),
      Dori(
        doriId: 101,
        userId: 1,
        partnerId: 101,
        direction: .baddori,
        partnerName: "조카1",
        relationship: "친구",
        eventType: "결혼식",
        amount: 100_000,
        eventDate: "2025-08-20",
        isVisited: true,
        memo: "",
        createdAt: "2026-02-17T09:00:00"
      )
    ]
    return s
  }()

  NavigationStack {
    SearchView(
      store: Store(initialState: state) {
        SearchFeature()
      } withDependencies: {
        $0.historyAPIClient = .previewValue
      }
    )
  }
}

#Preview("검색 결과 없음") {
  let state: SearchFeature.State = {
    var s = SearchFeature.State()
    s.searchQuery = "조가"
    s.searchResults = []
    return s
  }()

  NavigationStack {
    SearchView(
      store: Store(initialState: state) {
        SearchFeature()
      } withDependencies: {
        $0.historyAPIClient = .previewValue
      }
    )
  }
}
