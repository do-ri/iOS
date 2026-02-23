//
//  PartnerDoriResponses.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import Foundation

// MARK: - Partner Summary Response (GET /dori/partners)

public struct PartnerSummaryResponse: Codable, Equatable, Sendable {
  public let partnerId: Int64
  public let partnerName: String
  public let relationship: String
  public let recentDoriList: [DoriResponsesDTO]
  public let inDoriTotalAmount: Int64
  public let outDoriTotalAmount: Int64

  public init(
    partnerId: Int64,
    partnerName: String,
    relationship: String,
    recentDoriList: [DoriResponsesDTO],
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

// MARK: - Partner Dori List Response (GET /dori/list/partner)

public struct PartnerDoriListResponse: Codable, Equatable, Sendable {
  public let userId: Int64
  public let partnerId: Int64
  public let partnerName: String
  public let relationship: String
  public let inDoriTotalAmount: Int64
  public let inDoriList: [DoriResponsesDTO]
  public let outDoriTotalAmount: Int64
  public let outDoriList: [DoriResponsesDTO]

  public init(
    userId: Int64,
    partnerId: Int64,
    partnerName: String,
    relationship: String,
    inDoriTotalAmount: Int64,
    inDoriList: [DoriResponsesDTO],
    outDoriTotalAmount: Int64,
    outDoriList: [DoriResponsesDTO]
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
