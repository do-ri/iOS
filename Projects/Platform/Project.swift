//
//  Project.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dori(
  name: DoriLayer.platform.projectName,
  targets: [
    .doriFramework(
      DoriModules.kakaoAuth.module,
      dependencies: [
        DoriDependency.composableArchitecture,
        DoriDependency.kakaoSDKCommon,
        DoriDependency.kakaoSDKAuth,
        DoriDependency.kakaoSDKUser,
      ]
    ),
    .doriFramework(
      DoriModules.keychain.module,
      dependencies: [
        DoriModules.network.module.projectDependency,
      ]
    ),
  ]
)
