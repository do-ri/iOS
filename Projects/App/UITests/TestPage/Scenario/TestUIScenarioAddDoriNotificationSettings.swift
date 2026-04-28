//
//  TestUIScenarioAddDoriNotificationSettings.swift
//  DoriAppUITests
//
//  Created by Codex on 4/27/26.
//

import XCTest

final class TestUIScenarioAddDoriNotificationSettings: TestUIBase {
  func testShowNotificationSettingsAlertWhenSystemNotificationIsOffAfterAddingDori() {
    app.launchEnvironment[TestIdentifier.LaunchEnvironment.debugRoute] = TestIdentifier.DebugRoute.addDoriPage3
    app.launchEnvironment[TestIdentifier.LaunchEnvironment.notificationEnabled] = "false"
    app.launchEnvironment[TestIdentifier.LaunchEnvironment.partnerName] = "김철수"
    app.launchEnvironment[TestIdentifier.LaunchEnvironment.amount] = "100000"
    app.launch()

    let addDoriView = UIBaseAddDoriView(app: app)

    waitForExistence(addDoriView.submitButton)
    addDoriView.submit()

    waitForExistence(addDoriView.notificationAlertTitle)
    waitForExistence(addDoriView.notificationAlertDescription)
    waitForExistence(addDoriView.openSettingsButton)
    waitForExistence(addDoriView.laterButton)

    addDoriView.laterButton.tap()
    waitBriefly()

    XCTAssertFalse(addDoriView.notificationAlertTitle.exists)
  }
}
