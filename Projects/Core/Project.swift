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
    .doriFramework(DoriModules.core.module),
    .doriFramework(
      DoriModules.designSystem.module,
      dependencies: [
        DoriModules.core.module.targetDependency,
      ],
      hasResources: true
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
