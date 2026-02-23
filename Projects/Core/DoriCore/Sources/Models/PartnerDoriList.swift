//
//  PartnerDoriList.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/23/26.
//

import Foundation

public struct PartnerDoriList: Equatable, Sendable {
  public let userId: Int64
  public let partnerId: Int64
  public let partnerName: String
  public let relationship: String
  public let inDoriTotalAmount: Int64
  public let inDoriList: [Dori]
  public let outDoriTotalAmount: Int64
  public let outDoriList: [Dori]

  public init(
    userId: Int64,
    partnerId: Int64,
    partnerName: String,
    relationship: String,
    inDoriTotalAmount: Int64,
    inDoriList: [Dori],
    outDoriTotalAmount: Int64,
    outDoriList: [Dori]
  ) {
    self.userId = userId
    self.partnerId = partnerId
    self.partnerName = partnerName
    self.relationship = relationship
    self.inDoriTotalAmount = inDoriTotalAmount
    self.inDoriList = inDoriList
    self.outDoriTotalAmount = outDoriTotalAmount
    self.outDoriList = outDoriList
  }
}
