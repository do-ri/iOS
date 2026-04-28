//
//  Project.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dori(
  targets: [
    .app(
      name: "DoriApp",
      bundleId: Environment.App.baseBundleId,
      resources: [.glob(pattern: "Resources/**", excluding: ["Resources/info.plist", "Resources/*.entitlements"])],
      dependencies: [
        DoriModules.onboarding.module.projectDependency,
        DoriModules.addDori.module.projectDependency,
        DoriModules.calendar.module.projectDependency,
        DoriModules.history.module.projectDependency,
        DoriModules.myPage.module.projectDependency,
        DoriModules.network.module.projectDependency,
        DoriModules.networkImpl.module.projectDependency,
        DoriModules.kakaoAuth.module.projectDependency,
        DoriModules.keychain.module.projectDependency,
        DoriModules.fcm.module.projectDependency,
        DoriModules.designSystem.module.projectDependency,
        DoriModules.core.module.projectDependency,
        .external(.composableArchitecture)
      ],
      entitlements: .file(path: "Resources/DoriApp.entitlements")
    ),
    .target(
      name: "DoriAppUITests",
      destinations: .iOS,
      product: .uiTests,
      bundleId: "\(Environment.App.baseBundleId).UITests",
      deploymentTargets: .iOS(Environment.deploymentTarget),
      sources: ["UITests/**"],
      dependencies: [
        .target(name: "DoriApp")
      ],
      settings: .testSettings
    ),
  ]
)
