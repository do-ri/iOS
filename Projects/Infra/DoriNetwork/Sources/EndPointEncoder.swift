//
//  EndPointEncoder.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/7/26.
//

import Foundation

public protocol EndPointEncoder {
  func encode(_ value: Encodable) -> [String: String]
}

public struct DefaultQueryEncoder: EndPointEncoder {
  public init() {}
  public func encode(_ value: Encodable) -> [String: String] {
    let encoder = JSONEncoder()
    guard
      let data = try? encoder.encode(value),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: String]
    else { return [:] }
    
    return object
  }
}
