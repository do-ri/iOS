//
//  MyPageFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import ComposableArchitecture
import DoriDesignSystem
import DoriNetwork
import Foundation

@Reducer
public struct MyPageFeature {
  @Dependency(\.myPageAPIClient) var myPageAPIClient
  @Dependency(\.continuousClock) var clock

  public init() {}

  private enum CancelID {
    case toastDismiss
  }

  @ObservableState
  public struct State: Equatable, Sendable {
    public var navigationPath: [Route]
    public var isLoading: Bool
    public var isLogoutAlertPresented: Bool
    public var isWithdrawAlertPresented: Bool
    public var toastItem: DoriToast?

    public init(
      isLoading: Bool = false,
      isLogoutAlertPresented: Bool = false,
      isWithdrawAlertPresented: Bool = false,
      toastItem: DoriToast? = nil
    ) {
      self.navigationPath = []
      self.isLoading = isLoading
      self.isLogoutAlertPresented = isLogoutAlertPresented
      self.isWithdrawAlertPresented = isWithdrawAlertPresented
      self.toastItem = toastItem
    }
  }

  public enum Action: Equatable, Sendable {
    case onAppear
    case privacyPolicyTapped
    case navigationPathChanged([Route])

    case logoutButtonTapped
    case withdrawButtonTapped
    case logoutAlertDismissed
    case withdrawAlertDismissed

    case logoutConfirmed
    case withdrawConfirmed

    case logoutSucceeded
    case logoutFailed(RequestError)
    case withdrawSucceeded
    case withdrawFailed(RequestError)

    case toastDismissed
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case didLogout
      case didWithdraw
      case authExpired
    }
  }

  public enum Route: Hashable, Sendable {
    case privacyPolicy
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .onAppear:
      return .none

    case .privacyPolicyTapped:
      state.navigationPath.append(.privacyPolicy)
      return .none

    case .navigationPathChanged(let path):
      state.navigationPath = path
      return .none

    case .logoutButtonTapped:
      state.isLogoutAlertPresented = true
      return .none

    case .withdrawButtonTapped:
      state.isWithdrawAlertPresented = true
      return .none

    case .logoutAlertDismissed:
      state.isLogoutAlertPresented = false
      return .none

    case .withdrawAlertDismissed:
      state.isWithdrawAlertPresented = false
      return .none

    case .logoutConfirmed:
      state.isLogoutAlertPresented = false
      state.isLoading = true
      state.toastItem = nil

      let client = myPageAPIClient

      return .run { send in
        do {
          try await client.logout()
          await send(.logoutSucceeded)
        } catch {
          await send(.logoutFailed(RequestError.from(error: error)))
        }
      }

    case .withdrawConfirmed:
      state.isWithdrawAlertPresented = false
      state.isLoading = true
      state.toastItem = nil

      let client = myPageAPIClient

      return .run { send in
        do {
          try await client.withdraw()
          await send(.withdrawSucceeded)
        } catch {
          await send(.withdrawFailed(RequestError.from(error: error)))
        }
      }

    case .logoutSucceeded:
      state.isLoading = false
      return showToast(
        &state,
        type: .info,
        message: "성공적으로 로그아웃 되었습니다.",
        additionalEffect: .send(.delegate(.didLogout))
      )

    case .logoutFailed(let error):
      state.isLoading = false

      if error == .unauthorized {
        return .send(.delegate(.authExpired))
      }

      return showToast(
        &state,
        type: .error,
        message: error.message
      )

    case .withdrawSucceeded:
      state.isLoading = false
      return showToast(
        &state,
        type: .info,
        message: "성공적으로 회원탈퇴 되었습니다.",
        additionalEffect: .send(.delegate(.didWithdraw))
      )

    case .withdrawFailed(let error):
      state.isLoading = false

      if error == .unauthorized {
        return .send(.delegate(.authExpired))
      }

      return showToast(
        &state,
        type: .error,
        message: error.message
      )

    case .toastDismissed:
      state.toastItem = nil
      return .cancel(id: CancelID.toastDismiss)

    case .delegate:
      return .none
    }
  }

  private func showToast(
    _ state: inout State,
    type: ToastType,
    message: String,
    additionalEffect: Effect<Action>? = nil
  ) -> Effect<Action> {
    let toast = DoriToast(
      type: type,
      message: message
    )
    state.toastItem = toast

    let clock = self.clock
    let timerEffect: Effect<Action> = .run { send in
      try await clock.sleep(for: .seconds(toast.duration))
      await send(.toastDismissed)
    }
    .cancellable(
      id: CancelID.toastDismiss,
      cancelInFlight: true
    )

    if let additionalEffect {
      return .merge(timerEffect, additionalEffect)
    }

    return timerEffect
  }
}

