//
//  Target+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 강동영 on 2/13/26.
//

import ProjectDescription

public extension Target {
  static func doriFramework(
    _ module: DoriModule,
    dependencies: [TargetDependency] = [],
    hasResources: Bool = false
  ) -> Target {
    .target(
      name: module.name,
      destinations: .iOS,
      product: .framework,
      bundleId: "\(Environment.App.baseBundleId).\(module.name)",
      deploymentTargets: .iOS(Environment.deploymentTarget),
      sources: ["\(module.localPath)/Sources/**"],
      resources: hasResources ? ["\(module.localPath)/Resources/**"] : nil,
      dependencies: dependencies,
      settings: .frameworkSettings
    )
  }

  static func doriUnitTests(
    _ module: DoriModule,
    dependencies: [TargetDependency] = []
  ) -> Target {
    .target(
      name: "\(module.name)Tests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "\(Environment.App.baseBundleId).\(module.name)Tests",
      deploymentTargets: .iOS(Environment.deploymentTarget),
      sources: ["\(module.localPath)/Tests/**"],
      dependencies: [.target(name: module.name)] + dependencies,
      settings: .testSettings
    )
  }
  
  static func app(
    name: String,
    bundleId: String,
    infoPlist: InfoPlist? = .baseInfoPlist(),
    sources: SourceFilesList = ["Sources/**"],
    resources: ResourceFileElements = ["Resources/**"],
    dependencies: [TargetDependency] = [],
    settings: Settings? = .appSettings(),
    entitlements: Entitlements? = nil
  ) -> Target {
    .target(
      name: name,
      destinations: .iOS,
      product: .app,
      bundleId: bundleId,
      deploymentTargets: .iOS(Environment.deploymentTarget),
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      dependencies: dependencies,
      settings: settings
    )
  }
}
