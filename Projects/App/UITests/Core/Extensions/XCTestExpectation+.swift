//
//  XCTestExpectation+.swift
//  DoriAppUITests
//
//  Created by Codex on 4/27/26.
//

import XCTest

extension XCTestCase {
  func waitBriefly(seconds: TimeInterval = 0.3) {
    let expectation = expectation(description: "brief wait")
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: seconds + 1)
  }
}
