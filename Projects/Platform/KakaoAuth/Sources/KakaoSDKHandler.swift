//
//  KakaoSDKHandler.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKCommon

public enum KakaoSDKHandler {
  public static func initializeFromMainBundle(infoKey: String = "KAKAO_NATIVE_APP_KEY") {
    guard
      let appKey = Bundle.main.object(forInfoDictionaryKey: infoKey) as? String,
      !appKey.isEmpty
    else {
      assertionFailure("\(infoKey) is missing in Info.plist")
      return
    }

    KakaoSDK.initSDK(appKey: appKey)
  }

  @MainActor @discardableResult
  public static func handleOpenURL(_ url: URL) -> Bool {
    guard AuthApi.isKakaoTalkLoginUrl(url) else { return false }
    return AuthController.handleOpenUrl(url: url)
  }
}
