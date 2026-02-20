//
//  DoriDomain.swift
//  DoriCore
//
//  Created by 강동영 on 2/19/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import Foundation

public struct Dori: Equatable, Sendable {
  public let doriId: Int64
  public let userId: Int64
  public let partnerId: Int64
  public let direction: Direction
  public let partnerName: String
  public let relationship: Relationship
  public let eventType: EventType
  public let amount: Int32
  public let eventDate: String
  public let isVisited: Bool
  public let memo: String
  public let createdAt: String
  
  public init(
    doriId: Int64,
    userId: Int64,
    partnerId: Int64,
    direction: Direction,
    partnerName: String,
    relationship: Relationship,
    eventType: EventType,
    amount: Int32,
    eventDate: String,
    isVisited: Bool,
    memo: String,
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

public extension Dori {
  enum Direction: String, Equatable, Sendable {
    case `in` = "IN"
    case out = "OUT"
  }
}
