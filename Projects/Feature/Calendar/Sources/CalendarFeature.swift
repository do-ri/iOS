//
//  CalendarFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import ComposableArchitecture
import Foundation
import FeatureAddDori
import DoriCore

@Reducer
public struct CalendarFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable, Sendable {
    @Presents public var addDori: AddDoriFeature.State?

    public var currentMonth: Date
    public var selectedType: TransactionType = .judori
    public var calendarData: CalendarMonthlyData
    public var calendarDays: [CalendarDay] = []
    public var selectedDay: CalendarDay?
    public var dayDoris: [CalendarDori] = []
    public var errorMessage: String?

    public var totalAmount: Int {
      switch selectedType {
      case .judori:
        return calendarData.outDoriTotalAmount
      case .baddori:
        return calendarData.inDoriTotalAmount
      }
    }

    public init(currentMonth: Date = Date()) {
      self.currentMonth = currentMonth
      self.calendarData = .empty(for: currentMonth)
    }
  }

  public enum Action: Equatable, Sendable {
    case onAppear
    case fabTapped
    case addDori(PresentationAction<AddDoriFeature.Action>)
    case goToPreviousMonth
    case goToNextMonth
    case selectedTypeChanged(TransactionType)
    case calendarDataResponse(CalendarMonthlyData)
    case calendarDataFailed(String)
    case dayTapped(CalendarDay)
    case sheetDismissed
  }

  @Dependency(\.calendarClient) var calendarClient

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.errorMessage = nil
        return fetchMonthlyData(month: state.currentMonth, type: state.selectedType)
        
      case .fabTapped:
        state.addDori = AddDoriFeature.State()
        return .none

      case .addDori(.presented(.delegate(.doriCreated))):
        state.addDori = nil
        return .none

      case .addDori(.presented(.delegate(.dismissed))):
        state.addDori = nil
        return .none

      case .addDori(.dismiss):
        state.addDori = nil
        return .none

      case .addDori:
        return .none
        
      case .goToPreviousMonth:
        state.currentMonth = state.currentMonth.previousMonth
        state.selectedDay = nil
        state.dayDoris = []
        return fetchMonthlyData(month: state.currentMonth, type: state.selectedType)
        
      case .goToNextMonth:
        state.currentMonth = state.currentMonth.nextMonth
        state.selectedDay = nil
        state.dayDoris = []
        return fetchMonthlyData(month: state.currentMonth, type: state.selectedType)
        
      case let .selectedTypeChanged(type):
        state.selectedType = type
        state.selectedDay = nil
        state.dayDoris = []
        state.errorMessage = nil
        return fetchMonthlyData(month: state.currentMonth, type: state.selectedType)
        
      case let .calendarDataResponse(data):
        state.calendarData = data
        state.errorMessage = nil
        buildCalendarDays(state: &state)
        updateSelectedDayDoris(state: &state)
        return .none

      case let .calendarDataFailed(message):
        state.calendarData = .empty(for: state.currentMonth)
        state.errorMessage = message
        state.selectedDay = nil
        state.dayDoris = []
        buildCalendarDays(state: &state)
        return .none
        
      case let .dayTapped(day):
        guard day.isCurrentMonth, let date = day.date else { return .none }
        state.selectedDay = day
        state.dayDoris = currentTypeDoris(state: state).filter { $0.eventDate.isSameDay(as: date) }
        return .none
        
      case .sheetDismissed:
        state.selectedDay = nil
        state.dayDoris = []
        return .none
      }
    }
    .ifLet(\.$addDori, action: \.addDori) {
      AddDoriFeature()
    }
  }

  private func fetchMonthlyData(month: Date, type: TransactionType) -> Effect<Action> {
    let client = calendarClient
    return .run { send in
      do {
        let data = try await client.fetchMonthlyData(month, type)
        await send(.calendarDataResponse(data))
      } catch {
        await send(.calendarDataFailed(error.localizedDescription))
      }
    }
  }

  private func buildCalendarDays(state: inout State) {
    let currentMonth = state.currentMonth
    let transactionDaySet = Set(currentTypeDayList(state: state))

    let calendar = Calendar.current
    let startOfMonth = currentMonth.startOfMonth
    let firstWeekday = currentMonth.firstWeekdayOfMonth // 일=1, 월=2, ...
    let daysInMonth = currentMonth.daysInMonth
    let prefixCount = firstWeekday - 1

    // 이전달 정보
    let previousMonth = currentMonth.previousMonth
    let daysInPreviousMonth = previousMonth.daysInMonth

    var days: [CalendarDay] = []

    // 이전달 날짜 채우기
    for i in 0..<prefixCount {
      let day = daysInPreviousMonth - prefixCount + 1 + i
      let date = calendar.date(
        byAdding: .day,
        value: day - daysInPreviousMonth - 1,
        to: startOfMonth
      )
      days.append(
        CalendarDay(
          id: i,
          day: day,
          date: date,
          isCurrentMonth: false
        )
      )
    }

    // 현재달 날짜 채우기
    for day in 1...daysInMonth {
      let index = prefixCount + day - 1
      let date = calendar.date(
        byAdding: .day,
        value: day - 1,
        to: startOfMonth
      )
      days.append(
        CalendarDay(
          id: index,
          day: day,
          date: date,
          amount: nil,
          hasTransaction: transactionDaySet.contains(day),
          isCurrentMonth: true
        )
      )
    }

    // 다음달 날짜 채우기 (총 35칸 = 5줄)
    let remaining = 35 - days.count
    for i in 0..<remaining {
      let day = i + 1
      let date = calendar.date(
        byAdding: .day,
        value: i,
        to: currentMonth.nextMonth.startOfMonth
      )
      days.append(
        CalendarDay(
          id: prefixCount + daysInMonth + i,
          day: day,
          date: date,
          isCurrentMonth: false
        )
      )
    }

    state.calendarDays = days
  }

  private func updateSelectedDayDoris(state: inout State) {
    guard let selectedDay = state.selectedDay, let date = selectedDay.date else { return }
    state.dayDoris = currentTypeDoris(state: state).filter { $0.eventDate.isSameDay(as: date) }
  }

  private func currentTypeDayList(state: State) -> [Int] {
    switch state.selectedType {
    case .judori:
      return state.calendarData.outDoriDayList
    case .baddori:
      return state.calendarData.inDoriDayList
    }
  }

  private func currentTypeDoris(state: State) -> [CalendarDori] {
    switch state.selectedType {
    case .judori:
      return state.calendarData.outDoriList
    case .baddori:
      return state.calendarData.inDoriList
    }
  }
}
