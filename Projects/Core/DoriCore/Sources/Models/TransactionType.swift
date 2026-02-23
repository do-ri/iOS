//
//  TransactionType.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import Foundation

public enum TransactionType: String, CaseIterable, Codable, Equatable, Sendable, Hashable, Identifiable {
  case judori = "OUT"
  case baddori = "IN"

  public var id: String { rawValue }
  
  public var displayName: String {
    switch self {
    case .judori:
      "주도리"
    case .baddori:
      "받도리"
    }
  }
}
