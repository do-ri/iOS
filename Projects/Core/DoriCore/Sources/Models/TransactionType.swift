//
//  TransactionType.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import Foundation

public enum TransactionType: String, CaseIterable, Codable, Equatable, Sendable, Hashable, Identifiable {
  case given = "주도리"
  case received = "받도리"

  public var id: String { rawValue }
}
