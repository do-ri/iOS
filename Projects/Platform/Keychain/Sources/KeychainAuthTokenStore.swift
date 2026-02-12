//
//  KeychainAuthTokenStore.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation
import Security
import DoriNetwork

public struct KeychainAuthTokenStore: AuthTokenStoring {
  private let service: String

  public init(service: String) {
    self.service = service
  }

  public func save(accessToken: String, refreshToken: String?) throws {
    try set(accessToken, for: .accessToken)
    if let refreshToken {
      try set(refreshToken, for: .refreshToken)
    }
  }

  public func load() -> (accessToken: String?, refreshToken: String?) {
    let accessToken = try? string(for: .accessToken)
    let refreshToken = try? string(for: .refreshToken)
    return (accessToken, refreshToken)
  }

  public func clear() throws {
    _ = try? delete(.accessToken)
    _ = try? delete(.refreshToken)
  }

  public func exists() throws -> Bool {
    try contains(.accessToken)
  }
}

private extension KeychainAuthTokenStore {
  func set(_ value: String, for key: DoriKeychainKey) throws {
    guard let data = value.data(using: .utf8) else {
      throw KeychainError.invalidData
    }

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key.rawValue,
      kSecValueData as String: data,
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    do {
      try handleError(status)
    } catch KeychainError.duplicateItem {
      try updateExisting(data, for: key)
    }
  }

  func updateExisting(_ data: Data, for key: DoriKeychainKey) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key.rawValue,
    ]

    let attributes: [String: Any] = [kSecValueData as String: data]
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    try handleError(status)
  }

  func string(for key: DoriKeychainKey) throws -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key.rawValue,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    try handleError(status)

    guard let data = item as? Data else {
      throw KeychainError.unexpectedPasswordData
    }

    guard let string = String(data: data, encoding: .utf8) else {
      throw KeychainError.unexpectedPasswordData
    }

    return string
  }

  func delete(_ key: DoriKeychainKey) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key.rawValue,
    ]

    let status = SecItemDelete(query as CFDictionary)
    if status == errSecItemNotFound {
      return
    }
    try handleError(status)
  }

  func contains(_ key: DoriKeychainKey) throws -> Bool {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key.rawValue,
    ]

    let status = SecItemCopyMatching(query as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      return true
    case errSecItemNotFound:
      return false
    default:
      throw KeychainError.unexpected(status)
    }
  }

  func handleError(_ status: OSStatus) throws {
    switch status {
    case errSecSuccess:
      return
    case errSecDuplicateItem:
      throw KeychainError.duplicateItem
    case errSecItemNotFound:
      throw KeychainError.itemNotFound
    default:
      throw KeychainError.unexpected(status)
    }
  }
}
