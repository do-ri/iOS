//
//  Project.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dori(
  name: DoriLayer.infra.projectName,
  targets: [
    .doriFramework(DoriModules.network.module),
    .doriUnitTests(DoriModules.network.module),
    .doriFramework(
      DoriModules.networkImpl.module,
      dependencies: [
        DoriModules.network.module.targetDependency,
        DoriDependency.alamofire,
      ]
    ),
  ]
)
