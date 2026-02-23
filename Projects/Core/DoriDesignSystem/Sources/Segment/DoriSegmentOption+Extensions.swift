//
//  DoriSegmentOption+Extensions.swift
//  DoriCore
//
//  Created by 강동영 on 2/23/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import DoriCore

public extension Relationship {
  func toSegmentOptions() -> DoriSegmentOption<Self> {
    if self == .other {
      DoriSegmentOption(id: self, title: self.rawValue, role: .other)
    } else {
      DoriSegmentOption(id: self, title: self.rawValue, role: .normal)
    }
  }
}

public extension EventType {
  func toSegmentOptions() -> DoriSegmentOption<Self> {
    if self == .other {
      DoriSegmentOption(id: self, title: self.rawValue, role: .other)
    } else {
      DoriSegmentOption(id: self, title: self.rawValue, role: .normal)
    }
  }
}

public extension Visited {
  func toSegmentOptions() -> DoriSegmentOption<Self> {
    DoriSegmentOption(id: self, title: self.rawValue, role: .normal)
  }
}
