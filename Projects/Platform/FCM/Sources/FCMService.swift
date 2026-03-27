//
//  FCMService.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/25/26.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

/// Firebase Cloud Messaging 전담 서비스 객체.
///
/// 역할:
/// - Firebase 초기화
/// - APNs 권한 요청 및 원격 알림 등록
/// - FCM 토큰 수신 후 `tokenRefreshHandler` 를 통해 외부(서버 업로드 등)로 전달
@MainActor
public final class FCMService: NSObject {

  public static let shared = FCMService()

  /// FCM 토큰이 새로 발급/갱신됐을 때 호출되는 핸들러.
  /// 서버 FCM 토큰 등록 API 연동 시 이 핸들러에 구현체를 주입한다.
  public var tokenRefreshHandler: ((_ token: String) async -> Void)?

  private override init() {
    super.init()
  }

  // MARK: - Setup

  /// Firebase를 초기화하고 Messaging / UNUserNotificationCenter 델리게이트를 설정한다.
  /// `AppDelegate.application(_:didFinishLaunchingWithOptions:)` 에서 호출한다.
  public func configure() {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
  }

  // MARK: - Authorization

  /// APNs 알림 권한을 요청하고 승인된 경우 원격 알림을 등록한다.
  public func requestAuthorization() async {
    do {
      let granted = try await UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .badge, .sound])
      guard granted else { return }
      UIApplication.shared.registerForRemoteNotifications()
    } catch {
      // 권한 거부 또는 시스템 오류 — 조용히 처리
    }
  }

  // MARK: - APNs Token

  /// AppDelegate로부터 APNs 디바이스 토큰을 전달받아 Firebase Messaging에 등록한다.
  public func setAPNSToken(_ deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}

// MARK: - MessagingDelegate

extension FCMService: MessagingDelegate {
  /// FCM 토큰이 새로 발급되거나 갱신될 때 호출된다.
  public nonisolated func messaging(
    _ messaging: Messaging,
    didReceiveRegistrationToken fcmToken: String?
  ) {
    guard let token = fcmToken else { return }
    Task { @MainActor [weak self] in
      await self?.tokenRefreshHandler?(token)
    }
  }
}

// MARK: - UNUserNotificationCenterDelegate

extension FCMService: UNUserNotificationCenterDelegate {
  /// 앱이 포그라운드 상태일 때 수신된 알림을 배너·사운드·뱃지로 표시한다.
  public nonisolated func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    return [.banner, .sound, .badge]
  }
}
