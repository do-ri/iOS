import ProjectDescription

let deploymentTarget: DeploymentTargets = .iOS("17.6")

let commonSettings: SettingsDictionary = [
    "SWIFT_VERSION": "6.0",
    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
]

func framework(
    name: String,
    path: String,
    dependencies: [TargetDependency] = [],
    hasResources: Bool = false
) -> Target {
    .target(
        name: name,
        destinations: .iOS,
        product: .staticFramework,
        bundleId: "com.arex.dori.\(name)",
        deploymentTargets: deploymentTarget,
        sources: ["\(path)/Sources/**"],
        resources: hasResources ? ["\(path)/Resources/**"] : nil,
        dependencies: dependencies,
        settings: .settings(base: commonSettings)
    )
}

let project = Project(
    name: "Dori-iOS",
    organizationName: "com.arex",
    settings: .settings(base: commonSettings),
    targets: [
        // App
        .target(
            name: "DoriApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.arex.dori",
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
                "BASE_URL": "$(BASE_URL)",
                "Appearance": "Light",
            ]),
            sources: ["Projects/App/Sources/**"],
            resources: ["Projects/App/Resources/**"],
            dependencies: [
                .target(name: "FeatureOnboarding"),
                .target(name: "DoriNetworkImpl"),
                .target(name: "DoriDesignSystem"),
                .target(name: "DoriCore"),
            ],
            settings: .settings(
                base: commonSettings,
                configurations: [
                    .debug(name: "Debug", xcconfig: "Projects/App/Resources/Common.xcconfig"),
                    .release(name: "Release", xcconfig: "Projects/App/Resources/Common.xcconfig"),
                ]
            )
        ),

        // Core
        framework(name: "DoriCore", path: "Projects/Core/DoriCore"),
        framework(name: "DoriDesignSystem", path: "Projects/Core/DoriDesignSystem",
                  dependencies: [.target(name: "DoriCore")],
                  hasResources: true),

        // Infra
        framework(name: "DoriNetwork", path: "Projects/Infra/DoriNetwork"),
        framework(name: "DoriNetworkImpl", path: "Projects/Infra/DoriNetworkImpl",
                  dependencies: [
                      .target(name: "DoriNetwork"),
                      .external(name: "Alamofire"),
                  ]),

        // Feature
        framework(name: "FeatureOnboarding", path: "Projects/Feature/Onboarding",
                  dependencies: [.target(name: "DoriDesignSystem"), .target(name: "DoriCore")],
                  hasResources: true),
    ]
)
