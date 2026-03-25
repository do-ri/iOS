//
//  HistoryAPIClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import Foundation
import ComposableArchitecture
import DoriCore
import DoriNetwork

public struct HistoryAPIClient: Sendable {
  public var fetchPartners: @Sendable (_ page: Int, _ size: Int) async throws -> [PartnerSummary]
  public var searchPartners: @Sendable (_ query: String) async throws -> [Dori]
  public var fetchPartnerDoriList: @Sendable (_ partnerId: Int64) async throws -> PartnerDoriList
  public var fetchDoriDetail: @Sendable (_ doriId: Int64) async throws -> Dori
  public var updateDori: @Sendable (_ doriId: Int64, _ input: DoriUpdateInput) async throws -> Dori
  public var deleteDori: @Sendable (_ doriId: Int64) async throws -> Void
  public var bulkDeleteDori: @Sendable (_ doriIds: [Int64]) async throws -> [Int64]

  public init(
    fetchPartners: @escaping @Sendable (_ page: Int, _ size: Int) async throws -> [PartnerSummary],
    searchPartners: @escaping @Sendable (_ query: String) async throws -> [Dori],
    fetchPartnerDoriList: @escaping @Sendable (_ partnerId: Int64) async throws -> PartnerDoriList,
    fetchDoriDetail: @escaping @Sendable (_ doriId: Int64) async throws -> Dori,
    updateDori: @escaping @Sendable (_ doriId: Int64, _ input: DoriUpdateInput) async throws -> Dori,
    deleteDori: @escaping @Sendable (_ doriId: Int64) async throws -> Void,
    bulkDeleteDori: @escaping @Sendable (_ doriIds: [Int64]) async throws -> [Int64]
  ) {
    self.fetchPartners = fetchPartners
    self.searchPartners = searchPartners
    self.fetchPartnerDoriList = fetchPartnerDoriList
    self.fetchDoriDetail = fetchDoriDetail
    self.updateDori = updateDori
    self.deleteDori = deleteDori
    self.bulkDeleteDori = bulkDeleteDori
  }
}

// MARK: - Error

private enum HistoryAPIClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "HistoryAPIClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    }
  }
}

// MARK: - DependencyKey

extension HistoryAPIClient: DependencyKey {
  public static let liveValue = Self(
    fetchPartners: { _, _ in throw HistoryAPIClientError.unconfigured },
    searchPartners: { _ in throw HistoryAPIClientError.unconfigured },
    fetchPartnerDoriList: { _ in throw HistoryAPIClientError.unconfigured },
    fetchDoriDetail: { _ in throw HistoryAPIClientError.unconfigured },
    updateDori: { _, _ in throw HistoryAPIClientError.unconfigured },
    deleteDori: { _ in throw HistoryAPIClientError.unconfigured },
    bulkDeleteDori: { _ in throw HistoryAPIClientError.unconfigured }
  )

