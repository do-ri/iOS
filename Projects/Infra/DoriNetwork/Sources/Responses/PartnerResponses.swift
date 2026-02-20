//
//  PartnerResponses.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/10/26.
//

import Foundation

// MARK: - Partner Response DTOs

public struct PartnerDetailResponse: Codable, Equatable, Sendable {
    public let partnerId: Int64
    public let userId: Int64
    public let name: String
    public let relationship: String
    public let nickname: String?
    public let ageGroup: String?
    public let gender: String?
    public let createdAt: String

    public init(
        partnerId: Int64,
        userId: Int64,
        name: String,
        relationship: String,
        nickname: String? = nil,
        ageGroup: String? = nil,
        gender: String? = nil,
        createdAt: String
    ) {
        self.partnerId = partnerId
        self.userId = userId
        self.name = name
        self.relationship = relationship
        self.nickname = nickname
        self.ageGroup = ageGroup
        self.gender = gender
        self.createdAt = createdAt
    }
}

public struct PartnerUpdateResponse: Codable, Equatable, Sendable {
    public let updatedCount: Int32

    public init(updatedCount: Int32) {
        self.updatedCount = updatedCount
    }
}

public struct PartnerExistsResponse: Codable, Equatable, Sendable {
    public let exists: Bool

    public init(exists: Bool) {
        self.exists = exists
    }
}
