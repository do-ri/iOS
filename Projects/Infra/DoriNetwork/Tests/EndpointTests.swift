import XCTest
@testable import DoriNetwork

final class EndpointTests: XCTestCase {
  private struct StubEndpoint: Endpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryParameters: [String: String]
    let body: Data?
  }

  func testCreateURL_includesPathAndQueryParameters() throws {
    let endpoint = StubEndpoint(
      baseURL: "https://api.example.com",
      path: "/v1/users",
      method: .GET,
      headers: [:],
      queryParameters: ["page": "1", "size": "20"],
      body: nil
    )

    let url = try XCTUnwrap(endpoint.createURL())
    let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
    let queryDictionary = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })

    XCTAssertEqual(components.scheme, "https")
    XCTAssertEqual(components.host, "api.example.com")
    XCTAssertEqual(components.path, "/v1/users")
    XCTAssertEqual(queryDictionary["page"], "1")
    XCTAssertEqual(queryDictionary["size"], "20")
  }

  func testCreateURLRequest_setsMethodHeadersAndBody() throws {
    let body = #"{"id":1}"#.data(using: .utf8)
    let endpoint = StubEndpoint(
      baseURL: "https://api.example.com",
      path: "/v1/users",
      method: .POST,
      headers: [
        "Authorization": "Bearer token",
        "Content-Type": "application/vnd.api+json",
      ],
      queryParameters: [:],
      body: body
    )

    let request = try endpoint.createURLRequest()

    XCTAssertEqual(request.httpMethod, HTTPMethod.POST.rawValue)
    XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/vnd.api+json")
    XCTAssertEqual(request.value(forHTTPHeaderField: "accept"), "application/json")
    XCTAssertEqual(request.httpBody, body)
  }

  func testCreateURLRequest_whenURLIsInvalid_throwsInvalidURL() {
    let endpoint = StubEndpoint(
      baseURL: "",
      path: "",
      method: .GET,
      headers: [:],
      queryParameters: [:],
      body: nil
    )

    XCTAssertThrowsError(try endpoint.createURLRequest()) { error in
      guard case NetworkError.invalidURL = error else {
        return XCTFail("Expected NetworkError.invalidURL, got \(error)")
      }
    }
  }
}