  public static let previewValue = Self(
    fetchPartners: { _, _ in
      [
        PartnerSummary(
          partnerId: 1,
          partnerName: "홍길동",
          relationship: "친구",
          recentDoriList: [
            Dori(
              doriId: 1,
              userId: 1,
              partnerId: 1,
              direction: .judori,
              partnerName: "홍길동",
              relationship: "친구",
              eventType: "생일",
              amount: 50_000,
              eventDate: "2025-05-01",
              isVisited: true,
              memo: "생일 축하",
              createdAt: "2026-02-17T09:00:00"
            ),
            Dori(
              doriId: 2,
              userId: 1,
              partnerId: 1,
              direction: .baddori,
              partnerName: "홍길동",
              relationship: "친구",
              eventType: "결혼",
              amount: 100_000,
              eventDate: "2025-03-15",
              isVisited: true,
              memo: "",
              createdAt: "2026-02-17T09:00:00"
            )
          ],
          inDoriTotalAmount: 100_000,
          outDoriTotalAmount: 50_000
        ),
        PartnerSummary(
          partnerId: 2,
          partnerName: "김철수",
          relationship: "직장동료",
          recentDoriList: [
            Dori(
              doriId: 3,
              userId: 1,
              partnerId: 2,
              direction: .judori,
              partnerName: "김철수",
              relationship: "직장동료",
              eventType: "결혼",
              amount: 100_000,
              eventDate: "2025-08-20",
              isVisited: false,
              memo: "축의금",
              createdAt: "2026-02-17T09:00:00"
            )
          ],
          inDoriTotalAmount: 0,
          outDoriTotalAmount: 200_000
        ),
        PartnerSummary(
          partnerId: 3,
          partnerName: "이영희",
          relationship: "가족",
          recentDoriList: [
            Dori(
              doriId: 4,
              userId: 1,
              partnerId: 3,
              direction: .baddori,
              partnerName: "이영희",
              relationship: "가족",
              eventType: "생일",
              amount: 300_000,
              eventDate: "2025-01-10",
              isVisited: true,
              memo: "생일 선물",
              createdAt: "2026-02-17T09:00:00"
            )
          ],
          inDoriTotalAmount: 300_000,
          outDoriTotalAmount: 150_000
        ),
        PartnerSummary(
          partnerId: 4,
          partnerName: "박민준",
          relationship: "지인",
          recentDoriList: [
            Dori(
              doriId: 5,
              userId: 1,
              partnerId: 4,
              direction: .baddori,
              partnerName: "박민준",
              relationship: "지인",
              eventType: "돌잔치",
              amount: 50_000,
              eventDate: "2025-11-05",
              isVisited: true,
              memo: "",
              createdAt: "2026-02-17T09:00:00"
            )
          ],
          inDoriTotalAmount: 50_000,
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
              relationship: "친구",
              eventType: "생일",
              amount: 80_000,
              eventDate: "2025-07-22",
              isVisited: true,
              memo: "생일 케이크",
              createdAt: "2026-02-17T09:00:00"
            )
          ],
          inDoriTotalAmount: 80_000,
          outDoriTotalAmount: 80_000
        )
      ]
    },
    searchPartners: { query in
      let allPartners: [Dori] = [
        Dori(
          doriId: 1,
          userId: 1,
          partnerId: 1,
          direction: .judori,
          partnerName: "홍길동",
          relationship: "친구",
          eventType: "생일",
          amount: 50_000,
          eventDate: "2024-05-01",
          isVisited: true,
          memo: "",
          createdAt: "2026-02-17T09:00:00"
        ),
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
      return allPartners.filter { $0.partnerName.contains(query) }
    },
    fetchPartnerDoriList: { partnerId in
      PartnerDoriList(
        userId: 1,
        partnerId: partnerId,
        partnerName: "홍길동",
        relationship: "친구",
        inDoriTotalAmount: 550_000,
        inDoriList: [
          Dori(
            doriId: 1,
            userId: 1,
            partnerId: partnerId,
            direction: .baddori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "결혼식",
            amount: 200_000,
            eventDate: "2025-08-15",
            isVisited: true,
            memo: "축하해요",
            createdAt: "2026-02-17T09:00:00"
          ),
          Dori(
            doriId: 2,
            userId: 1,
            partnerId: partnerId,
            direction: .baddori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "생일",
            amount: 100_000,
            eventDate: "2025-05-01",
            isVisited: true,
            memo: "생일 축하",
            createdAt: "2026-02-17T09:00:00"
          ),
          Dori(
            doriId: 3,
            userId: 1,
            partnerId: partnerId,
            direction: .baddori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "돌잔치",
            amount: 150_000,
            eventDate: "2025-03-10",
            isVisited: false,
            memo: "",
            createdAt: "2026-02-17T09:00:00"
          ),
          Dori(
            doriId: 4,
            userId: 1,
            partnerId: partnerId,
            direction: .baddori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "집들이",
            amount: 50_000,
            eventDate: "2025-01-20",
            isVisited: true,
            memo: "새집 축하",
            createdAt: "2026-02-17T09:00:00"
          ),
          Dori(
            doriId: 5,
            userId: 1,
            partnerId: partnerId,
            direction: .baddori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "장례식",
            amount: 50_000,
            eventDate: "2024-11-05",
            isVisited: true,
            memo: "",
            createdAt: "2026-02-17T09:00:00"
          )
        ],
        outDoriTotalAmount: 480_000,
        outDoriList: [
          Dori(
            doriId: 6,
            userId: 1,
            partnerId: partnerId,
            direction: .judori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "결혼식",
            amount: 150_000,
            eventDate: "2025-06-20",
            isVisited: true,
            memo: "축의금",
            createdAt: "2026-02-17T09:00:00"
          ),
          Dori(
            doriId: 7,
            userId: 1,
            partnerId: partnerId,
            direction: .judori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "생일",
            amount: 80_000,
            eventDate: "2025-05-01",
            isVisited: true,
            memo: "생일 케이크",
            createdAt: "2026-02-17T09:00:00"
          ),
          Dori(
            doriId: 8,
            userId: 1,
            partnerId: partnerId,
            direction: .judori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "장례식",
            amount: 100_000,
            eventDate: "2025-04-15",
            isVisited: false,
            memo: "조의금",
            createdAt: "2026-02-17T09:00:00"
          ),
          Dori(
            doriId: 9,
            userId: 1,
            partnerId: partnerId,
            direction: .judori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "기타",
            amount: 50_000,
            eventDate: "2025-02-14",
            isVisited: true,
            memo: "발렌타인",
            createdAt: "2026-02-17T09:00:00"
          ),
          Dori(
            doriId: 10,
            userId: 1,
            partnerId: partnerId,
            direction: .judori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "집들이",
            amount: 100_000,
            eventDate: "2024-12-25",
            isVisited: true,
            memo: "",
            createdAt: "2026-02-17T09:00:00"
          )
        ]
      )
    },
    fetchDoriDetail: { doriId in
      let previews: [Int64: Dori] = [
        1: Dori(
          doriId: 1,
          userId: 1,
          partnerId: 1,
          direction: .baddori,
          partnerName: "홍길동",
          relationship: "친구",
          eventType: "결혼식",
          amount: 200_000,
          eventDate: "2025-08-15",
          isVisited: true,
          memo: "축하해요",
          createdAt: "2026-02-17T09:00:00"
        ),
        6: Dori(
          doriId: 6,
          userId: 1,
          partnerId: 1,
          direction: .judori,
          partnerName: "홍길동",
          relationship: "친구",
          eventType: "결혼식",
          amount: 150_000,
          eventDate: "2025-06-20",
          isVisited: true,
          memo: "축의금",
          createdAt: "2026-02-17T09:00:00"
        )
      ]
      return previews[doriId] ?? Dori(
        doriId: doriId,
        userId: 1,
        partnerId: 1,
        direction: .baddori,
        partnerName: "홍길동",
        relationship: "친구",
        eventType: "생일",
        amount: 50_000,
        eventDate: "2024-05-01",
        isVisited: true,
        memo: "메모",
        createdAt: "2026-02-17T09:00:00"
      )
    },
    updateDori: { doriId, input in
      Dori(
        doriId: doriId,
        userId: 1,
        partnerId: 1,
        direction: input.direction ?? .judori,
        partnerName: "홍길동",
        relationship: "친구",
        eventType: input.eventType ?? "결혼식",
        amount: input.amount ?? 50_000,
        eventDate: input.eventDate ?? "2026-02-15",
        isVisited: input.isVisited ?? true,
        memo: input.memo ?? "",
        createdAt: "2026-02-15"
      )
    },
    deleteDori: { _ in },
    bulkDeleteDori: { doriIds in doriIds }
  )

  public static let testValue = Self(
    fetchPartners: { _, _ in [] },
    searchPartners: { _ in [] },
    fetchPartnerDoriList: { partnerId in
      PartnerDoriList(
        userId: 1,
        partnerId: partnerId,
        partnerName: "테스트",
        relationship: "친구",
        inDoriTotalAmount: 0,
        inDoriList: [],
        outDoriTotalAmount: 0,
        outDoriList: []
      )
    },
    fetchDoriDetail: { doriId in
      Dori(
        doriId: doriId,
        userId: 1,
        partnerId: 1,
        direction: .baddori,
        partnerName: "테스트",
        relationship: "친구",
        eventType: "생일",
        amount: 0,
        eventDate: "2024-01-01",
        isVisited: true,
        memo: "",
        createdAt: "2024-01-01"
      )
    },
    updateDori: { _, _ in
      Dori(
        doriId: 1,
        userId: 1,
        partnerId: 1,
        direction: .judori,
        partnerName: "테스트",
        relationship: "친구",
        eventType: "결혼식",
        amount: 50_000,
        eventDate: "2026-02-15",
        isVisited: true,
        memo: "",
        createdAt: "2026-02-15"
      )
    },
    deleteDori: { _ in },
    bulkDeleteDori: { _ in [] }
  )
}

