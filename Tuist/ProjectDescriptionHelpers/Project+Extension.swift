//
//  Project+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 강동영 on 2/13/26.
//

import ProjectDescription

public extension Project {
  static func dori(
    name: String = Environment.projectName,
    packages: [Package] = [],
    targets: [Target],
    resourceSynthesizers: [ResourceSynthesizer] = []
  ) -> Project {
    Project(
      name: name,
      organizationName: Environment.organizationName,
      packages: packages,
      settings: .settings(),
      targets: targets,
      resourceSynthesizers: resourceSynthesizers
    )
  }
}
