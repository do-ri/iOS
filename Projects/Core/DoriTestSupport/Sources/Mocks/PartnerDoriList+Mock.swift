import Foundation
import DoriCore

public extension PartnerDoriList {
  static let mock = PartnerDoriList(
    userId: 1,
    partnerId: 100,
    partnerName: "조카 1",
    relationship: "가족",
    inDoriTotalAmount: 80_000,
    inDoriList: [.mockJudori],
    outDoriTotalAmount: 50_000,
    outDoriList: [.mockBaddori]
  )

  static let mockEmpty = PartnerDoriList(
    userId: 1,
    partnerId: 999,
    partnerName: "이름 없음",
    relationship: "기타",
    inDoriTotalAmount: 0,
    inDoriList: [],
    outDoriTotalAmount: 0,
    outDoriList: []
  )
}
