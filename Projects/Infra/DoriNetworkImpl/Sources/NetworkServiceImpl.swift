//
//  NetworkServiceImpl.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/7/26.
//

import Foundation
import Alamofire
import DoriNetwork

public final class NetworkServiceImpl: NetworkService {
  
  // MARK: - Properties
  private let session: Session
  private let decoder: JSONDecoder
  private let logger: NetworkLogable?
  
  public init(
    configuration: URLSessionConfiguration,
    logger: NetworkLogable? = nil,
    interceptor: RequestInterceptor? = nil
  ) {
    configuration.timeoutIntervalForRequest = 20
    self.session = Session(configuration: configuration, interceptor: interceptor)
    self.logger = logger
    self.decoder = JSONDecoder()
  }
  
  public func request<T: Decodable & Sendable>(_ endpoint: any Endpoint, responseType: T.Type) async throws -> T {
    do {
      let urlRequest = try endpoint.createURLRequest()
      
#if DEBUG
      logger?.requestLogger(request: urlRequest)
#endif
      
      let dataTask = session.request(urlRequest)
        .validate(statusCode: 200..<300)
        .serializingData()
      
      let response = await dataTask.response
      
      // 에러 체크
      if let error = response.error {
        print("❌ Network Error: \(error.localizedDescription)")
        throw mapAlamofireError(error)
      }
      
      guard let httpResponse = response.response else {
        throw NetworkError.invalidResponse
      }
      
      guard let data = response.data else {
        throw NetworkError.noData
      }
#if DEBUG
      self.logger?.responseLogger(response: httpResponse, data: data)
#endif
      
      let decodedData = try JSONDecoder().decode(T.self, from: data)
      
      return decodedData
    } catch let error as AFError {
      throw mapAlamofireError(error)
    } catch let error as DecodingError {
      throw mapError(error)
    } catch {
      throw mapError(error)
    }
  }
  
  // MARK: - Private Methods
  private func alamofireMethod(from httpMethod: DoriNetwork.HTTPMethod) -> Alamofire.HTTPMethod {
    switch httpMethod {
    case .GET:
      return .get
    case .POST:
      return .post
    case .PUT:
      return .put
    case .DELETE:
      return .delete
    case .PATCH:
      return .patch
    @unknown default:
      fatalError()
    }
  }
  
  private func alamofireHeaders(from headers: [String: String]?) -> Alamofire.HTTPHeaders? {
    guard let headers = headers else { return nil }
    return Alamofire.HTTPHeaders(headers)
  }
  
  private func mapAlamofireError(_ error: AFError) -> NetworkError {
    switch error {
    case .responseValidationFailed(let reason):
      switch reason {
      case .unacceptableStatusCode(let code):
        switch code {
        case 401:
          return .unauthorized
        case 403:
          return .forbidden
        case 404:
          return .notFound
        default:
          return .http(statusCode: code, message: "")
        }
      default:
        return .network(error)
      }
    case .responseSerializationFailed:
      return .decoding(error)
    default:
      return .network(error)
    }
  }
  
  private func mapError(_ error: Error) -> NetworkError {
    if let networkError = error as? NetworkError {
      return networkError
    } else if error is DecodingError {
      return NetworkError.decoding(error)
    } else if let afError = error as? AFError {
      return mapAlamofireError(afError)
    } else {
      return NetworkError.network(error)
    }
  }
}

