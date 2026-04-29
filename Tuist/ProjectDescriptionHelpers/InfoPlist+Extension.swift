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
    "BASE_URL": "$(BASE_URL)",
    "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",
    "Appearance": "Light",
    "UISupportedInterfaceOrientations": [
      "UIInterfaceOrientationPortrait"
    ],
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "CFBundleURLTypes": [
      [
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
