//
//  PartnerSearchResultRow.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import SwiftUI
import DoriDesignSystem
import DoriNetwork
import DoriCore

struct PartnerSearchResultRow: View {
  @Binding var searchQuery: String
  let partner: Dori

  var body: some View {
    HStack(spacing: 6) {
      HStack(spacing: 6) {
        Text(highlightedName)
          .pretendard(.body(.r4))
          .lineLimit(2)
          
        Text(partner.relationship)
          .pretendard(.caption(.m2))
          .foregroundStyle(DoriColors.grey600.color)
          .fixedSize(horizontal: false, vertical: true)
          .lineLimit(1)
          .truncationMode(.tail)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(
            RoundedRectangle(cornerRadius: 5)
              .fill(DoriColors.grey100.color)
          )
      }

      Spacer()

      Text(partner.eventType)
        .pretendard(.body(.m5))
        .foregroundStyle(DoriColors.grey500.color)

      Text(partner.eventDate)
        .pretendard(.body(.m5))
        .foregroundStyle(DoriColors.grey500.color)
    }
  }
  
  private var highlightedName: AttributedString {
    var attributed = AttributedString(partner.partnerName)
    
    guard !searchQuery.isEmpty,
          let range = attributed.range(of: searchQuery, options: .caseInsensitive)
    else {
      return attributed
    }
    
    // 기본 폰트를 먼저 전체에 적용
    attributed[attributed.startIndex..<attributed.endIndex].font = .pretendard(.body(.r4))
    // 검색어 범위만 bold 처리
    attributed[range].font = .pretendard(.body(.b4))
    
    return attributed
  }
}

public extension Font {
  @MainActor static func pretendard(_ name: TypoSemantic) -> Font {
    let provider = PretendardProvider()
    let style = name.getFontStyle(with: provider)
    return style.font
  }
}

#Preview {
  @Previewable @State var searchQuery = "박수진"
  PartnerSearchResultRow(
    searchQuery: $searchQuery,
    partner: Dori(
      doriId: 1,
      userId: 1,
      partnerId: 1,
      direction: .judori,
      partnerName: "박수진수진수진수진수",
      relationship: "친구야친구야",
      eventType: "결혼식",
      amount: 100_000,
      eventDate: "2024-05-12",
      isVisited: true,
      memo: "",
      createdAt: "2026-05-12"
    )
  )
  .padding(20)
  .padding(.horizontal, 16)
}
