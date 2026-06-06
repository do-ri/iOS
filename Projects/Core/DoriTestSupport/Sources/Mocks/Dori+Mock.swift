import Foundation
import DoriCore

public extension Dori {
  static let mockJudori = Dori(
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
  )

  static let mockBaddori = Dori(
    doriId: 101,
    userId: 1,
    partnerId: 101,
    direction: .baddori,
    partnerName: "친구 김철수",
    relationship: "친구",
    eventType: "결혼식",
    amount: 100_000,
    eventDate: "2025-08-20",
    isVisited: true,
    memo: "축의금",
    createdAt: "2026-02-20T10:30:00"
  )

  static let mock = mockJudori

  static let mockList: [Dori] = [
    .mockJudori,
    .mockBaddori,
    Dori(
      doriId: 102,
      userId: 1,
      partnerId: 102,
      direction: .judori,
      partnerName: "사촌 형",
      relationship: "가족",
      eventType: "돌잔치",
      amount: 30_000,
      eventDate: "2025-09-15",
      isVisited: false,
      memo: "",
      createdAt: "2026-03-01T14:00:00"
    ),
    Dori(
      doriId: 103,
      userId: 1,
      partnerId: 103,
      direction: .baddori,
      partnerName: "직장 동료",
      relationship: "직장",
      eventType: "장례식",
      amount: 50_000,
      eventDate: "2025-11-03",
      isVisited: true,
      memo: "",
      createdAt: "2026-03-10T09:15:00"
    ),
  ]
}
