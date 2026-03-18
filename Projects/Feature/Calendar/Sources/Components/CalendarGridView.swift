//
//  CalendarGridView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/5/26.
//

import SwiftUI
import DoriDesignSystem
import DoriCore

public struct CalendarGridView: View {
  let days: [CalendarDay]
  let selectedType: TransactionType
  let onDayTapped: (CalendarDay) -> Void

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
  private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

  public init(
    days: [CalendarDay],
    selectedType: TransactionType,
    onDayTapped: @escaping (CalendarDay) -> Void
  ) {
    self.days = days
    self.selectedType = selectedType
    self.onDayTapped = onDayTapped
  }

  public var body: some View {
    VStack(spacing: 0) {
      // 요일 헤더
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(weekdays, id: \.self) { weekday in
          Text(weekday)
            .pretendard(.regular(.r13))
            .foregroundStyle(.grey400)
            .padding(.bottom, 10)
        }
      }

      // 날짜 그리드 (최대 6줄, 42칸)
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(days) { calendarDay in
          CalendarDayCell(
            day: calendarDay,
            selectedType: selectedType
          )
          .allowsHitTesting(calendarDay.isSelectable)
          .onTapGesture {
            onDayTapped(calendarDay)
          }
        }
      }
    }
    .background(.doriWhite)
  }
}

struct CalendarDayCell: View {
  let day: CalendarDay
  let selectedType: TransactionType


  var textColor: UIAsset.Colors {
    if day.isCurrentMonth {
      if isToday { return .doriWhite }
      return .doriBlack
    } else {
      return .grey400
    }
  }
  
  var isTodayCircleColor: Color {
    guard isToday else { return .clear }
    return selectedType == .judori ? UIAsset.Colors.secondary.color : UIAsset.Colors.grey600.color
  }
  
  var dotColor: UIAsset.Colors {
    return selectedType == .judori ? .secondary : .grey600
  }
  
  var isToday: Bool {
    guard let day = day.date else {return false }
    return Date().isSameDay(as: day)
  }
  
  var body: some View {
    VStack(spacing: 7) {
      textContent

      dotContent
    }
    .frame(maxWidth: .infinity)
    .frame(height: 44)
    .padding(.top, 8)
    .padding(.bottom, 26)
    .contentShape(Rectangle())
    .background(alignment: .top, content: {
      Rectangle()
        .frame(height: 0.5)
        .foregroundStyle(.grey300)
    })
  }
  
  var textContent: some View {
    Text("\(day.day)")
      .pretendard(.medium(.m15))
      .foregroundStyle(textColor)
      .padding(8)
      .background(
        Circle()
          .fill(isTodayCircleColor)
      )
  }
  @ViewBuilder
  var dotContent: some View {
    if day.isCurrentMonth && day.hasTransaction {
      Circle()
        .fill(dotColor)
        .frame(width: 6, height: 6)
    } else {
      Circle()
        .fill(.clear)
        .frame(width: 6, height: 6)
    }
  }
}

#Preview {
  CalendarGridView(
    days: (0..<42).map { index in
      CalendarDay(
        id: index,
        day: index < 2 ? 29 + index : (index - 1 > 28 ? index - 29 : index - 1),
        hasTransaction: [5, 10, 15].contains(index),
        isCurrentMonth: index >= 2 && index <= 29
      )
    },
    selectedType: .judori,
    onDayTapped: { _ in }
  )
  .padding()
}
