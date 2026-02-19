//
//  Int+Extensions.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation

public extension Int {
  // "100,000원" 형식
  var wonFormatted: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ko_KR")
    let formatted = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    return "\(formatted)원"
  }

  // "100,000" 형식 (원 없이)
  var decimalFormatted: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
  }
}
