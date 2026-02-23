//
//  AddDoriAPIClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import Foundation
import ComposableArchitecture
import DoriCore
import DoriNetwork

public struct AddDoriAPIClient: Sendable {
  public var searchPartners: @Sendable (_ query: String) async throws -> [Dori]
  public var createDori: @Sendable (DoriPostInput) async throws -> Dori
  public var updateDori: @Sendable (_ doriId: Int64, _ input: DoriUpdateInput) async throws -> Dori

  public init(
    searchPartners: @escaping @Sendable (_ query: String) async throws -> [Dori],
    createDori: @escaping @Sendable (DoriPostInput) async throws -> Dori,
    updateDori: @escaping @Sendable (_ doriId: Int64, _ input: DoriUpdateInput) async throws -> Dori
  ) {
    self.searchPartners = searchPartners
    self.createDori = createDori
    self.updateDori = updateDori
  }
}

private enum AddDoriAPIClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "AddDoriAPIClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    }
  }
}

extension AddDoriAPIClient: DependencyKey {
  public static let liveValue = Self(
    searchPartners: { _ in throw AddDoriAPIClientError.unconfigured },
    createDori: { _ in throw AddDoriAPIClientError.unconfigured },
    updateDori: { _, _ in throw AddDoriAPIClientError.unconfigured }
  )

  public static let previewValue = Self(
    searchPartners: { query in
      [
        Dori(
          doriId: 1,
          userId: 1,
          partnerId: 1,
          direction: .judori,
          partnerName: "박수진",
          relationship: "친구",
          eventType: "결혼식",
          amount: 100_000,
          eventDate: "2026-01-10",
          isVisited: true,
          memo: "",
          createdAt: "2026-01-10"
        ),
        Dori(
          doriId: 2,
          userId: 1,
          partnerId: 2,
          direction: .judori,
          partnerName: "박민준",
          relationship: "가족",
          eventType: "장례식",
          amount: 200_000,
          eventDate: "2025-08-20",
          isVisited: true,
          memo: "많이 힘드셨을텐데",
          createdAt: "2025-08-20"
        ),
        Dori(
          doriId: 3,
          userId: 1,
          partnerId: 3,
          direction: .baddori,
          partnerName: "김철수",
          relationship: "직장동료",
          eventType: "돌잔치",
          amount: 50_000,
          eventDate: "2025-11-05",
          isVisited: false,
          memo: "",
          createdAt: "2025-11-05"
        ),
        Dori(
          doriId: 4,
          userId: 1,
          partnerId: 4,
          direction: .baddori,
          partnerName: "김영희",
          relationship: "친척",
          eventType: "생신",
          amount: 100_000,
          eventDate: "2026-02-01",
          isVisited: true,
          memo: "",
          createdAt: "2026-02-01"
        ),
      ].filter { $0.partnerName.contains(query) }
    },
    createDori: { input in
      Dori(
        doriId: 1,
        userId: 1,
        partnerId: input.partnerId ?? 0,
        direction: input.direction,
        partnerName: input.partnerName,
        relationship: input.relationship,
        eventType: input.eventType,
        amount: input.amount,
        eventDate: input.eventDate,
        isVisited: input.isVisited,
        memo: input.memo ?? "",
        createdAt: "2026-02-15"
      )
    },
    updateDori: { doriId, input in
      Dori(
        doriId: doriId,
        userId: 1,
        partnerId: 1,
        direction: input.direction ?? .judori,
        partnerName: "김철수",
        relationship: "친구",
        eventType: input.eventType ?? "결혼식",
        amount: input.amount ?? 50_000,
        eventDate: input.eventDate ?? "2026-02-15",
        isVisited: input.isVisited ?? true,
        memo: input.memo ?? "",
        createdAt: "2026-02-15"
      )
    }
  )

  public static let testValue = Self(
    searchPartners: { _ in [] },
    createDori: { input in
      Dori(
        doriId: 1,
        userId: 1,
        partnerId: input.partnerId ?? 0,
        direction: input.direction,
        partnerName: input.partnerName,
        relationship: input.relationship,
        eventType: input.eventType,
        amount: input.amount,
        eventDate: input.eventDate,
        isVisited: input.isVisited,
        memo: input.memo ?? "",
        createdAt: "2026-02-15"
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
    }
  )
}

public extension DependencyValues {
  var addDoriAPIClient: AddDoriAPIClient {
    get { self[AddDoriAPIClient.self] }
    set { self[AddDoriAPIClient.self] = newValue }
  }
}

public extension AddDoriAPIClient {
  static func live(networkService: any NetworkService) -> Self {
    Self(
      searchPartners: { query in
        let endpoint = SearchPartnersEndpoint(query: query)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<[DoriResponsesDTO]>.self
        )

        if let apiError = response.error {
          throw AddDoriAPIClientError.backendError(apiError.message ?? apiError.code)
        }

        guard response.success, let data = response.data else {
          throw AddDoriAPIClientError.invalidResponse
        }

        return data.map { $0.toDomain() }
      },
      createDori: { input in
        let endpoint = CreateDoriEndpoint(request: input.toRequest())
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<DoriResponsesDTO>.self
        )

        if let apiError = response.error {
          throw AddDoriAPIClientError.backendError(apiError.message ?? apiError.code)
        }

        guard response.success, let data = response.data else {
          throw AddDoriAPIClientError.invalidResponse
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
          throw AddDoriAPIClientError.backendError(apiError.message ?? apiError.code)
        }

        guard response.success, let data = response.data else {
          throw AddDoriAPIClientError.invalidResponse
        }

        return data.toDomain()
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

private extension DoriPostInput {
  func toRequest() -> DoriPostRequest {
    DoriPostRequest(
      partnerId: partnerId,
      direction: direction.rawValue,
      partnerName: partnerName,
      relationship: relationship,
      eventType: eventType,
      amount: amount,
      eventDate: eventDate,
      isVisited: isVisited,
      memo: memo
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
