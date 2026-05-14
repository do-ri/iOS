//
//  AddDoriFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import Foundation
import ComposableArchitecture
import DoriCore
import DoriNetwork
import DoriDesignSystem
import UserNotifications

@Reducer
public struct AddDoriFeature {
  public init() {}

  // MARK: - State

  @ObservableState
  public struct State: Equatable, Sendable {
    public var currentPage: Int = 0

    // Page 1: 이름/구분
    public var transactionType: TransactionType = .judori
    public var searchQuery: String = ""
    public var searchResults: [Dori] = []
    public var selectedPartner: Dori? = nil
    public var isSearching: Bool = false

    // Page 2: 관계/경조사
    public var selectedRelationship: Relationship = .friend
    public var customRelationship: String = ""
    public var selectedEventType: EventType = .wedding
    public var customEventType: String = ""

    // Page 3: 금액/날짜
    public var amountInput = InputFieldFeature.State(
      variant: .amount(maxAmount: 2_100_000_000),
      trailing: .unitAndClear(unitText: "원"),
      placeholder: "금액을 입력해주세요"
    )
    public var eventDate: Date = .init()
    public var isDatePickerVisible: Bool = false
    public var isVisited: Visited = .yes
    public var memo: String = ""

    public var isSubmitting: Bool = false
    public var isNotificationSettingsAlertPresented: Bool = false
    public var pendingCreatedDori: Dori?

    // MARK: - Validation

    public var isPage1Valid: Bool {
      selectedPartner != nil || !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var isPage2Valid: Bool {
      let hasRelationship = (selectedRelationship != Relationship.other || !customRelationship.trimmingCharacters(in: .whitespaces).isEmpty)
      let hasEventType = (selectedEventType != EventType.other || !customEventType.trimmingCharacters(in: .whitespaces).isEmpty)

      print("hasRelationship: \(hasRelationship), hasEventType: \(hasEventType)")
      return hasRelationship && hasEventType
    }

    public var isPage3Valid: Bool {
      guard let amount = Int(amountInput.text) else { return false }
      return amount > 0 && !amountInput.state.isError
    }

    // MARK: - Computed

    public var partnerName: String {
      selectedPartner?.partnerName ?? searchQuery.trimmingCharacters(in: .whitespaces)
    }
    
    public var resolvedRelationship: String {
      if selectedRelationship == Relationship.other {
        return customRelationship.trimmingCharacters(in: .whitespaces)
      }
      return selectedRelationship.rawValue
    }

    public var resolvedEventType: String {
      if selectedEventType == EventType.other {
        return customEventType.trimmingCharacters(in: .whitespaces)
      }
      return selectedEventType.rawValue
    }

    // MARK: - Init

    public init() {}
  }

  // MARK: - Action

  public enum Action: Equatable, Sendable {
    // Navigation
    case nextPageTapped
    case previousPageTapped

    // Page 1
    case transactionTypeChanged(TransactionType)
    case searchQueryChanged(String)
    case searchResponse([Dori])
    case partnerSelected(Dori?)
    case clearSearchTapped

    // Page 2
    case relationshipSelected(Relationship)
    case customRelationshipChanged(String)
    case eventTypeSelected(EventType)
    case customEventTypeChanged(String)

    // Page 3
    case amountInput(InputFieldFeature.Action)
    case addAmountTapped(Int)
    case datePickerToggled
    case eventDateChanged(Date)
    case isVisitedChanged(Visited)
    case memoChanged(String)

    // Submit
    case submitTapped
    case submitResponse(Result<Dori, SubmitError>)
    case notificationAuthorizationStatusResponse(Bool, Dori)
    case notificationSettingsAlertDismissed

    // Delegate
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case doriCreated(Dori)
      case dismissed
    }
  }

  public struct SubmitError: Error, Equatable, Sendable {
    public let message: String

    public init(message: String) {
      self.message = message
    }
  }

  static let maxAmount = Int(Int32.max) // 2,147,483,647 (약 21.47억)

  private enum CancelID {
    case search
  }

  // MARK: - Dependencies

  @Dependency(\.continuousClock) var clock
  @Dependency(\.addDoriAPIClient) var apiClient
  @Dependency(\.userNotificationSettingsClient) var userNotificationSettingsClient

  // MARK: - Reducer

