//
//  DayDetailSheet.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/17/26.
//

import SwiftUI
import DoriDesignSystem
import DoriCore

struct DayDetailSheet: View {
  let date: Date
  let doris: [CalendarDori]

  var body: some View {
    VStack(spacing: 24) {
      HStack {
        Text(date.koreanDateWithWeekday)
          .pretendard(.title(.t1))
        Spacer()
      }
      .padding(.horizontal, 4)
      .padding(.bottom, 4)
      
      ForEach(doris, id: \.self) { dori in
        CalendarDoriRow(dori: dori)
      }
      
      Spacer()
      
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 30)
    .background(.bgPrimary)
  }
}

#Preview {
  DayDetailSheet(
    date: Date(),
    doris: [
      CalendarDori(
        id: 1,
        type: .judori,
        partnerName: "김철수",
        relationship: "친구",
        eventType: "결혼",
        amount: 50000,
        eventDate: Date(),
        isVisited: true,
        memo: "축하합니다"
      ),
      CalendarDori(
        id: 2,
        type: .baddori,
        partnerName: "이영희",
        relationship: "동료",
        eventType: "생일",
        amount: 30000,
        eventDate: Date(),
        isVisited: false,
        memo: nil
      ),
    ]
  )
}

private struct CalendarDoriRow: View {
  private let dori: CalendarDori
  private let isChevronHidden: Bool

  public init(
    dori: CalendarDori,
    isChevronHidden: Bool = false
  ) {
    self.dori = dori
    self.isChevronHidden = isChevronHidden
  }

  private var isJudori: Bool {
    dori.type == .judori
  }

  private var eventIcon: UIAsset.Icons {
    let eventType = EventType(rawValue: dori.eventType)
    if isJudori {
      switch eventType {
      case .wedding: return .judoriWedding
      case .funeral: return .judoriFuneral
      case .firstBirthday: return .judoriFirstBirthday
      case .housewarming: return .judoriHousewarming
      case .birthday: return .judoriBirthday
      default: return .judoriEtc
      }
    } else {
      switch eventType {
      case .wedding: return .baddoriWedding
      case .funeral: return .baddoriFuneral
      case .firstBirthday: return .baddoriFirstBirthday
      case .housewarming: return .baddoriHousewarming
      case .birthday: return .baddoriBirthday
      default: return .baddoriEtc
      }
    }
  }

  public var body: some View {
    HStack {
      DoriCircleIcon(eventIcon, style: isJudori ? .judori : .baddori)

      VStack(spacing: 4) {
        HStack(spacing: 2) {
          Text(dori.partnerName)
            .pretendard(.body(.b4))
            .foregroundStyle(.textPrimary)

          Text(dori.relationship)
            .pretendard(.caption(.m2))
            .foregroundStyle(.textSecondary)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(
              RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(.bgSecondary)
            )

          Spacer()
        }
        
        HStack(spacing: 4) {
          Text(dori.eventType)
          
          if !(dori.memo ?? "").isEmpty {
            Rectangle()
              .frame(width: 1, height: 10)
            Text((dori.memo ?? ""))
          }
          
          Spacer()
        }
        .pretendard(.body(.r6))
        .foregroundStyle(.textSecondary)
      }
      

      Spacer()

      HStack(spacing: 8) {
        AmountLabel(Int(dori.amount))
          .pretendard(.body(.sb2))
          .foregroundStyle(.textPrimary)
      }
    }
    .padding(.vertical, 8)
  }

}

// MARK: - Preview

//#Preview {
//  VStack {
//    CalendarDoriRow(
//      dori: Dori(
//        doriId: 1,
//        userId: 1,
//        partnerId: 1,
//        direction: .judori,
//        partnerName: "홍길동",
//        relationship: "친구",
//        eventType: "설날 세뱃돈",
//        amount: 100_000,
//        eventDate: "2026-01-01",
//        isVisited: true,
//        memo: "조카에게",
//        createdAt: "2026-01-01"
//      )
//    )
//
//    CalendarDoriRow(
//      dori: Dori(
//        doriId: 2,
//        userId: 1,
//        partnerId: 1,
//        direction: .baddori,
//        partnerName: "홍길동",
//        relationship: "친구",
//        eventType: "생일 선물",
//        amount: 50_000,
//        eventDate: "2026-02-01",
//        isVisited: true,
//        memo: "",
//        createdAt: "2026-02-01"
//      )
//    )
//  }
//  .padding()
//}

import ComposableArchitecture

#Preview {
  CalendarView(
    store: Store(initialState: CalendarFeature.State()) {
      CalendarFeature()
    }
  )
}
