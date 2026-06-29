//
//  AppleServerLoginClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/25/26.
//

import Foundation
import ComposableArchitecture
import DoriNetwork

public struct AppleServerLoginClient: Sendable {
  public var login: @Sendable (_ identityToken: String, _ user: AppleLoginUserInfo?) async throws -> SocialLoginResponse

  public init(login: @escaping @Sendable (_ identityToken: String, _ user: AppleLoginUserInfo?) async throws -> SocialLoginResponse) {
    self.login = login
  }
}

private enum AppleServerLoginClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "AppleServerLoginClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    }
  }
}

extension AppleServerLoginClient: DependencyKey {
  public static let liveValue = Self(
    login: { _, _ in
      throw AppleServerLoginClientError.unconfigured
    }
  )

  public static let testValue = Self(
    login: { _, _ in
      SocialLoginResponse(
        accessToken: "test-jwt",
        refreshToken: "test-refresh",
        id: 1
      )
    }
  )
}

public extension DependencyValues {
  var appleServerLoginClient: AppleServerLoginClient {
    get { self[AppleServerLoginClient.self] }
    set { self[AppleServerLoginClient.self] = newValue }
  }
}

public extension AppleServerLoginClient {
  static func live(
    networkService: any NetworkService,
    tokenStore: any AuthTokenStoring
  ) -> Self {
    Self(
      login: { identityToken, user in
        let endpoint = AppleLoginEndpoint(identityToken: identityToken, user: user)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<SocialLoginResponse>.self
        )

        if let apiError = response.error {
          throw AppleServerLoginClientError.backendError(
            apiError.message ?? apiError.code
          )
        }

        guard response.success, let data = response.data else {
          throw AppleServerLoginClientError.invalidResponse
        }

        print("token save accessToken: \(data.accessToken)")
        print("token save refreshToken: \(data.refreshToken)")
        try tokenStore.save(accessToken: data.accessToken, refreshToken: data.refreshToken)
        return data
      }
    )
  }
}
