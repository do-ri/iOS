//
//  FCMClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/25/26.
//

import ComposableArchitecture

/// FCM 관련 기능을 TCA Dependency로 노출하는 클라이언트.
///
/// - `requestPermissionAndRegister`: APNs 권한 요청 + 원격 알림 등록
/// - `uploadFCMTokenToServer`: FCM 토큰을 서버에 전송하는 스텁 (API 연동 시 구현)
@DependencyClient
public struct FCMClient: Sendable {
  /// APNs 알림 권한을 요청하고 승인되면 원격 알림을 등록한다.
  public var requestPermissionAndRegister: @Sendable () async -> Void = {}

  /// FCM 토큰을 서버에 등록한다.
  ///
  /// - Note: 서버 FCM 토큰 등록 API 연동 전까지 빈 스텁으로 유지한다.
  ///         연동 시 `networkService.registerFCMToken(token)` 형태로 구현한다.
  public var uploadFCMTokenToServer: @Sendable (_ token: String) async throws -> Void = { _ in }
}

// MARK: - DependencyKey

extension FCMClient: DependencyKey {
  public static let liveValue = Self(
    requestPermissionAndRegister: {
      await FCMService.shared.requestAuthorization()
    },
    uploadFCMTokenToServer: { token in
      // TODO: 서버 FCM 토큰 등록 API 연동
      // 예시: try await networkService.registerFCMToken(token)
    }
  )

  public static let testValue = Self(
    requestPermissionAndRegister: {},
    uploadFCMTokenToServer: { _ in }
  )
}

// MARK: - DependencyValues

public extension DependencyValues {
  var fcmClient: FCMClient {
    get { self[FCMClient.self] }
    set { self[FCMClient.self] = newValue }
  }
}
