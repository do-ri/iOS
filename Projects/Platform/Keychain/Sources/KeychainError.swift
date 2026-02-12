//
//  KeychainError.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation

public enum KeychainError: Error {
  case itemNotFound
  case duplicateItem
  case invalidData
  case unexpected(OSStatus)
}

extension KeychainError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .itemNotFound:
      return "아이템을 찾을 수 없습니다."
    case .duplicateItem:
      return "이미 존재하는 아이템입니다."
    case .invalidData:
      return "유효하지 않은 데이터입니다."
    case .unexpected(let status):
      return "Keychain 에러: \(status)"
    }
  }
}
