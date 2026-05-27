import Foundation
import DoriCore

public extension PartnerSummary {
  static let mock = PartnerSummary(
    partnerId: 100,
    partnerName: "조카 1",
    relationship: "가족",
    recentDoriList: [.mockJudori],
    inDoriTotalAmount: 50_000,
    outDoriTotalAmount: 0
  )

  static let mockList: [PartnerSummary] = [
    .mock,
    PartnerSummary(
      partnerId: 101,
      partnerName: "친구 김철수",
      relationship: "친구",
      recentDoriList: [.mockBaddori],
      inDoriTotalAmount: 0,
      outDoriTotalAmount: 100_000
    ),
    PartnerSummary(
      partnerId: 102,
      partnerName: "사촌 형",
      relationship: "가족",
      recentDoriList: [],
      inDoriTotalAmount: 30_000,
      outDoriTotalAmount: 0
    ),
  ]
}
