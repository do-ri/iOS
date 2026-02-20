//
//  DoriRequests.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/10/26.
//

import Foundation

// MARK: - Dori Request DTOs
public struct DoriPostRequest: Codable, Equatable, Sendable {
    public let partnerId: Int64
    public let direction: String
    public let partnerName: String
    public let relationship: String
    public let eventType: String
    public let amount: Int32
    public let eventDate: String
    public let isVisited: Bool
    public let memo: String?

    public init(
        partnerId: Int64,
        direction: String,
        partnerName: String,
        relationship: String,
        eventType: String,
        amount: Int32,
        eventDate: String,
        isVisited: Bool,
        memo: String? = nil
    ) {
        self.partnerId = partnerId
        self.direction = direction
        self.partnerName = partnerName
        self.relationship = relationship
        self.eventType = eventType
        self.amount = amount
        self.eventDate = eventDate
        self.isVisited = isVisited
        self.memo = memo
    }
}

public struct DoriUpdateRequest: Codable, Equatable, Sendable {
    public let direction: String?
    public let eventType: String?
    public let amount: Int32?
    public let eventDate: String?
    public let isVisited: Bool?
    public let memo: String?

    public init(
        direction: String? = nil,
        eventType: String? = nil,
        amount: Int32? = nil,
        eventDate: String? = nil,
        isVisited: Bool? = nil,
        memo: String? = nil
    ) {
        self.direction = direction
        self.eventType = eventType
        self.amount = amount
        self.eventDate = eventDate
        self.isVisited = isVisited
        self.memo = memo
    }
}
