//
//  Date+Extensions.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import Foundation

public extension Date {
  private static let koreanLocale = Locale(identifier: "ko_KR")
  private static let koreanCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = koreanLocale
    return calendar
  }()

  // "12월 12일(금)" 형식
  var koreanDateWithWeekday: String {
    let formatter = DateFormatter()
    formatter.locale = Self.koreanLocale
    formatter.dateFormat = "M월 d일(E)"
    return formatter.string(from: self)
  }

  // "2024년 12월" 형식
  var koreanYearMonth: String {
    let formatter = DateFormatter()
    formatter.locale = Self.koreanLocale
    formatter.dateFormat = "yyyy년 M월"
    return formatter.string(from: self)
  }

  // "12월" 형식
  var koreanMonth: String {
    let formatter = DateFormatter()
    formatter.locale = Self.koreanLocale
    formatter.dateFormat = "M월"
    return formatter.string(from: self)
  }

  // 해당 월의 첫째 날
  var startOfMonth: Date {
    Self.koreanCalendar.date(from: Self.koreanCalendar.dateComponents([.year, .month], from: self)) ?? self
  }

  // 해당 월의 마지막 날
  var endOfMonth: Date {
    Self.koreanCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? self
  }

  // 해당 월의 일 수
  var daysInMonth: Int {
    Self.koreanCalendar.range(of: .day, in: .month, for: self)?.count ?? 30
  }

  // 해당 월 1일의 요일 (일요일 = 1)
  var firstWeekdayOfMonth: Int {
    Self.koreanCalendar.component(.weekday, from: startOfMonth)
  }

  // 해당 날짜의 일(day)
  var day: Int {
    Self.koreanCalendar.component(.day, from: self)
  }

  // 해당 날짜의 월(month)
  var month: Int {
    Self.koreanCalendar.component(.month, from: self)
  }

  // 해당 날짜의 연(year)
  var year: Int {
    Self.koreanCalendar.component(.year, from: self)
  }

  // 이전 달
  var previousMonth: Date {
    Self.koreanCalendar.date(byAdding: .month, value: -1, to: self) ?? self
  }

  // 다음 달
  var nextMonth: Date {
    Self.koreanCalendar.date(byAdding: .month, value: 1, to: self) ?? self
  }

  // 같은 날인지 확인
  func isSameDay(as other: Date) -> Bool {
    Self.koreanCalendar.isDate(self, inSameDayAs: other)
  }

  // 같은 달인지 확인
  func isSameMonth(as other: Date) -> Bool {
    Self.koreanCalendar.isDate(self, equalTo: other, toGranularity: .month)
  }
}
