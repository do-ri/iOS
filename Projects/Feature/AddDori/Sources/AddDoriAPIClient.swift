//
//  AddDoriAPIClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import Foundation
import ComposableArchitecture
import DoriNetwork

public struct AddDoriAPIClient: Sendable {
  public var searchPartners: @Sendable (_ query: String) async throws -> [DoriResponsesDTO]
  public var createDori: @Sendable (DoriPostRequest) async throws -> DoriResponsesDTO
  public var updateDori: @Sendable (_ doriId: Int64, _ request: DoriUpdateRequest) async throws -> DoriResponsesDTO

  public init(
    searchPartners: @escaping @Sendable (_ query: String) async throws -> [DoriResponsesDTO],
    createDori: @escaping @Sendable (DoriPostRequest) async throws -> DoriResponsesDTO,
    updateDori: @escaping @Sendable (_ doriId: Int64, _ request: DoriUpdateRequest) async throws -> DoriResponsesDTO
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
        DoriResponsesDTO(
          doriId: 1,
          userId: 1,
          partnerId: 1,
          direction: "주도리",
          partnerName: "박수진",
          relationship: "친구",
          eventType: "결혼식",
          amount: 100_000,
          eventDate: "2026-01-10",
          isVisited: true,
          memo: "",
          createdAt: "2026-01-10"
        ),
        DoriResponsesDTO(
          doriId: 2,
          userId: 1,
          partnerId: 2,
          direction: "주도리",
          partnerName: "박민준",
          relationship: "가족",
          eventType: "장례식",
          amount: 200_000,
          eventDate: "2025-08-20",
          isVisited: true,
          memo: "많이 힘드셨을텐데",
          createdAt: "2025-08-20"
        ),
        DoriResponsesDTO(
          doriId: 3,
          userId: 1,
          partnerId: 3,
          direction: "받도리",
          partnerName: "김철수",
          relationship: "직장동료",
          eventType: "돌잔치",
          amount: 50_000,
          eventDate: "2025-11-05",
          isVisited: false,
          memo: "",
          createdAt: "2025-11-05"
        ),
        DoriResponsesDTO(
          doriId: 4,
          userId: 1,
          partnerId: 4,
          direction: "받도리",
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
    createDori: { request in
      DoriResponsesDTO(
        doriId: 1,
        userId: 1,
        partnerId: 0,
        direction: request.direction,
        partnerName: request.partnerName,
        relationship: request.relationship,
        eventType: request.eventType,
        amount: request.amount,
        eventDate: request.eventDate,
        isVisited: request.isVisited,
        memo: request.memo ?? "",
        createdAt: "2026-02-15"
      )
    },
    updateDori: { doriId, request in
      DoriResponsesDTO(
        doriId: doriId,
        userId: 1,
        partnerId: 1,
        direction: request.direction ?? "주도리",
        partnerName: "김철수",
        relationship: "친구",
        eventType: request.eventType ?? "결혼식",
        amount: request.amount ?? 50_000,
        eventDate: request.eventDate ?? "2026-02-15",
        isVisited: request.isVisited ?? true,
        memo: request.memo ?? "",
        createdAt: "2026-02-15"
      )
    }
  )

  public static let testValue = Self(
    searchPartners: { _ in [] },
    createDori: { request in
      DoriResponsesDTO(
        doriId: 1,
        userId: 1,
        partnerId: 0,
        direction: request.direction,
        partnerName: request.partnerName,
        relationship: request.relationship,
        eventType: request.eventType,
        amount: request.amount,
        eventDate: request.eventDate,
        isVisited: request.isVisited,
        memo: request.memo ?? "",
        createdAt: "2026-02-15"
      )
    },
    updateDori: { _, _ in
      DoriResponsesDTO(
        doriId: 1,
        userId: 1,
        partnerId: 1,
        direction: "주도리",
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

        return data
      },
      createDori: { request in
        let endpoint = CreateDoriEndpoint(request: request)
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

        return data
      },
      updateDori: { doriId, request in
        let endpoint = UpdateDoriEndpoint(doriId: doriId, request: request)
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

        return data
      }
    )
  }
}
