//
//  IntroFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation
import PlatformKakaoAuth
import DoriNetwork
import ComposableArchitecture

@Reducer
public struct IntroFeature : Sendable {
  public init() {}

  @ObservableState
  public struct State: Equatable, Sendable {
    public var isLoading = false
    public var loginSucceeded = false
    public var errorMessage: String?

    public init() {}
  }

  public enum Action: Equatable, Sendable {
    case kakaoLoginButtonTapped
    case kakaoLoginResponse(Result<SocialLoginResponse, KakaoLoginFailure>)
    case errorAlertDismissed
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case loginSucceeded
    }
  }

  @Dependency(KakaoAuthClient.self) var kakaoAuthClient
  @Dependency(KakaoServerLoginClient.self) var kakaoServerLoginClient

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .kakaoLoginButtonTapped:
      guard !state.isLoading else { return .none }
      state.isLoading = true
      state.errorMessage = nil
      return .run { send in
        do {
          let kakaoAccessToken = try await kakaoAuthClient.login()
          print("kakaoAccessToken: \(kakaoAccessToken)")
          let loginResponse = try await kakaoServerLoginClient.login(kakaoAccessToken)
          await send(.kakaoLoginResponse(.success(loginResponse)))
        } catch {
          await send(.kakaoLoginResponse(.failure(KakaoLoginFailure(error))))
        }
      }

    case .kakaoLoginResponse(.success):
      state.isLoading = false
      state.loginSucceeded = true
      return .send(.delegate(.loginSucceeded))

    case let .kakaoLoginResponse(.failure(error)):
      state.isLoading = false
      state.errorMessage = error.message
      return .none

    case .errorAlertDismissed:
      state.errorMessage = nil
      return .none

    case .delegate:
      return .none
    }
  }
}

public struct KakaoLoginFailure: Error, Equatable, Sendable {
  public let message: String

  public init(_ error: Error) {
    let description = (error as NSError).localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    self.message = description.isEmpty ? "로그인 중 오류가 발생했습니다." : description
  }
}
