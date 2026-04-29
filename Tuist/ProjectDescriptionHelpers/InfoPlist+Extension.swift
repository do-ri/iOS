//
//  InfoPlist+Extension.swift
//  Manifests
//
//  Created by 강동영 on 2/13/26.
//

import ProjectDescription

extension InfoPlist {
  static var commonDictionary: [String: Plist.Value] {
    var dict: [String: Plist.Value] = [:]
    dict["UILaunchScreen"] = .dictionary([:])
    dict["CFBundleDisplayName"] = "$(APP_DISPLAY_NAME)"
    dict["CFBundleShortVersionString"] = "$(MARKETING_VERSION)"
    dict["CFBundleVersion"] = "$(CURRENT_PROJECT_VERSION)"
    dict["BASE_URL"] = "$(BASE_URL)"
    dict["KAKAO_NATIVE_APP_KEY"] = "$(KAKAO_NATIVE_APP_KEY)"
    dict["Appearance"] = "Light"
    dict["ITSAppUsesNonExemptEncryption"] = .boolean(false)
    dict["FirebaseAppDelegateProxyEnabled"] = .boolean(false)
    dict["FirebaseMessagingAutoInitEnabled"] = .boolean(true)
    dict["CFBundleURLTypes"] = .array([
      .dictionary([
        "CFBundleTypeRole": "Editor",
        "CFBundleURLName": .string(Environment.App.baseBundleId),
        "CFBundleURLSchemes": .array([.string("$(KAKAO_CAllBACK)")]),
      ]),
    ])
    dict["LSApplicationQueriesSchemes"] = .array([
      .string("kakaokompassauth"),
      .string("kakaolink"),
    ])
    dict["UISupportedInterfaceOrientations"] = .array([
      .string("UIInterfaceOrientationPortrait"),
    ])
    return dict
  }

  public static func baseInfoPlist() -> InfoPlist {
    return .extendingDefault(with: commonDictionary)
  }
}
