//
//  TestIdentifier.swift
//  DoriAppUITests
//
//  Created by Codex on 4/27/26.
//

enum TestIdentifier {
  enum LaunchEnvironment {
    static let debugRoute = "DORI_DEBUG_ROUTE"
    static let notificationEnabled = "DORI_DEBUG_NOTIFICATION_ENABLED"
    static let partnerName = "DORI_DEBUG_PARTNER_NAME"
    static let amount = "DORI_DEBUG_AMOUNT"
  }

  enum DebugRoute {
    static let addDoriPage3 = "addDoriPage3"
  }

  enum AddDori {
    static let submitButton = "완료"
    static let notificationAlertTitle = "알림을 켜주세요"
    static let notificationAlertDescription = "도리 일정을 놓치지 않도록\n시스템 알림 설정을 켜주세요"
    static let openSettingsButton = "설정하기"
    static let laterButton = "나중에"
  }
}
