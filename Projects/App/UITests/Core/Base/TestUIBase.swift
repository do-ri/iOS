//
//  TestUIBase.swift
//  DoriAppUITests
//
//  Created by Codex on 4/27/26.
//

import XCTest

@MainActor
class TestUIBase: XCTestCase {
  let app = XCUIApplication()

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {
    app.terminate()
  }

  func waitForExistence(
    _ element: XCUIElement,
    timeout: TimeInterval = 5,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertTrue(element.waitForExistence(timeout: timeout), file: file, line: line)
  }
}
