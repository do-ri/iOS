//
//  AppDelegate.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/25/26.
//

import UIKit
import PlatformFCM

final class AppDelegate: NSObject, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FCMService.shared.configure()
    return true
  }

  // MARK: - APNs Token

  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    FCMService.shared.setAPNSToken(deviceToken)
  }

  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    // 실제 기기에서만 APNs 등록 가능 — 시뮬레이터 실패는 무시
  }
}
