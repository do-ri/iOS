//
//  CalendarDay.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/5/26.
//

import Foundation

public struct CalendarDay: Identifiable, Equatable, Sendable {
  public let id: Int
  public let day: Int
  public let date: Date?
  public let amount: Int?
  public let hasTransaction: Bool
  public let isCurrentMonth: Bool

  public init(
    id: Int,
    day: Int,
    date: Date? = nil,
    amount: Int? = nil,
    hasTransaction: Bool = false,
    isCurrentMonth: Bool = true,
  ) {
    self.id = id
    self.day = day
    self.date = date
    self.amount = amount
    self.hasTransaction = hasTransaction
    self.isCurrentMonth = isCurrentMonth
  }

  public var isSelectable: Bool {
    isCurrentMonth && hasTransaction
  }
}
