//
//  KakaoServerLoginClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation
import ComposableArchitecture
import DoriNetwork

public struct KakaoServerLoginClient: Sendable {
  public var login: @Sendable (_ kakaoAccessToken: String) async throws -> SocialLoginResponse

  public init(login: @escaping @Sendable (_ kakaoAccessToken: String) async throws -> SocialLoginResponse) {
    self.login = login
  }
}

private enum KakaoServerLoginClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "KakaoServerLoginClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    }
  }
}

extension KakaoServerLoginClient: DependencyKey {
  public static let liveValue = Self(
    login: { _ in
      throw KakaoServerLoginClientError.unconfigured
    }
  )

  public static let testValue = Self(
    login: { _ in
      SocialLoginResponse(
        accessToken: "test-jwt",
        refreshToken: "test-refresh",
        id: 1
      )
    }
  )
}

public extension DependencyValues {
  var kakaoServerLoginClient: KakaoServerLoginClient {
    get { self[KakaoServerLoginClient.self] }
    set { self[KakaoServerLoginClient.self] = newValue }
  }
}

public extension KakaoServerLoginClient {
  static func live(
    networkService: any NetworkService,
    tokenStore: any AuthTokenStoring
  ) -> Self {
    Self(
      login: { kakaoAccessToken in
        let endpoint = KakaoLoginEndpoint(accessToken: kakaoAccessToken)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<SocialLoginResponse>.self
        )

        if let apiError = response.error {
          throw KakaoServerLoginClientError.backendError(
            apiError.message ?? apiError.code
          )
        }

        guard response.success, let data = response.data else {
          throw KakaoServerLoginClientError.invalidResponse
        }

        print("token save accessToken: \(data.accessToken)")
        print("token save refreshToken: \(data.refreshToken)")
        try tokenStore.save(accessToken: data.accessToken, refreshToken: data.refreshToken)
        return data
      }
    )
  }
}
