import XCTest
@testable import DoriNetwork

final class NetworkErrorTests: XCTestCase {
  func testErrorDescription_forHTTPErrorWithEmptyMessage() {
    let error = NetworkError.http(statusCode: 500, message: "")

    XCTAssertEqual(error.errorDescription, "HTTP 오류: 500")
  }

  func testErrorDescription_forHTTPErrorWithMessage() {
    let error = NetworkError.http(statusCode: 400, message: "bad request")

    XCTAssertEqual(error.errorDescription, "HTTP 오류 (400): bad request")
  }

  func testErrorDescription_forNetworkErrorIncludesLocalizedDescription() {
    let underlying = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "offline"])
    let error = NetworkError.network(underlying)

    XCTAssertEqual(error.errorDescription, "네트워크 오류: offline")
  }
}
