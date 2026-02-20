//
//  PartnerRequests.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/10/26.
//

import Foundation

// MARK: - Partner Request DTOs

public struct PartnerCreateRequest: Codable, Equatable, Sendable {
    public let name: String
    public let relationship: String
    public let nickname: String?
    public let ageGroup: String?
    public let gender: String?

    public init(
        name: String,
        relationship: String,
        nickname: String? = nil,
        ageGroup: String? = nil,
        gender: String? = nil
    ) {
        self.name = name
        self.relationship = relationship
        self.nickname = nickname
        self.ageGroup = ageGroup
        self.gender = gender
    }
}

public struct PartnerUpdateRequest: Codable, Equatable, Sendable {
    public let fromPartnerName: String
    public let fromRelationship: String
    public let toPartnerName: String
    public let toRelationship: String

    public init(
        fromPartnerName: String,
        fromRelationship: String,
        toPartnerName: String,
        toRelationship: String
    ) {
        self.fromPartnerName = fromPartnerName
        self.fromRelationship = fromRelationship
        self.toPartnerName = toPartnerName
        self.toRelationship = toRelationship
    }
}
