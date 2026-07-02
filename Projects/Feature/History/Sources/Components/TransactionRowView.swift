//
//  TransactionRowView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import SwiftUI
import DoriDesignSystem
import DoriCore

public struct TransactionRowView: View {
  private let dori: Dori
  private let isChevronHidden: Bool

  public init(
    dori: Dori,
    isChevronHidden: Bool = false
  ) {
    self.dori = dori
    self.isChevronHidden = isChevronHidden
  }

  private var isJudori: Bool {
    dori.direction == .judori
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
        .padding(4)

      VStack(alignment: .leading, spacing: 4) {
        Text(dori.eventType)
          .pretendard(.semiBold(.sb14))
          .foregroundStyle(.textPrimary)

        if !dori.memo.isEmpty {
          Text(dori.memo)
            .pretendard(.regular(.r12))
            .foregroundStyle(.textSecondary)
        }
      }

      Spacer()

      HStack(spacing: 8) {
        AmountLabel(Int(dori.amount))
          .pretendard(.body(.sb3))
          .foregroundStyle(.textPrimary)

        if !isChevronHidden {
          Image(systemName: "chevron.right")
            .font(.system(size: 12))
            .foregroundStyle(.textDisabled)
        }
      }
    }
    .padding(.vertical, 8)
  }

}

// MARK: - Preview

#Preview {
  VStack {
    TransactionRowView(
      dori: Dori(
        doriId: 1,
        userId: 1,
        partnerId: 1,
        direction: .judori,
        partnerName: "홍길동",
        relationship: "친구",
        eventType: "설날 세뱃돈",
        amount: 100_000,
        eventDate: "2026-01-01",
        isVisited: true,
        memo: "조카에게",
        createdAt: "2026-01-01"
      )
    )

    TransactionRowView(
      dori: Dori(
        doriId: 2,
        userId: 1,
        partnerId: 1,
        direction: .baddori,
        partnerName: "홍길동",
        relationship: "친구",
        eventType: "생일 선물",
        amount: 50_000,
        eventDate: "2026-02-01",
        isVisited: true,
        memo: "",
        createdAt: "2026-02-01"
      )
    )
  }
  .padding()
}
