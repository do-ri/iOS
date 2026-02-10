//
//  NetworkConfig.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/7/26.
//

import Foundation

public struct NetworkConfig {
  public static let baseURL: String = (Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String) ?? ""
  private init() {}
}
