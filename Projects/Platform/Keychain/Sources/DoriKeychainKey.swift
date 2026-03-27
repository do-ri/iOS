//
//  DoriKeychainKey.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation

public enum DoriKeychainKey: Sendable {
  public static let serviceID = Bundle.main.bundleIdentifier ?? "com.arex.dori"

  case accessToken
  case refreshToken
  case fcmToken

  public var rawValue: String {
    switch self {
    case .accessToken: return "access_token"
    case .refreshToken: return "refresh_token"
    case .fcmToken: return "fcm_token"
    }
  }
}
