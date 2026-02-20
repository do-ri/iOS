//
//  Visited.swift
//  AddDori
//
//  Created by 강동영 on 2/19/26.
//  Copyright © 2026 com.arex. All rights reserved.
//


public enum Visited: String, CaseIterable, Hashable, Sendable {
  case yes = "예"
  case no = "아니오"
  
  var boolValue: Bool {
    switch self {
    case .yes: return true
    case .no: return false
    }
  }
}
