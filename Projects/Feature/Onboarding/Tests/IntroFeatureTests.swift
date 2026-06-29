//
//  IntroFeatureTests.swift
//  Dori-iOS
//

import ComposableArchitecture
import Testing
import DoriNetwork
import PlatformAppleAuth
import PlatformKakaoAuth
@testable import FeatureOnboarding

@Suite("IntroFeature")
struct IntroFeatureTests {

  // MARK: - Apple Login

  @Test("Apple 로그인 성공 → loginSucceeded=true, delegate(.loginSucceeded) 발송")
  @MainActor
  func appleLogin_success() async {
    let store = TestStore(initialState: IntroFeature.State()) {
      IntroFeature()
    } withDependencies: {
      $0.appleAuthClient.login = {
        AppleAuthCredential(
          identityToken: "test-identity-token",
          firstName: "길동",
          lastName: "홍",
          email: "test@example.com"
        )
      }
      $0.appleServerLoginClient.login = { _, _ in
        SocialLoginResponse(accessToken: "test-jwt", refreshToken: "test-refresh", id: 1)
      }
    }

    await store.send(.appleLoginButtonTapped) {
      $0.isLoading = true
    }
    await store.receive(\.appleLoginResponse.success) {
      $0.isLoading = false
      $0.loginSucceeded = true
    }
    await store.receive(\.delegate.loginSucceeded)
  }

  @Test("AppleAuthClient 실패 → errorMessage 설정")
  @MainActor
  func appleLogin_authClientFails() async {
    let store = TestStore(initialState: IntroFeature.State()) {
      IntroFeature()
    } withDependencies: {
      $0.appleAuthClient.login = { throw StubError() }
    }

    await store.send(.appleLoginButtonTapped) {
      $0.isLoading = true
    }
    await store.receive(\.appleLoginResponse.failure) {
      $0.isLoading = false
      $0.errorMessage = StubError.message
    }
  }

  @Test("AppleServerLoginClient 실패 → errorMessage 설정")
  @MainActor
  func appleLogin_serverFails() async {
    let store = TestStore(initialState: IntroFeature.State()) {
      IntroFeature()
    } withDependencies: {
      $0.appleAuthClient.login = {
        AppleAuthCredential(identityToken: "test-identity-token")
      }
      $0.appleServerLoginClient.login = { _, _ in throw StubError() }
    }

    await store.send(.appleLoginButtonTapped) {
      $0.isLoading = true
    }
    await store.receive(\.appleLoginResponse.failure) {
      $0.isLoading = false
      $0.errorMessage = StubError.message
    }
  }

  @Test("에러 알림 해제 → errorMessage=nil")
  @MainActor
  func errorAlertDismissed_clearsMessage() async {
    var initialState = IntroFeature.State()
    initialState.errorMessage = "이전 에러"
    let store = TestStore(initialState: initialState) {
      IntroFeature()
    }

    await store.send(.errorAlertDismissed) {
      $0.errorMessage = nil
    }
  }

  // MARK: - Kakao Login

  @Test("Kakao 로그인 성공 → loginSucceeded=true, delegate(.loginSucceeded) 발송")
  @MainActor
  func kakaoLogin_success() async {
    let store = TestStore(initialState: IntroFeature.State()) {
      IntroFeature()
    } withDependencies: {
      $0.kakaoAuthClient.login = { "test-kakao-token" }
      $0.kakaoServerLoginClient.login = { _ in
        SocialLoginResponse(accessToken: "test-jwt", refreshToken: "test-refresh", id: 1)
      }
    }

    await store.send(.kakaoLoginButtonTapped) {
      $0.isLoading = true
    }
    await store.receive(\.kakaoLoginResponse.success) {
      $0.isLoading = false
      $0.loginSucceeded = true
    }
    await store.receive(\.delegate.loginSucceeded)
  }

  @Test("KakaoServerLoginClient 실패 → errorMessage 설정")
  @MainActor
  func kakaoLogin_serverFails() async {
    let store = TestStore(initialState: IntroFeature.State()) {
      IntroFeature()
    } withDependencies: {
      $0.kakaoAuthClient.login = { "test-kakao-token" }
      $0.kakaoServerLoginClient.login = { _ in throw StubError() }
    }

    await store.send(.kakaoLoginButtonTapped) {
      $0.isLoading = true
    }
    await store.receive(\.kakaoLoginResponse.failure) {
      $0.isLoading = false
      $0.errorMessage = StubError.message
    }
  }
}

// MARK: - Helpers

private struct StubError: LocalizedError {
  static let message = "테스트 에러"
  var errorDescription: String? { Self.message }
}
