//
//  EditDoriFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/23/26.
//

import Foundation
import ComposableArchitecture
import DoriCore
import DoriNetwork
import DoriDesignSystem

@Reducer
public struct EditDoriFeature {
  public init() {}

  // MARK: - State

  @ObservableState
  public struct State: Equatable, Sendable {
    public var dori: Dori

    public var transactionType: TransactionType
    public var selectedEventType: EventType
    public var customEventType: String

    public var amountInput: InputFieldFeature.State
    public var eventDate: Date
    public var isDatePickerVisible: Bool = false
    public var isVisited: Visited
    public var memo: String

    public var isSubmitting: Bool = false

    // MARK: - Computed

    public var resolvedEventType: String {
      if selectedEventType == .other {
        return customEventType.trimmingCharacters(in: .whitespaces)
      }
      return selectedEventType.rawValue
    }

    public var isFormValid: Bool {
      guard let amount = Int(amountInput.text), amount > 0 else { return false }
      let hasEventType = selectedEventType != .other || !customEventType.trimmingCharacters(in: .whitespaces).isEmpty
      return hasEventType && !amountInput.state.isError
    }

    // MARK: - Init

    public init(dori: Dori) {
      self.dori = dori

      self.transactionType = dori.direction

      let knownEventTypes = EventType.allCases.map(\.rawValue)
      if knownEventTypes.contains(dori.eventType) {
        self.selectedEventType = EventType(rawValue: dori.eventType) ?? .other
        self.customEventType = ""
      } else {
        self.selectedEventType = .other
        self.customEventType = dori.eventType
      }

      self.amountInput = InputFieldFeature.State(
        text: String(dori.amount),
        variant: .amount(maxAmount: 2_100_000_000),
        trailing: .unitAndClear(unitText: "원"),
        placeholder: "금액을 입력해주세요"
      )

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      self.eventDate = formatter.date(from: dori.eventDate) ?? .init()

      self.isVisited = dori.isVisited ? .yes : .no
      self.memo = dori.memo
    }
  }

  // MARK: - Action

  public enum Action: Equatable, Sendable {
    case transactionTypeChanged(TransactionType)
    case eventTypeSelected(EventType)
    case customEventTypeChanged(String)

    case amountInput(InputFieldFeature.Action)
    case addAmountTapped(Int)

    case datePickerToggled
    case eventDateChanged(Date)

    case isVisitedChanged(Visited)
    case memoChanged(String)

    case submitTapped
    case submitResponse(Result<Dori, SubmitError>)

    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case doriUpdated(Dori)
    }
  }

  public struct SubmitError: Error, Equatable, Sendable {
    public let message: String
    public init(message: String) { self.message = message }
  }

  static let maxAmount = Int(Int32.max)

  // MARK: - Dependencies

  @Dependency(\.historyAPIClient) var apiClient

  // MARK: - Reducer

  public var body: some ReducerOf<Self> {
    Scope(state: \.amountInput, action: \.amountInput) {
      InputFieldFeature()
    }

    Reduce { state, action in
      switch action {
      case let .transactionTypeChanged(type):
        state.transactionType = type
        return .none

      case let .eventTypeSelected(eventType):
        state.selectedEventType = eventType
        if eventType != .other {
          state.customEventType = ""
        }
        return .none

      case let .customEventTypeChanged(text):
        state.customEventType = String(text.prefix(10))
        return .none

      case .amountInput:
        return .none

      case let .addAmountTapped(amount):
        if state.amountInput.state.isError {
          return .none
        }

        let current = Int(state.amountInput.text) ?? 0
        let total = min(current + amount, Self.maxAmount)
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

      case .submitTapped:
        guard !state.isSubmitting else { return .none }
        state.isSubmitting = true

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let eventDateString = dateFormatter.string(from: state.eventDate)

        let request = DoriUpdateInput(
          direction: state.transactionType,
          eventType: state.resolvedEventType,
          amount: Int32(state.amountInput.text) ?? 0,
          eventDate: eventDateString,
          isVisited: state.isVisited.boolValue,
          memo: state.memo.isEmpty ? nil : state.memo
        )
        let doriId = state.dori.doriId
        let updateDori = apiClient.updateDori
        return .run { send in
          do {
            let response = try await updateDori(doriId, request)
            await send(.submitResponse(.success(response)))
          } catch {
            await send(.submitResponse(.failure(SubmitError(message: error.localizedDescription))))
          }
        }

      case let .submitResponse(.success(response)):
        state.isSubmitting = false
        return .send(.delegate(.doriUpdated(response)))

      case .submitResponse(.failure):
        state.isSubmitting = false
        return .none

      case .delegate:
        return .none
      }
    }
  }
}
