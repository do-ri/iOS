//
//  DoriSegmentOption.swift
//  DoriCore
//
//  Created by 강동영 on 2/23/26.
//  Copyright © 2026 com.arex. All rights reserved.
//


public struct DoriSegmentOption<ID: Hashable>: Identifiable {
  public enum Role { case normal, other }
  
  public let id: ID
  public let title: String
  public let role: Role
  
  public init(id: ID, title: String, role: Role) {
    self.id = id
    self.title = title
    self.role = role
  }
}
