//
//  PartnerSummary.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/23/26.
//

import Foundation

public struct PartnerSummary: Identifiable, Equatable, Hashable, Sendable {
  public var id: Int64 { partnerId }

  public let partnerId: Int64
  public let partnerName: String
  public let relationship: String
  public let recentDoriList: [Dori]
  public let inDoriTotalAmount: Int64
  public let outDoriTotalAmount: Int64

  public init(
    partnerId: Int64,
    partnerName: String,
    relationship: String,
    recentDoriList: [Dori],
    inDoriTotalAmount: Int64,
    outDoriTotalAmount: Int64
  ) {
    self.partnerId = partnerId
    self.partnerName = partnerName
    self.relationship = relationship
    self.recentDoriList = recentDoriList
    self.inDoriTotalAmount = inDoriTotalAmount
    self.outDoriTotalAmount = outDoriTotalAmount
  }
}
