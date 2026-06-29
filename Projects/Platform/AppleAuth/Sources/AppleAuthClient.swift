//
//  AppleAuthClient.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/25/26.
//

import Foundation
import UIKit
import AuthenticationServices
import ComposableArchitecture

public struct AppleAuthCredential: Equatable, Sendable {
  public let identityToken: String
  public let firstName: String?
  public let lastName: String?
  public let email: String?

  public init(
    identityToken: String,
    firstName: String? = nil,
    lastName: String? = nil,
    email: String? = nil
  ) {
    self.identityToken = identityToken
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
  }
}

public struct AppleAuthClient: Sendable {
  public var login: @Sendable () async throws -> AppleAuthCredential

  public init(login: @escaping @Sendable () async throws -> AppleAuthCredential) {
    self.login = login
  }
}

private enum AppleAuthClientError: LocalizedError {
  case missingIdentityToken
  case invalidIdentityTokenEncoding

  var errorDescription: String? {
    switch self {
    case .missingIdentityToken:
      return "Apple 인증 토큰을 가져올 수 없습니다."
    case .invalidIdentityTokenEncoding:
      return "Apple 인증 토큰을 해석할 수 없습니다."
    }
  }
}

extension AppleAuthClient: DependencyKey {
  public static let liveValue = Self(
    login: {
      try await loginWithAppleID()
    }
  )

  public static let testValue = Self(
    login: {
      AppleAuthCredential(
        identityToken: "test-identity-token",
        firstName: "길동",
        lastName: "홍",
        email: "test@example.com"
      )
    }
  )

  @MainActor
  private static func loginWithAppleID() async throws -> AppleAuthCredential {
    try await withCheckedThrowingContinuation { continuation in
      let provider = ASAuthorizationAppleIDProvider()
      let request = provider.createRequest()
      request.requestedScopes = [.fullName, .email]

      let controller = ASAuthorizationController(authorizationRequests: [request])
      let delegate = AppleAuthControllerDelegate(continuation: continuation)
      controller.delegate = delegate
      controller.presentationContextProvider = delegate
      delegate.retain()
      controller.performRequests()
    }
  }
}

@MainActor
private final class AppleAuthControllerDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private var continuation: CheckedContinuation<AppleAuthCredential, Error>?
  private var retainedSelf: AppleAuthControllerDelegate?

  init(continuation: CheckedContinuation<AppleAuthCredential, Error>) {
    self.continuation = continuation
  }

  func retain() {
    retainedSelf = self
  }

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    defer { retainedSelf = nil }

    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
      continuation?.resume(throwing: AppleAuthClientError.missingIdentityToken)
      continuation = nil
      return
    }

    guard let tokenData = credential.identityToken else {
      continuation?.resume(throwing: AppleAuthClientError.missingIdentityToken)
      continuation = nil
      return
    }

    guard let identityToken = String(data: tokenData, encoding: .utf8) else {
      continuation?.resume(throwing: AppleAuthClientError.invalidIdentityTokenEncoding)
      continuation = nil
      return
    }

    let result = AppleAuthCredential(
      identityToken: identityToken,
      firstName: credential.fullName?.givenName,
      lastName: credential.fullName?.familyName,
      email: credential.email
    )
    continuation?.resume(returning: result)
    continuation = nil
  }

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    defer { retainedSelf = nil }
    continuation?.resume(throwing: error)
    continuation = nil
  }

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    return keyWindow ?? ASPresentationAnchor()
  }
}

public extension DependencyValues {
  var appleAuthClient: AppleAuthClient {
    get { self[AppleAuthClient.self] }
    set { self[AppleAuthClient.self] = newValue }
  }
}
