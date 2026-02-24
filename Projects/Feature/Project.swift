//
//  Project.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dori(
  name: DoriLayer.feature.projectName,
  targets: [
    .doriFramework(
      DoriModules.onboarding.module,
      dependencies: [
        DoriModules.designSystem.module.projectDependency,
        DoriModules.core.module.projectDependency,
        DoriModules.network.module.projectDependency,
        DoriModules.kakaoAuth.module.projectDependency,
        .external(.composableArchitecture)
      ]
    ),
    .doriFramework(
      DoriModules.addDori.module,
      dependencies: [
        DoriModules.designSystem.module.projectDependency,
        DoriModules.core.module.projectDependency,
        DoriModules.network.module.projectDependency,
        .external(.composableArchitecture)
      ]
    ),
    .doriFramework(
      DoriModules.calendar.module,
      dependencies: [
        DoriModules.addDori.module.targetDependency,
        DoriModules.designSystem.module.projectDependency,
        DoriModules.core.module.projectDependency,
        DoriModules.network.module.projectDependency,
        .external(.composableArchitecture)
      ]
    ),
    .doriFramework(
      DoriModules.history.module,
      dependencies: [
        DoriModules.addDori.module.targetDependency,
        DoriModules.designSystem.module.projectDependency,
        DoriModules.core.module.projectDependency,
        DoriModules.network.module.projectDependency,
        .external(.composableArchitecture)
      ]
    ),
    .doriFramework(
      DoriModules.myPage.module,
      dependencies: [
        DoriModules.designSystem.module.projectDependency,
        DoriModules.network.module.projectDependency,
        .external(.composableArchitecture)
      ]
    ),
  ]
)
