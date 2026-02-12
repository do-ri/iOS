//
//  AuthInterceptor.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation
import Alamofire
import DoriNetwork

public final class AuthInterceptor: RequestInterceptor {
  private let authorizationKey = "Authorization"
  private let tokenStore: any AuthTokenStoring

  public init(tokenStore: any AuthTokenStoring) {
    self.tokenStore = tokenStore
  }

  public func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping (Result<URLRequest, Error>) -> Void
  ) {
    var request = urlRequest
    let accessToken = tokenStore.load().accessToken

    if let accessToken, !accessToken.isEmpty {
      request.setValue("Bearer \(accessToken)", forHTTPHeaderField: authorizationKey)
    }

    completion(.success(request))
  }

  public func retry(
    _ request: Request,
    for session: Session,
    dueTo error: any Error,
    completion: @escaping @Sendable (RetryResult) -> Void
  ) {
    completion(.doNotRetryWithError(error))
  }
}
