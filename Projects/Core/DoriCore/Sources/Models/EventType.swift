//
//  EventType.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import Foundation

public enum EventType: String, CaseIterable, Codable, Equatable, Sendable, Identifiable {
  case wedding = "결혼식"
  case funeral = "장례식"
  case firstBirthday = "돌잔치"
  case housewarming = "집들이"
  case birthday = "생일"
  case other = "기타"

  public var id: String { rawValue }
}
