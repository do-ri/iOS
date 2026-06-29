//
//  Endpoint.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/7/26.
//

import Foundation

// MARK: - HTTP Method
public enum HTTPMethod: String, Sendable {
  case GET
  case POST
  case PUT
  case DELETE
  case PATCH
}

// MARK: - Parameters
public typealias Parameters = [String: any Sendable]

// MARK: - Base Endpoint Protocol
public protocol Endpoint: Sendable {
  var baseURL: String { get }
  var path: String { get }
  var method: HTTPMethod { get }
  var headers: [String: String] { get }
  var queryParameters: [String: String] { get }
  var queryEncoder: EndPointEncoder { get }
  var body: Data? { get }
}

public extension Endpoint {
  var queryEncoder: EndPointEncoder { DefaultQueryEncoder() }
  
  var defaultHeaders: [String: String] {
    [
      "Content-Type": "application/json",
      "accept": "application/json"
    ]
  }
  
  func createURL() -> URL? {
    var urlComponents = URLComponents(string: baseURL.appending(path))
    var queryItems = [URLQueryItem]()
    
    queryParameters.forEach {
      queryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
    }
    urlComponents?.queryItems = queryItems
    
    return urlComponents?.url
  }
  
  func createURLRequest() throws -> URLRequest {
    guard let url = createURL() else { throw NetworkError.invalidURL }
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    defaultHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0)}
    headers.forEach { request.setValue($1, forHTTPHeaderField: $0)}
    request.httpBody = body
    return request
  }
}
