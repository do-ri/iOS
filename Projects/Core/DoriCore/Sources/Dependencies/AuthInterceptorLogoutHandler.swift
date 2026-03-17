//
//  AuthInterceptorLogoutHandler.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/26/26.
//

import Dependencies

extension DependencyValues {
  public var authInterceptorLogoutHandler: @Sendable () async -> Void {
    get { self[AuthInterceptorLogoutHandlerKey.self] }
    set { self[AuthInterceptorLogoutHandlerKey.self] = newValue }
  }
}

private enum AuthInterceptorLogoutHandlerKey: DependencyKey {
  public static let liveValue: @Sendable () async -> Void = {}
  public static let testValue: @Sendable () async -> Void = {}
}
