//
//  SuccessResponse.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/7/26.
//

import Foundation

// MARK: - API Error Response
public struct ApiErrorResponse: Codable, Equatable, Sendable {
    public let code: String
    public let message: String?

    public init(
        code: String,
        message: String? = nil
    ) {
        self.code = code
        self.message = message
    }
}

// MARK: - Generic Success Response
public struct SuccessResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let success: Bool
    public let data: T?
    public let error: ApiErrorResponse?
}

public struct EmptyResponse: Codable, Equatable, Sendable {
    public init() {}
}
