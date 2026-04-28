//
//  UIBaseAddDoriView.swift
//  DoriAppUITests
//
//  Created by Codex on 4/27/26.
//

import XCTest

@MainActor
final class UIBaseAddDoriView: UITestPage {
  let app: XCUIApplication

  init(app: XCUIApplication) {
    self.app = app
  }

  var submitButton: XCUIElement {
    app.buttons[TestIdentifier.AddDori.submitButton]
  }

  var notificationAlertTitle: XCUIElement {
    app.staticTexts[TestIdentifier.AddDori.notificationAlertTitle]
  }

  var notificationAlertDescription: XCUIElement {
    app.staticTexts[TestIdentifier.AddDori.notificationAlertDescription]
  }

  var openSettingsButton: XCUIElement {
    app.buttons[TestIdentifier.AddDori.openSettingsButton]
  }

  var laterButton: XCUIElement {
    app.buttons[TestIdentifier.AddDori.laterButton]
  }

  func submit() {
    submitButton.tap()
  }
}
