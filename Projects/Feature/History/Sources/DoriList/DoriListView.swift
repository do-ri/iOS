//
//  DoriListView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem

import DoriCore

public struct DoriListView: View {
  @Bindable var store: StoreOf<DoriListFeature>

  public init(store: StoreOf<DoriListFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        ForEach(store.filteredPartners, id: \.partnerId) { partner in
          PersonCardView(partner: partner) {
            store.send(.partnerTapped(partner))
          }
        }
      }
      .padding()
    }
    .overlay {
      if store.filteredPartners.isEmpty && !store.isLoading {
        DoriEmptyView(.partnerList)
          .background(.grey100)
      }
    }
    .overlay(alignment: .bottomTrailing) {
      FloatingActionButton {
        store.send(.fabTapped)
      }
      .padding(20)
    }
    .background(.grey100)
    .doriNavigationBar(
      .titleWithActions(
        "내역",
        trailing: [
          .iconButton(
            image: Image(systemName: "magnifyingglass"),
            action: { store.send(.searchTapped) }
          )
        ]
      )
    )
    .refreshable {
      store.send(.refresh)
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}

// MARK: - Preview

#Preview {
  let previewPartners: [PartnerSummary] = [
    PartnerSummary(
      partnerId: 1,
      partnerName: "길태환",
      relationship: "친구",
      recentDoriList: [
        Dori(
          doriId: 1,
          userId: 1,
          partnerId: 1,
          direction: .judori,
          partnerName: "길태환",
          relationship: Relationship.friend.rawValue,
          eventType: EventType.birthday.rawValue,
          amount: 1,
          eventDate: "2025-05-01",
          isVisited: true,
          memo: "퇴근하고 바로 찾아가서 축하함",
          createdAt: "2026-02-17T09:00:00"
        ),
        Dori(
          doriId: 2,
          userId: 1,
          partnerId: 1,
          direction: .baddori,
          partnerName: "길태환",
          relationship: Relationship.friend.rawValue,
          eventType: EventType.wedding.rawValue,
          amount: 100_000,
          eventDate: "2025-03-15",
          isVisited: true,
          memo: "퇴근하고 바로 찾아가서 축하함",
          createdAt: "2026-02-17T09:00:00"
        ),
      ],
      inDoriTotalAmount: 100_000,
      outDoriTotalAmount: 1
    ),
    PartnerSummary(
      partnerId: 2,
      partnerName: "박수진",
      relationship: "직장짱친동료",
      recentDoriList: [
        Dori(
          doriId: 3,
          userId: 1,
          partnerId: 2,
          direction: .judori,
          partnerName: "김철수",
          relationship: Relationship.company.rawValue,
          eventType: EventType.wedding.rawValue,
          amount: 100_000,
          eventDate: "2025-08-20",
          isVisited: false,
          memo: "축의금",
          createdAt: "2026-02-17T09:00:00"
        )
      ],
      inDoriTotalAmount: 100_000,
      outDoriTotalAmount: 300_000
    ),
    PartnerSummary(
      partnerId: 3,
      partnerName: "박수진",
      relationship: "가족",
      recentDoriList: [
        Dori(
          doriId: 4,
          userId: 1,
          partnerId: 3,
          direction: .baddori,
          partnerName: "이영희",
          relationship: Relationship.family.rawValue,
          eventType: EventType.birthday.rawValue,
          amount: 300_000,
          eventDate: "2025-01-10",
          isVisited: true,
          memo: "생일 선물",
          createdAt: "2026-02-17T09:00:00"
        )
      ],
      inDoriTotalAmount: 300_000,
      outDoriTotalAmount: 100_000
    ),
    PartnerSummary(
      partnerId: 4,
      partnerName: "강성범",
      relationship: "지인",
      recentDoriList: [
        Dori(
          doriId: 5,
          userId: 1,
          partnerId: 4,
          direction: .baddori,
          partnerName: "박민준",
          relationship: Relationship.friend.rawValue,
          eventType: EventType.firstBirthday.rawValue,
          amount: 50_000,
          eventDate: "2025-11-05",
          isVisited: true,
          memo: "",
          createdAt: "2026-02-17T09:00:00"
        )
      ],
      inDoriTotalAmount: 100_000,
      outDoriTotalAmount: 0
    ),
    PartnerSummary(
      partnerId: 5,
      partnerName: "최수진",
      relationship: "친구",
      recentDoriList: [
        Dori(
          doriId: 6,
          userId: 1,
          partnerId: 5,
          direction: .judori,
          partnerName: "최수진",
          relationship: Relationship.friend.rawValue,
          eventType: EventType.birthday.rawValue,
          amount: 80_000,
          eventDate: "2025-07-22",
          isVisited: true,
          memo: "생일 케이크",
          createdAt: "2026-02-17T09:00:00"
        )
      ],
      inDoriTotalAmount: 300_000,
      outDoriTotalAmount: 100_000
    ),
  ]

  NavigationStack {
    DoriListView(
      store: Store(
        initialState: {
          var state = DoriListFeature.State()
          state.partners = previewPartners
          return state
        }()
      ) {
        DoriListFeature()
      } withDependencies: {
        $0.historyAPIClient = .previewValue
      }
    )
  }
}
