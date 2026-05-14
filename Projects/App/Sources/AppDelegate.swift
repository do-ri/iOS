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
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    print("APNS Token: \"\(token)\"")
    FCMService.shared.setAPNSToken(deviceToken)
  }

  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("APNs 등록 실패: \(error.localizedDescription)")
  }
}
