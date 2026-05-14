//
//  UITestProtocols.swift
//  DoriAppUITests
//
//  Created by Codex on 4/27/26.
//

import XCTest

@MainActor
protocol UITestPage {
  var app: XCUIApplication { get }
}
