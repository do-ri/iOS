//
//  Project.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dori(
  name: DoriLayer.core.projectName,
  targets: [
    .doriFramework(
      DoriModules.core.module,
      dependencies: [
        .external(.composableArchitecture),
      ]
    ),
    .doriFramework(
      DoriModules.designSystem.module,
      dependencies: [
        DoriModules.core.module.targetDependency,
      ],
      hasResources: true
    ),
    .doriUnitTests(
      DoriModules.designSystem.module,
      dependencies: [
        .external(.composableArchitecture),
        .external(.snapshotTesting),
      ]
    ),
  ],
  resourceSynthesizers: [
    .custom(
      name: "Assets",
      parser: .assets,
      extensions: ["xcassets"]
    ),
  ]
)
