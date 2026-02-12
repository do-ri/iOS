//
//  AuthTokenStoring.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation

public protocol AuthTokenStoring: Sendable {
  func save(accessToken: String, refreshToken: String?) throws
  func load() -> (accessToken: String?, refreshToken: String?)
  func clear() throws
  func exists() throws -> Bool
}
