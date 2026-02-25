//
//  AuthTokenStoreClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/25/26.
//

import Foundation
import ComposableArchitecture
import DoriNetwork

public struct AuthTokenStoreClient: Sendable {
  public var save: @Sendable (_ accessToken: String, _ refreshToken: String?) throws -> Void
  public var load: @Sendable () -> (accessToken: String?, refreshToken: String?)
  public var clear: @Sendable () throws -> Void
  public var exists: @Sendable () throws -> Bool

  public init(
    save: @escaping @Sendable (_ accessToken: String, _ refreshToken: String?) throws -> Void,
    load: @escaping @Sendable () -> (accessToken: String?, refreshToken: String?),
    clear: @escaping @Sendable () throws -> Void,
    exists: @escaping @Sendable () throws -> Bool
  ) {
    self.save = save
    self.load = load
    self.clear = clear
    self.exists = exists
  }
}

extension AuthTokenStoreClient: DependencyKey {
  public static let liveValue = Self(
    save: { _, _ in },
    load: { (nil, nil) },
    clear: {},
    exists: { false }
  )

  public static let testValue = Self(
    save: { _, _ in },
    load: { (nil, nil) },
    clear: {},
    exists: { false }
  )
}

public extension DependencyValues {
  var authTokenStore: AuthTokenStoreClient {
    get { self[AuthTokenStoreClient.self] }
    set { self[AuthTokenStoreClient.self] = newValue }
  }
}

public extension AuthTokenStoreClient {
  static func live(tokenStore: any AuthTokenStoring) -> Self {
    Self(
      save: { accessToken, refreshToken in
        try tokenStore.save(
          accessToken: accessToken,
          refreshToken: refreshToken
        )
      },
      load: {
        tokenStore.load()
      },
      clear: {
        try tokenStore.clear()
      },
      exists: {
        try tokenStore.exists()
      }
    )
  }
}
