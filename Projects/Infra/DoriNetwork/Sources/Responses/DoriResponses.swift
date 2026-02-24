//
//  DoriResponses.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/10/26.
//

import Foundation

// MARK: - Dori Response DTOs

public struct DoriResponsesDTO: Codable, Equatable, Sendable {
  public let doriId: Int64
  public let userId: Int64
  public let partnerId: Int64
  public let direction: String
  public let partnerName: String
  public let relationship: String
  public let eventType: String
  public let amount: Int32
  public let eventDate: String
  public let isVisited: Bool
  public let memo: String?
  public let createdAt: String
  
  public init(
    doriId: Int64,
    userId: Int64,
    partnerId: Int64,
    direction: String,
    partnerName: String,
    relationship: String,
    eventType: String,
    amount: Int32,
    eventDate: String,
    isVisited: Bool,
    memo: String?,
    createdAt: String
  ) {
    self.doriId = doriId
    self.userId = userId
    self.partnerId = partnerId
    self.direction = direction
    self.partnerName = partnerName
    self.relationship = relationship
    self.eventType = eventType
    self.amount = amount
    self.eventDate = eventDate
    self.isVisited = isVisited
    self.memo = memo
    self.createdAt = createdAt
  }
}

public struct DoriListResponseDTO: Codable, Equatable, Sendable {
  public let userId: Int64
  public let year: Int
  public let month: Int
  public let inDoriTotalAmount: Int
  public let inDoriDayList: [Int]
  public let inDoriList: [DoriListItemDTO]
  public let outDoriTotalAmount: Int
  public let outDoriDayList: [Int]
  public let outDoriList: [DoriListItemDTO]

  public init(
    userId: Int64,
    year: Int,
    month: Int,
    inDoriTotalAmount: Int,
    inDoriDayList: [Int],
    inDoriList: [DoriListItemDTO],
    outDoriTotalAmount: Int,
    outDoriDayList: [Int],
    outDoriList: [DoriListItemDTO]
  ) {
    self.userId = userId
    self.year = year
    self.month = month
    self.inDoriTotalAmount = inDoriTotalAmount
    self.inDoriDayList = inDoriDayList
    self.inDoriList = inDoriList
    self.outDoriTotalAmount = outDoriTotalAmount
    self.outDoriDayList = outDoriDayList
    self.outDoriList = outDoriList
  }
}

public struct DoriListItemDTO: Codable, Equatable, Sendable {
  public let doriId: Int64
  public let userId: Int64
  public let partnerId: Int64
  public let direction: String
  public let partnerName: String
  public let relationship: String
  public let eventType: String
  public let amount: Int
  public let eventDate: String
  public let isVisited: Bool
  public let memo: String?
  public let createdAt: String

  public init(
    doriId: Int64,
    userId: Int64,
    partnerId: Int64,
    direction: String,
    partnerName: String,
    relationship: String,
    eventType: String,
    amount: Int,
    eventDate: String,
    isVisited: Bool,
    memo: String?,
    createdAt: String
  ) {
    self.doriId = doriId
    self.userId = userId
    self.partnerId = partnerId
    self.direction = direction
    self.partnerName = partnerName
    self.relationship = relationship
    self.eventType = eventType
    self.amount = amount
    self.eventDate = eventDate
    self.isVisited = isVisited
    self.memo = memo
    self.createdAt = createdAt
  }
}

