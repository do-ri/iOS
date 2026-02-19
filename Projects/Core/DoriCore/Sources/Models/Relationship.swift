//
//  Relationship.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import Foundation

public enum Relationship: String, CaseIterable, Codable, Equatable, Sendable, Hashable, Identifiable {
  case friend = "친구"
  case family = "가족"
  case company = "회사"
  case other = "기타"

  public var id: String { rawValue }
}
