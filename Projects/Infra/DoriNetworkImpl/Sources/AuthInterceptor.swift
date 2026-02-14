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
  private let maxRetryCount = 1
  private let coordinator = RefreshCoordinator()
  private let session: Session
  
  public init(tokenStore: any AuthTokenStoring) {
    self.tokenStore = tokenStore
    self.session = Session()
  }
  
  private actor RefreshCoordinator {
    private var refreshTask: Task<Bool, Never>?
    
    func refresh(with refreshTokens: @escaping @Sendable () async -> Bool) async -> Bool {
      if let existingTask = refreshTask {
        return await existingTask.value
      }
      
      let task = Task { @MainActor in
        await refreshTokens()
      }
      
      refreshTask = task
      let result = await task.value
      refreshTask = nil
      
      return result
    }
    
  }
  
  public func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping (Result<URLRequest, Error>) -> Void
  ) {
    var request = urlRequest
    let accessToken = tokenStore.load().accessToken
    
    if let accessToken, !accessToken.isEmpty {
      request.setValue(
        "Bearer \(accessToken)",
        forHTTPHeaderField: authorizationKey
      )
    }
    
    completion(.success(request))
  }
  
  public func retry(
    _ request: Request,
    for session: Session,
    dueTo error: any Error,
    completion: @escaping @Sendable (RetryResult) -> Void) {
      print(#function)
      guard let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401 else {
        completion(.doNotRetryWithError(error))
        return
      }
      
      guard request.retryCount < maxRetryCount else {
        print("⚠️ Max retry count reached. Logging out.")
        completion(.doNotRetry)
        handleLogout()
        return
      }
      
      Task { @MainActor in
        let success = await coordinator.refresh { [weak self] in
          guard let self = self else { return false }
          return await self.refreshTokens()
        }
        
        print("retry is success?: \(success)")
        if success {
          completion(.retry)
        } else {
          completion(.doNotRetry)
          handleLogout()
        }
      }
    }
  
  private func refreshTokens() async -> Bool {
    let tokens = tokenStore.load()
    guard let refreshToken = tokens.refreshToken else {
      return false
    }
    
    guard let request = try? RefreshEndpoint(refreshToken: refreshToken).createURLRequest() else {
      return false
    }
    
    do {
      let tokenResponse = try await session.request(request)
        .validate()
        .serializingDecodable(SuccessResponse<TokenRefreshResponse>.self)
        .value
      
      guard let tokenData = tokenResponse.data else {
        return false
      }
      
      try? tokenStore.save(
        accessToken: tokenData.accessToken,
        refreshToken: tokenData.refreshToken
      )
      
      return true
    } catch {
      return false
    }
  }
  
  private func handleLogout() {
    try? tokenStore.clear()
  }
  
}

