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
  private let logoutHandler: @Sendable () async -> Void

  public init(
    tokenStore: any AuthTokenStoring,
    logoutHandler: @escaping @Sendable () async -> Void = {}
  ) {
    self.tokenStore = tokenStore
    self.session = Session()
    self.logoutHandler = logoutHandler
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
    let token = tokenStore.load()

    if let accessToken = token.accessToken, !accessToken.isEmpty {
      print("🔑 accessToken: \(accessToken)")
      print("🔑 refreshToken: \(token.refreshToken)")
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
      guard let response = request.response,
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
    print("🔑 refreshToken: \(refreshToken)")
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

    // TCA 방식으로 강제 로그아웃 전파
    Task { @MainActor in
      await logoutHandler()
    }
  }
  
}

