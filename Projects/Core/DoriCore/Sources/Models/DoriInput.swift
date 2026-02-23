//
//  DoriInput.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/23/26.
//

import Foundation

// MARK: - 생성 요청용

public struct DoriPostInput: Equatable, Sendable {
  public let partnerId: Int64?
  public let direction: TransactionType
  public let partnerName: String
  public let relationship: String
  public let eventType: String
  public let amount: Int32
  public let eventDate: String
  public let isVisited: Bool
  public let memo: String?

  public init(
    partnerId: Int64? = nil,
    direction: TransactionType,
    partnerName: String,
    relationship: String,
    eventType: String,
    amount: Int32,
    eventDate: String,
    isVisited: Bool,
    memo: String? = nil
  ) {
    self.partnerId = partnerId
    self.direction = direction
    self.partnerName = partnerName
    self.relationship = relationship
    self.eventType = eventType
    self.amount = amount
    self.eventDate = eventDate
    self.isVisited = isVisited
    self.memo = memo
  }
}

// MARK: - 수정 요청용

public struct DoriUpdateInput: Equatable, Sendable {
  public let direction: TransactionType?
  public let eventType: String?
  public let amount: Int32?
  public let eventDate: String?
  public let isVisited: Bool?
  public let memo: String?

  public init(
    direction: TransactionType? = nil,
    eventType: String? = nil,
    amount: Int32? = nil,
    eventDate: String? = nil,
    isVisited: Bool? = nil,
    memo: String? = nil
  ) {
    self.direction = direction
    self.eventType = eventType
    self.amount = amount
    self.eventDate = eventDate
    self.isVisited = isVisited
    self.memo = memo
  }
}
