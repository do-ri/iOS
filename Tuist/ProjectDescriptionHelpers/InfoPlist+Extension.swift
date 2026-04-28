//
//  InfoPlist+Extension.swift
//  Manifests
//
//  Created by 강동영 on 2/13/26.
//

import ProjectDescription

extension InfoPlist {
  static let commonDictionary: [String: Plist.Value] = [
    "UILaunchScreen": .dictionary([:]),
    "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
    "BASE_URL": "$(BASE_URL)",
    "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",
    "Appearance": "Light",
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "FirebaseAppDelegateProxyEnabled": .boolean(false),
    "FirebaseMessagingAutoInitEnabled": .boolean(true),
    "CFBundleURLTypes": [
      [
        "CFBundleTypeRole": "Editor",
        "CFBundleURLName": Plist.Value.string(Environment.App.baseBundleId),
        "CFBundleURLSchemes": ["$(KAKAO_CAllBACK)"],
      ],
    ],
    "LSApplicationQueriesSchemes": [
      "kakaokompassauth",
      "kakaolink",
    ],
  ]
    
  public static func baseInfoPlist() -> InfoPlist {
    return .extendingDefault(with: commonDictionary)
  }
}
