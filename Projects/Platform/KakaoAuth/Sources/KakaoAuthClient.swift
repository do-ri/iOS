//
//  KakaoAuthClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation
import ComposableArchitecture
import KakaoSDKUser

public struct KakaoAuthClient: Sendable {
  public var login: @Sendable () async throws -> String

  public init(login: @escaping @Sendable () async throws -> String) {
    self.login = login
  }
}

extension KakaoAuthClient: DependencyKey {
  public static let liveValue = Self(
    login: {
      if UserApi.isKakaoTalkLoginAvailable() {
        return try await loginWithKakaoTalk()
      }
      return try await loginWithKakaoAccount()
    }
  )

  public static let testValue = Self(
    login: { "test-access-token" }
  )

  private enum KakaoAuthClientError: LocalizedError {
    case missingToken

    var errorDescription: String? {
      switch self {
      case .missingToken:
        return "카카오 인증 토큰을 가져올 수 없습니다."
      }
    }
  }

  @MainActor
  private static func loginWithKakaoTalk() async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.loginWithKakaoTalk { token, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        guard let accessToken = token?.accessToken else {
          continuation.resume(throwing: KakaoAuthClientError.missingToken)
          return
        }
        continuation.resume(returning: accessToken)
      }
    }
  }

  @MainActor
  private static func loginWithKakaoAccount() async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.loginWithKakaoAccount { token, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        guard let accessToken = token?.accessToken else {
          continuation.resume(throwing: KakaoAuthClientError.missingToken)
          return
        }
        continuation.resume(returning: accessToken)
      }
    }
  }
}

public extension DependencyValues {
  var kakaoAuthClient: KakaoAuthClient {
    get { self[KakaoAuthClient.self] }
    set { self[KakaoAuthClient.self] = newValue }
  }
}
