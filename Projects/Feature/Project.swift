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
    .doriUnitTests(
      DoriModules.onboarding.module,
      dependencies: [
        DoriModules.testSupport.module.projectDependency,
        .external(.composableArchitecture),
        .external(.snapshotTesting),
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
    .doriUnitTests(
      DoriModules.addDori.module,
      dependencies: [
        DoriModules.testSupport.module.projectDependency,
        .external(.composableArchitecture),
        .external(.snapshotTesting),
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
    .doriUnitTests(
      DoriModules.calendar.module,
      dependencies: [
        DoriModules.testSupport.module.projectDependency,
        .external(.composableArchitecture),
        .external(.snapshotTesting),
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
    .doriUnitTests(
      DoriModules.history.module,
      dependencies: [
        DoriModules.testSupport.module.projectDependency,
        .external(.composableArchitecture),
        .external(.snapshotTesting),
      ]
    ),
    .doriFramework(
      DoriModules.myPage.module,
      dependencies: [
        DoriModules.designSystem.module.projectDependency,
        DoriModules.network.module.projectDependency,
        DoriModules.keychain.module.projectDependency,
        DoriModules.core.module.projectDependency,
        .external(.composableArchitecture)
      ]
    ),
    .doriUnitTests(
      DoriModules.myPage.module,
      dependencies: [
        DoriModules.testSupport.module.projectDependency,
        .external(.composableArchitecture),
        .external(.snapshotTesting),
      ]
    ),
  ]
)
