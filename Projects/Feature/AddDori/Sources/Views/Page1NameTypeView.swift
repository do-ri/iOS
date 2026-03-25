//
//  Page1NameTypeView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem
import DoriCore
import DoriNetwork

struct Page1NameTypeView: View {
  @Bindable var store: StoreOf<AddDoriFeature>
  @State private var localNameText: String = ""

  private let options2x2: [DoriSegmentOption<TransactionType>] = [
    .init(id: .judori, title: TransactionType.judori.displayName, role: .normal),
    .init(id: .baddori, title: TransactionType.baddori.displayName, role: .normal),
  ]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      // 내역 구분
      VStack(alignment: .leading, spacing: 10) {
        Text("내역 구분")
          .addDoriSectionTitleStyle()

        DoriSegmentGridWithMemo(
          options: options2x2,
          selection: $store.transactionType.sending(\.transactionTypeChanged)
        )
      }

      // 이름
      VStack(alignment: .leading, spacing: 10) {
        Text("이름")
          .addDoriSectionTitleStyle()

        HStack {
          TextField(
            "상대방 이름을 입력하세요. (10자)",
            text: $localNameText
          )
          .pretendard(.body(.sb3))
          .foregroundStyle(.doriBlack)
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

          if !localNameText.isEmpty {
            Button {
              store.send(.clearSearchTapped)
            } label: {
              Image(systemName: "xmark.circle.fill")
                .foregroundStyle(DoriColors.grey400.color)
            }
          }
        }
        .roundedStyle()

        // 검색 결과
        if !store.searchResults.isEmpty {
          searchResultsList
        }
      }
    }
    .padding(.horizontal, 16)
  }

  private var searchResultsList: some View {
    ScrollView {
      LazyVStack(spacing: 34) {
        ForEach(
          Array(store.searchResults.enumerated()),
          id: \.offset
        ) { _, partner in
          PartnerSearchResultRow(searchQuery: $store.searchQuery.sending(\.searchQueryChanged), partner: partner
          )
          .contentShape(Rectangle())
          .onTapGesture {
            store.send(.partnerSelected(partner))
          }
        }
      }
    }
    .frame(maxHeight: 286)
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
    .roundedStyle()
  }
}

#Preview("검색 결과 있음") {
  let state: AddDoriFeature.State = {
    var s = AddDoriFeature.State()
    s.searchQuery = ""
    s.searchResults = [
      Dori(
        doriId: 1,
        userId: 1,
        partnerId: 1,
        direction: .judori,
        partnerName: "박수진수진수진수진수",
        relationship: "친구야친구야",
        eventType: "결혼식",
        amount: 100_000,
        eventDate: "2024-05-12",
        isVisited: true,
        memo: "",
        createdAt: "2026-05-12"
      ),
      Dori(
        doriId: 1,
        userId: 1,
        partnerId: 1,
        direction: .judori,
        partnerName: "박수진",
        relationship: "친구",
        eventType: "결혼식",
        amount: 100_000,
        eventDate: "2024-05-12",
        isVisited: true,
        memo: "",
        createdAt: "2026-05-12"
      ),
      Dori(
        doriId: 2,
        userId: 1,
        partnerId: 2,
        direction: .baddori,
        partnerName: "박지민",
        relationship: "직장동료",
        eventType: "돌잔치",
        amount: 50_000,
        eventDate: "2025-01-15",
        isVisited: false,
        memo: "",
        createdAt: "2026-01-15"
      ),
      Dori(
        doriId: 3,
        userId: 1,
        partnerId: 3,
        direction: .judori,
        partnerName: "박민준",
        relationship: "가족",
        eventType: "장례식",
        amount: 200_000,
        eventDate: "2024-08-20",
        isVisited: true,
        memo: "많이 힘드셨을텐데",
        createdAt: "2026-08-20"
      ),
    ]
    return s
  }()

  NavigationStack {
    Page1NameTypeView(
      store: Store(initialState: state) {
        AddDoriFeature()
      }
    )
  }
}

#Preview("빈 상태") {
  NavigationStack {
    Page1NameTypeView(
      store: Store(initialState: AddDoriFeature.State()) {
        AddDoriFeature()
      }
    )
  }
}
