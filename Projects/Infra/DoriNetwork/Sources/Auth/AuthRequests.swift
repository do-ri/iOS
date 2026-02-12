//
//  AuthRequests.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation

public struct KakaoLoginRequest: Codable, Equatable, Sendable {
  public let accessToken: String

  public init(accessToken: String) {
    self.accessToken = accessToken
  }
}