  public var body: some ReducerOf<Self> {
    Scope(state: \.amountInput, action: \.amountInput) {
      InputFieldFeature()
    }

    Reduce { state, action in
      switch action {
        // MARK: Navigation
      case .nextPageTapped:
        if state.currentPage < 2 {
          state.currentPage += 1
        }
        return .none

      case .previousPageTapped:
        if state.currentPage > 0 {
          state.currentPage -= 1
        }
        return .none

        // MARK: Page 1
      case let .transactionTypeChanged(type):
        state.transactionType = type
        return .none

      case let .searchQueryChanged(query):
        state.searchQuery = String(query.prefix(10))
        print("state.searchQuery: \(state.searchQuery)")
        state.selectedPartner = nil

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
          state.searchResults = []
          state.isSearching = false
          return .cancel(id: CancelID.search)
        }

        state.isSearching = true
        let searchPartners = apiClient.searchPartners
        let clock = self.clock
        return .run { send in
          try await clock.sleep(for: .milliseconds(300))
          let results = try await searchPartners(query)
          await send(.searchResponse(results))
        }
        .cancellable(
          id: CancelID.search,
          cancelInFlight: true
        )

      case let .searchResponse(results):
        state.searchResults = results
        state.isSearching = false
        return .none

      case let .partnerSelected(partner):
        state.selectedPartner = partner
        if let partner {
          state.searchQuery = partner.partnerName
          state.searchResults = []

          let knownRelationships = Relationship.allCases.map(\.rawValue)
          if knownRelationships.contains(partner.relationship) {
            state.selectedRelationship = Relationship(rawValue: partner.relationship) ?? .other
          } else {
            state.selectedRelationship = Relationship.other
            state.customRelationship = partner.relationship
          }
        }
        return .none

      case .clearSearchTapped:
        state.searchQuery = ""
        state.searchResults = []
        state.selectedPartner = nil
        return .cancel(id: CancelID.search)

        // MARK: Page 2
      case let .relationshipSelected(relationship):
        state.selectedRelationship = relationship
        if relationship != Relationship.other {
          state.customRelationship = ""
        }
        return .none

      case let .customRelationshipChanged(text):
        state.customRelationship = String(text.prefix(10))
        return .none

      case let .eventTypeSelected(eventType):
        state.selectedEventType = eventType
        if eventType != EventType.other {
          state.customEventType = ""
        }
        return .none

      case let .customEventTypeChanged(text):
        state.customEventType = String(text.prefix(10))
        return .none

        // MARK: Page 3
      case .amountInput:
        return .none

      case let .addAmountTapped(amount):
        if state.amountInput.state.isError {
          return .none
        }

        let current = Int(state.amountInput.text) ?? 0
        let effectiveMax = state.amountInput.variant.maxAmount ?? Self.maxAmount
        let total = min(current + amount, effectiveMax)
        return .send(.amountInput(.textChanged(String(total))))

      case .datePickerToggled:
        state.isDatePickerVisible.toggle()
        return .none

      case let .eventDateChanged(date):
        state.eventDate = date
        return .none

      case let .isVisitedChanged(visited):
        state.isVisited = visited
        return .none

      case let .memoChanged(text):
        state.memo = String(text.prefix(40))
        return .none

        // MARK: Submit
      case .submitTapped:
        guard !state.isSubmitting else { return .none }
        state.isSubmitting = true

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let eventDateString = dateFormatter.string(from: state.eventDate)

        let request = DoriPostInput(
          partnerId: nil,
          direction: state.transactionType,
          partnerName: state.partnerName,
          relationship: state.resolvedRelationship,
          eventType: state.resolvedEventType,
          amount: Int32(state.amountInput.text) ?? 0,
          eventDate: eventDateString,
          isVisited: state.isVisited.boolValue,
          memo: state.memo.isEmpty ? nil : state.memo
        )
        let createDori = apiClient.createDori
        return .run { send in
          do {
            let response = try await createDori(request)
            await send(.submitResponse(.success(response)))
          } catch {
            await send(.submitResponse(.failure(SubmitError(message: error.localizedDescription))))
          }
        }

      case let .submitResponse(.success(response)):
        state.isSubmitting = false
        let isNotificationEnabled = userNotificationSettingsClient.isNotificationEnabled
        return .run { send in
          let isEnabled = await isNotificationEnabled()
          await send(.notificationAuthorizationStatusResponse(isEnabled, response))
        }

      case .submitResponse(.failure):
        state.isSubmitting = false
        return .none

      case let .notificationAuthorizationStatusResponse(isEnabled, response):
        if isEnabled {
          return .send(.delegate(.doriCreated(response)))
        }

        state.pendingCreatedDori = response
        state.isNotificationSettingsAlertPresented = true
        return .none

      case .notificationSettingsAlertDismissed:
        state.isNotificationSettingsAlertPresented = false
        guard let createdDori = state.pendingCreatedDori else { return .none }
        state.pendingCreatedDori = nil
        return .send(.delegate(.doriCreated(createdDori)))

      case .delegate:
        return .none
      }
    }
  }
}

@DependencyClient
public struct UserNotificationSettingsClient: Sendable {
  public var isNotificationEnabled: @Sendable () async -> Bool = { true }
}

extension UserNotificationSettingsClient: DependencyKey {
  public static let liveValue = Self(
    isNotificationEnabled: {
      let settings = await UNUserNotificationCenter.current().notificationSettings()
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        return true
      case .notDetermined, .denied:
        return false
      @unknown default:
        return false
      }
    }
  )

  public static let testValue = Self(
    isNotificationEnabled: { true }
  )
}

public extension DependencyValues {
  var userNotificationSettingsClient: UserNotificationSettingsClient {
    get { self[UserNotificationSettingsClient.self] }
    set { self[UserNotificationSettingsClient.self] = newValue }
  }
}
