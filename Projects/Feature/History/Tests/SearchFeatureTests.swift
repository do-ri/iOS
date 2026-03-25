//
//  SearchFeatureTests.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/18/26.
//

import Testing
import ComposableArchitecture
import DoriCore
@testable import FeatureHistory

@MainActor
struct SearchFeatureTests {

  // MARK: - 검색 결과 검증용 mock 파트너 데이터

  private static let mockPartners: [Dori] = [
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

  // MARK: - "조" 검색 → 조카 1(가족), 조카1(친구) 2개 반환

  @Test
  func testSearchJo_returnsTwoResults() async throws {
    let results = Self.mockPartners.filter { $0.partnerName.contains("조") }

    #expect(results.count == 2)
    #expect(results[0].partnerName == "조카 1")
    #expect(results[0].relationship == "가족")
    #expect(results[1].partnerName == "조카1")
    #expect(results[1].relationship == "친구")

    // SearchFeature가 searchResponse로 결과를 state에 저장하는지 검증
    let store = TestStore(initialState: SearchFeature.State()) {
      SearchFeature()
    }
    store.exhaustivity = .off

    await store.send(.searchResponse(results)) {
      $0.searchResults = results
      $0.isSearching = false
    }

    #expect(store.state.searchResults.count == 2)
    #expect(store.state.searchResults[0].partnerName == "조카 1")
    #expect(store.state.searchResults[0].relationship == "가족")
    #expect(store.state.searchResults[1].partnerName == "조카1")
    #expect(store.state.searchResults[1].relationship == "친구")
  }

  // MARK: - "조가" 검색 → 결과 없음 (DoriEmptyView(.doriHistory) 표시 조건)

  @Test
  func testSearchJoGa_returnsEmptyResults() async throws {
    let results = Self.mockPartners.filter { $0.partnerName.contains("조가") }

    #expect(results.isEmpty)

    // SearchFeature가 빈 searchResponse를 받으면 searchResults가 비어있는지 검증
    let store = TestStore(initialState: SearchFeature.State()) {
      SearchFeature()
    }
    store.exhaustivity = .off

    await store.send(.searchResponse([])) {
      $0.searchResults = []
      $0.isSearching = false
    }

    #expect(store.state.searchResults.isEmpty)
  }
}
