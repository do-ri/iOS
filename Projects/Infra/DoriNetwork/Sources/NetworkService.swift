//
//  NetworkService.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/7/26.
//

import Foundation

// MARK: - Network Interface Protocol
public protocol NetworkService: Sendable {
  func request<T: Decodable & Sendable>(_ endpoint: any Endpoint, responseType: T.Type) async throws -> T
}
