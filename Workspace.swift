//
//  Workspace.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/12/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
  name: DoriManifest.projectName,
  projects: DoriLayer.allCases.map(\.projectPath)
)