// MARK: - DependencyValues

public extension DependencyValues {
  var historyAPIClient: HistoryAPIClient {
    get { self[HistoryAPIClient.self] }
    set { self[HistoryAPIClient.self] = newValue }
  }
}

// MARK: - Live Factory

public extension HistoryAPIClient {
  static func live(networkService: any NetworkService) -> Self {
    Self(
      fetchPartners: { page, size in
        let endpoint = FetchPartnersEndpoint(page: page, size: size)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<[PartnerSummaryResponse]>.self
        )
        if let apiError = response.error {
          throw HistoryAPIClientError.backendError(apiError.message ?? apiError.code)
        }
        guard response.success, let data = response.data else {
          throw HistoryAPIClientError.invalidResponse
        }
        return data.map { $0.toDomain() }
      },
      searchPartners: { query in
        let endpoint = SearchPartnersEndpoint(query: query)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<[DoriResponsesDTO]>.self
        )
        if let apiError = response.error {
          throw HistoryAPIClientError.backendError(apiError.message ?? apiError.code)
        }
        guard response.success, let data = response.data else {
          throw HistoryAPIClientError.invalidResponse
        }
        return data.map { $0.toDomain() }
      },
      fetchPartnerDoriList: { partnerId in
        let endpoint = FetchPartnerDoriListEndpoint(partnerId: partnerId)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<PartnerDoriListResponse>.self
        )
        if let apiError = response.error {
          throw HistoryAPIClientError.backendError(apiError.message ?? apiError.code)
        }
        guard response.success, let data = response.data else {
          throw HistoryAPIClientError.invalidResponse
        }
        return data.toDomain()
      },
      fetchDoriDetail: { doriId in
        let endpoint = FetchDoriDetailEndpoint(doriId: doriId)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<DoriResponsesDTO>.self
        )
        if let apiError = response.error {
          throw HistoryAPIClientError.backendError(apiError.message ?? apiError.code)
        }
        guard response.success, let data = response.data else {
          throw HistoryAPIClientError.invalidResponse
        }
        return data.toDomain()
      },
      updateDori: { doriId, input in
        let endpoint = UpdateDoriEndpoint(doriId: doriId, request: input.toRequest())
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<DoriResponsesDTO>.self
        )
        if let apiError = response.error {
          throw HistoryAPIClientError.backendError(apiError.message ?? apiError.code)
        }
        guard response.success, let data = response.data else {
          throw HistoryAPIClientError.invalidResponse
        }
        return data.toDomain()
      },
      deleteDori: { doriId in
        let endpoint = DeleteDoriEndpoint(doriId: doriId)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<String>.self
        )
        if let apiError = response.error {
          throw HistoryAPIClientError.backendError(apiError.message ?? apiError.code)
        }
        guard response.success else {
          throw HistoryAPIClientError.invalidResponse
        }
      },
      bulkDeleteDori: { doriIds in
        let endpoint = BulkDeleteDoriEndpoint(doriIds: doriIds)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<[Int64]>.self
        )
        if let apiError = response.error {
          throw HistoryAPIClientError.backendError(apiError.message ?? apiError.code)
        }
        guard response.success, let data = response.data else {
          throw HistoryAPIClientError.invalidResponse
        }
        return data
      }
    )
  }
}

