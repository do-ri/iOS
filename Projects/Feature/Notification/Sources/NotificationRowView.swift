//
//  NotificationRowView.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/11/26.
//

import SwiftUI
import DoriDesignSystem
import DoriNetwork

struct NotificationRowView: View {
  let item: NotificationItemResponse

  private var isUnread: Bool { item.readAt == nil }

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      // 읽지 않은 알림 표시 점
      Circle()
        .fill(isUnread ? UIAsset.Colors.brandMain.color : Color.clear)
        .frame(width: 6, height: 6)
        .padding(.top, 6)

      VStack(alignment: .leading, spacing: 4) {
        Text(item.title)
          .pretendard(.body(.sb3))
          .foregroundStyle(.textPrimary)

        Text(item.body)
          .pretendard(.body(.r4))
          .foregroundStyle(.textSecondary)
          .fixedSize(horizontal: false, vertical: true)

        Text(NotificationDateFormatter.displayString(from: item.pushedAt))
          .pretendard(.caption(.m2))
          .foregroundStyle(.textDisabled)
          .padding(.top, 2)
      }

      Spacer(minLength: 0)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.bgPrimary)
  }
}

// MARK: - Date Formatting

/// 서버 타임스탬프("2026-05-26T14:00:26.794863464")를 표시용 문자열로 변환.
/// 소수초 자리수가 표준(밀리초)을 넘어 `ISO8601DateFormatter` 가 실패할 수 있으므로
/// 소수초/타임존을 잘라낸 뒤 고정 포맷으로 파싱한다.
enum NotificationDateFormatter {
  private static let parser: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return formatter
  }()

  private static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "a h:mm"
    return formatter
  }()

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "M월 d일"
    return formatter
  }()

  static func displayString(from raw: String, now: Date = Date()) -> String {
    guard let date = parse(raw) else { return "" }
    if Calendar.current.isDate(date, inSameDayAs: now) {
      return timeFormatter.string(from: date)
    }
    return dateFormatter.string(from: date)
  }

  private static func parse(_ raw: String) -> Date? {
    // 소수초("." 이후)와 타임존 표기를 잘라낸 "yyyy-MM-dd'T'HH:mm:ss" 부분만 사용
    let trimmed = String(raw.prefix(19))
    return parser.date(from: trimmed)
  }
}
