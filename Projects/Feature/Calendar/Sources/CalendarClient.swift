//
//  CalendarClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/17/26.
//

import Foundation
import ComposableArchitecture
import DoriCore
import DoriNetwork

public struct CalendarDori: Identifiable, Sendable, Codable, Hashable {
  public let id: Int64
  public let type: TransactionType
  public let partnerName: String
  public let relationship: String
  public let eventType: String
  public let amount: Int
  public let eventDate: Date
  public let isVisited: Bool
  public let memo: String?

  public init(
    id: Int64,
    type: TransactionType,
    partnerName: String,
    relationship: String,
    eventType: String,
    amount: Int,
    eventDate: Date,
    isVisited: Bool,
    memo: String?
  ) {
    self.id = id
    self.type = type
    self.partnerName = partnerName
    self.relationship = relationship
    self.eventType = eventType
    self.amount = amount
    self.eventDate = eventDate
    self.isVisited = isVisited
    self.memo = memo
  }
}

public struct CalendarMonthlyData: Sendable, Equatable {
  public let year: Int
  public let month: Int
  public let inDoriTotalAmount: Int
  public let inDoriDayList: [Int]
  public let inDoriList: [CalendarDori]
  public let outDoriTotalAmount: Int
  public let outDoriDayList: [Int]
  public let outDoriList: [CalendarDori]

  public init(
    year: Int,
    month: Int,
    inDoriTotalAmount: Int,
    inDoriDayList: [Int],
    inDoriList: [CalendarDori],
    outDoriTotalAmount: Int,
    outDoriDayList: [Int],
    outDoriList: [CalendarDori]
  ) {
    self.year = year
    self.month = month
    self.inDoriTotalAmount = inDoriTotalAmount
    self.inDoriDayList = inDoriDayList
    self.inDoriList = inDoriList
    self.outDoriTotalAmount = outDoriTotalAmount
    self.outDoriDayList = outDoriDayList
    self.outDoriList = outDoriList
  }

  public static func empty(for month: Date) -> Self {
    Self(
      year: month.year,
      month: month.month,
      inDoriTotalAmount: 0,
      inDoriDayList: [],
      inDoriList: [],
      outDoriTotalAmount: 0,
      outDoriDayList: [],
      outDoriList: []
    )
  }
}

@DependencyClient
public struct CalendarClient: Sendable {
  public var fetchMonthlyData: @Sendable (
    _ month: Date,
    _ type: TransactionType
  ) async throws -> CalendarMonthlyData
}

private enum CalendarClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)
  case invalidEventDate(String)

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "CalendarClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    case .invalidEventDate(let value):
      return "올바르지 않은 날짜 형식입니다: \(value)"
    }
  }
}

extension CalendarClient: DependencyKey {
  public static let liveValue = Self(
    fetchMonthlyData: { _, _ in throw CalendarClientError.unconfigured }
  )

  public static let previewValue = Self(
    fetchMonthlyData: { month, _ in
      let calendar = Calendar(identifier: .gregorian)

      func makeDate(day: Int) -> Date {
        calendar.date(from: DateComponents(year: month.year, month: month.month, day: day)) ?? month
      }

      return CalendarMonthlyData(
        year: month.year,
        month: month.month,
        inDoriTotalAmount: 100_000,
        inDoriDayList: [1, 2, 8],
        inDoriList: [
          CalendarDori(
            id: 1,
            type: .baddori,
            partnerName: "홍길동",
            relationship: "지인",
            eventType: "생일",
            amount: 50_000,
            eventDate: makeDate(day: 1),
            isVisited: true,
            memo: "메모"
          )
        ],
        outDoriTotalAmount: 50_000,
        outDoriDayList: [3, 5],
        outDoriList: [
          CalendarDori(
            id: 2,
            type: .judori,
            partnerName: "김영희",
            relationship: "동료",
            eventType: "결혼",
            amount: 50_000,
            eventDate: makeDate(day: 3),
            isVisited: false,
            memo: nil
          )
        ]
      )
    }
  )

  public static let testValue = Self()
}

public extension CalendarClient {
  static func live(networkService: any NetworkService) -> Self {
    Self(
      fetchMonthlyData: { month, type in
        let request = DoriListRequest(
          direction: type.calendarDirection,
          year: String(month.year),
          month: String(month.month)
        )
        let endpoint = DoriListEndpoint(request: request)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<DoriListResponseDTO>.self
        )

        if let apiError = response.error {
          throw CalendarClientError.backendError(apiError.message ?? apiError.code)
        }

        guard response.success, let data = response.data else {
          throw CalendarClientError.invalidResponse
        }

        return CalendarMonthlyData(
          year: data.year,
          month: data.month,
          inDoriTotalAmount: data.inDoriTotalAmount,
          inDoriDayList: data.inDoriDayList,
          inDoriList: try data.inDoriList.map { try $0.toDomain(type: .baddori) },
          outDoriTotalAmount: data.outDoriTotalAmount,
          outDoriDayList: data.outDoriDayList,
          outDoriList: try data.outDoriList.map { try $0.toDomain(type: .judori) }
        )
      }
    )
  }
}

public extension DependencyValues {
  var calendarClient: CalendarClient {
    get { self[CalendarClient.self] }
    set { self[CalendarClient.self] = newValue }
  }
}

private extension TransactionType {
  var calendarDirection: String {
    switch self {
    case .judori:
      return "OUT"
    case .baddori:
      return "IN"
    }
  }
}

private extension DoriListItemDTO {
  func toDomain(type: TransactionType) throws -> CalendarDori {
    guard let parsedEventDate = eventDate.calendarEventDate else {
      throw CalendarClientError.invalidEventDate(eventDate)
    }

    return CalendarDori(
      id: doriId,
      type: type,
      partnerName: partnerName,
      relationship: relationship,
      eventType: eventType,
      amount: amount,
      eventDate: parsedEventDate,
      isVisited: isVisited,
      memo: memo
    )
  }
}

private extension String {
  var calendarEventDate: Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: self)
  }
}
