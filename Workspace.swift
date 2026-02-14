//
//  Workspace.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
  name: Environment.projectName,
  projects: DoriLayer.allCases.map(\.projectPath)
)
