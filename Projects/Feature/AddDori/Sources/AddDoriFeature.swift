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

@Reducer
public struct AddDoriFeature {
  public init() {}
  
  // MARK: - Mode
  
  public enum Mode: Equatable, Sendable {
    case create
    case edit(DoriResponsesDTO)
  }
  
  // MARK: - State
  
  @ObservableState
  public struct State: Equatable, Sendable {
    public var mode: Mode
    public var currentPage: Int = 0
    
    // Page 1: 이름/구분
    public var transactionType: TransactionType = .given
    public var searchQuery: String = ""
    public var searchResults: [DoriResponsesDTO] = []
    public var selectedPartner: DoriResponsesDTO? = nil
    public var isSearching: Bool = false
    
    // Page 2: 관계/경조사
    public var selectedRelationship: Relationship = .friend
    public var customRelationship: String = ""
    public var selectedEventType: EventType = .wedding
    public var customEventType: String = ""
    
    // Page 3: 금액/날짜
    public var amountText: String = ""
    public var eventDate: Date = .init()
    public var isDatePickerVisible: Bool = false
    public var isVisited: Visited = .yes
    public var memo: String = ""
    
    public var isSubmitting: Bool = false
    
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
      let digits = amountText.filter(\.isNumber)
      guard let amount = Int(digits), amount > 0 else { return false }
      return isVisited.boolValue
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
    
    public var navigationTitle: String {
      switch mode {
      case .create: "내역 추가"
      case .edit: "내역 수정"
      }
    }
    
    // MARK: - Init
    
    public init(mode: Mode = .create) {
      self.mode = mode
      
      if case let .edit(dori) = mode {
        self.transactionType = dori.direction == TransactionType.given.rawValue ? .given : .received
        self.searchQuery = dori.partnerName
        
        let knownRelationships = Relationship.allCases.map(\.rawValue)
        if knownRelationships.contains(dori.relationship) {
          self.selectedRelationship = Relationship(rawValue: dori.relationship) ?? .other
        } else {
          self.selectedRelationship = Relationship.other
          self.customRelationship = dori.relationship
        }
        
        let knownEventTypes = EventType.allCases.map(\.rawValue)
        if knownEventTypes.contains(dori.eventType) {
          self.selectedEventType = EventType(rawValue: dori.eventType) ?? .other
        } else {
          self.selectedEventType = EventType.other
          self.customEventType = dori.eventType
        }
        
        self.amountText = Int(dori.amount).decimalFormatted
        self.isVisited = dori.isVisited ? .yes : .no
        self.memo = dori.memo
      }
    }
  }
  
  // MARK: - Action
  
  public enum Action: Equatable, Sendable {
    // Navigation
    case nextPageTapped
    case previousPageTapped
    
    // Page 1
    case transactionTypeChanged(TransactionType)
    case searchQueryChanged(String)
    case searchResponse([DoriResponsesDTO])
    case partnerSelected(DoriResponsesDTO?)
    case clearSearchTapped
    
    // Page 2
    case relationshipSelected(Relationship)
    case customRelationshipChanged(String)
    case eventTypeSelected(EventType)
    case customEventTypeChanged(String)
    
    // Page 3
    case amountTextChanged(String)
    case addAmountTapped(Int)
    case datePickerToggled
    case eventDateChanged(Date)
    case isVisitedChanged(Visited)
    case memoChanged(String)
    
    // Submit
    case submitTapped
    case submitResponse(Result<DoriResponsesDTO, SubmitError>)
    
    // Delegate
    case delegate(Delegate)
    
    public enum Delegate: Equatable, Sendable {
      case doriCreated(DoriResponsesDTO)
      case doriUpdated(DoriResponsesDTO)
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
  
  // MARK: - Reducer
  
  public var body: some ReducerOf<Self> {
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
      case let .amountTextChanged(text):
        let digits = text.filter(\.isNumber)
        if let amount = Int(digits), amount > 0 {
          let capped = min(amount, Self.maxAmount)
          state.amountText = capped.decimalFormatted
        } else {
          state.amountText = ""
        }
        return .none

      case let .addAmountTapped(amount):
        let current = Int(state.amountText.filter(\.isNumber)) ?? 0
        let total = min(current + amount, Self.maxAmount)
        state.amountText = total.decimalFormatted
        return .none
        
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
        
        switch state.mode {
        case .create:
          let request = DoriPostRequest(
            partnerId: 0,
            direction: state.transactionType.rawValue,
            partnerName: state.partnerName,
            relationship: state.resolvedRelationship,
            eventType: state.resolvedEventType,
            amount: Int32(state.amountText.filter(\.isNumber)) ?? 0,
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
          
        case let .edit(existing):
          let request = DoriUpdateRequest(
            direction: state.transactionType.rawValue,
            eventType: state.resolvedEventType,
            amount: Int32(state.amountText.filter(\.isNumber)) ?? 0,
            eventDate: eventDateString,
            isVisited: state.isVisited.boolValue,
            memo: state.memo.isEmpty ? nil : state.memo
          )
          let doriId = existing.doriId
          let updateDori = apiClient.updateDori
          return .run { send in
            do {
              let response = try await updateDori(
                doriId,
                request
              )
              await send(.submitResponse(.success(response)))
            } catch {
              await send(.submitResponse(.failure(SubmitError(message: error.localizedDescription))))
            }
          }
        }
        
      case let .submitResponse(.success(response)):
        state.isSubmitting = false
        switch state.mode {
        case .create:
          return .send(.delegate(.doriCreated(response)))
        case .edit:
          return .send(.delegate(.doriUpdated(response)))
        }
        
      case .submitResponse(.failure):
        state.isSubmitting = false
        return .none
        
      case .delegate:
        return .none
      }
    }
  }
}
