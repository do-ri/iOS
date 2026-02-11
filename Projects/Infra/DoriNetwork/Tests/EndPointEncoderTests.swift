import XCTest
@testable import DoriNetwork

final class EndPointEncoderTests: XCTestCase {
  private struct StringQuery: Encodable {
    let keyword: String
    let page: String
  }

  private struct NonStringQuery: Encodable {
    let page: Int
  }

  func testEncode_whenAllValuesAreString_returnsDictionary() {
    let encoder = DefaultQueryEncoder()
    let query = StringQuery(keyword: "dori", page: "1")

    let encoded = encoder.encode(query)

    XCTAssertEqual(encoded["keyword"], "dori")
    XCTAssertEqual(encoded["page"], "1")
  }

  func testEncode_whenValueContainsNonString_returnsEmptyDictionary() {
    let encoder = DefaultQueryEncoder()
    let query = NonStringQuery(page: 1)

    let encoded = encoder.encode(query)

    XCTAssertTrue(encoded.isEmpty)
  }
}