// MARK: - DTO → Domain 매핑

private extension DoriResponsesDTO {
  func toDomain() -> Dori {
    Dori(
      doriId: doriId,
      userId: userId,
      partnerId: partnerId,
      direction: direction == "OUT" ? .judori : .baddori,
      partnerName: partnerName,
      relationship: relationship,
      eventType: eventType,
      amount: amount,
      eventDate: eventDate,
      isVisited: isVisited,
      memo: memo ?? "",
      createdAt: createdAt
    )
  }
}

private extension PartnerSummaryResponse {
  func toDomain() -> PartnerSummary {
    PartnerSummary(
      partnerId: partnerId,
      partnerName: partnerName,
      relationship: relationship,
      recentDoriList: recentDoriList.map { $0.toDomain() },
      inDoriTotalAmount: inDoriTotalAmount,
      outDoriTotalAmount: outDoriTotalAmount
    )
  }
}

private extension PartnerDoriListResponse {
  func toDomain() -> PartnerDoriList {
    PartnerDoriList(
      userId: userId,
      partnerId: partnerId,
      partnerName: partnerName,
      relationship: relationship,
      inDoriTotalAmount: inDoriTotalAmount,
      inDoriList: inDoriList.map { $0.toDomain() },
      outDoriTotalAmount: outDoriTotalAmount,
      outDoriList: outDoriList.map { $0.toDomain() }
    )
  }
}

private extension DoriUpdateInput {
  func toRequest() -> DoriUpdateRequest {
    DoriUpdateRequest(
      direction: direction?.rawValue,
      eventType: eventType,
      amount: amount,
      eventDate: eventDate,
      isVisited: isVisited,
      memo: memo
    )
  }
}