@DependencyClient
public struct MyPageAPIClient: Sendable {
  public var logout: @Sendable () async throws -> Void
  public var withdraw: @Sendable () async throws -> Void
}

private enum MyPageAPIClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)
  case missingRefreshToken

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "MyPageAPIClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    case .missingRefreshToken:
      return "리프레시 토큰이 없습니다."
    }
  }
}

extension MyPageAPIClient: DependencyKey {
  public static let liveValue = Self(
    logout: { throw MyPageAPIClientError.unconfigured },
    withdraw: { throw MyPageAPIClientError.unconfigured }
  )
}

extension MyPageAPIClient: TestDependencyKey {
  public static let previewValue = Self(
    logout: {},
    withdraw: {}
  )

  public static let testValue = Self()
}

public extension MyPageAPIClient {
  static func live(
    networkService: any NetworkService,
    tokenStore: any AuthTokenStoring
  ) -> Self {
    Self(
      logout: {
        let tokens = tokenStore.load()
        guard let refreshToken = tokens.refreshToken, !refreshToken.isEmpty else {
          throw MyPageAPIClientError.missingRefreshToken
        }

        let endpoint = LogoutEndpoint(refreshToken: refreshToken)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<EmptyResponse>.self
        )

        if let apiError = response.error {
          throw MyPageAPIClientError.backendError(
            apiError.message ?? "로그아웃에 실패했습니다."
          )
        }

        guard response.success else {
          throw MyPageAPIClientError.invalidResponse
        }

        try tokenStore.clear()
      },
      withdraw: {
        let endpoint = WithdrawEndpoint()
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<EmptyResponse>.self
        )

        if let apiError = response.error {
          throw MyPageAPIClientError.backendError(
            apiError.message ?? "회원탈퇴에 실패했습니다."
          )
        }

        guard response.success else {
          throw MyPageAPIClientError.invalidResponse
        }

        try tokenStore.clear()
      }
    )
  }
}

public extension DependencyValues {
  var myPageAPIClient: MyPageAPIClient {
    get { self[MyPageAPIClient.self] }
    set { self[MyPageAPIClient.self] = newValue }
  }
}

public enum RequestError: Error, Equatable, Sendable {
  case unauthorized
  case invalidResponse
  case decoding(String)
  case http(Int)
  case api(String)
  case unknown(String)

  static func from(error: Error) -> Self {
    if let requestError = error as? RequestError {
      return requestError
    }

    if let networkError = error as? NetworkError {
      switch networkError {
      case .unauthorized:
        return .unauthorized
      case .invalidResponse:
        return .invalidResponse
      case .http(let statusCode, _):
        return .http(statusCode)
      case .decoding(let error):
        return .decoding(error.localizedDescription)
      default:
        return .unknown(networkError.localizedDescription)
      }
    }

    return .unknown(error.localizedDescription)
  }

  var message: String {
    switch self {
    case .unauthorized:
      return "인증이 만료되었습니다. 다시 로그인해주세요."
    case .invalidResponse:
      return "응답 형식이 올바르지 않습니다."
    case .decoding(let message):
      return "디코딩 에러: \(message)"
    case .http(let statusCode):
      return "서버 오류(\(statusCode))가 발생했습니다."
    case .api(let message):
      return message
    case .unknown(let message):
      return message
    }
  }
}
