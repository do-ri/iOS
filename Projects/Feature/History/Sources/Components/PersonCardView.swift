//
//  PersonCardView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import SwiftUI
import DoriDesignSystem
import DoriCore

public struct PersonCardView: View {
  private let partner: PartnerSummary
  @State private var isExpanded: Bool = false
  private let onViewAllTapped: (() -> Void)?

  public init(
    partner: PartnerSummary,
    onViewAllTapped: (() -> Void)? = nil
  ) {
    self.partner = partner
    self.onViewAllTapped = onViewAllTapped
  }

  public var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 12) {
        // 헤더: 이름, 관계, 화살표
        HStack {
          Text(partner.partnerName)
            .pretendard(.body(.b4))
            .foregroundStyle(.textPrimary)

          Text(partner.relationship)
            .pretendard(.caption(.m2))
            .foregroundStyle(.textSecondary)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(
              RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(.bgSecondary)
            )

          Spacer()

          OutspreadChevron(isExpanded: $isExpanded)
        }
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .onTapGesture {
          withAnimation {
            isExpanded.toggle()
          }
        }

        // 막대 그래프
        DoriBarGraphView(
          givenAmount: Int(partner.outDoriTotalAmount),
          receivedAmount: Int(partner.inDoriTotalAmount)
        )

        // 금액 표시
        HStack {
          AmountLabel(Int(partner.outDoriTotalAmount))
            .pretendard(.caption(.b1))
            .foregroundStyle(.secondary)

          Spacer()

          AmountLabel(Int(partner.inDoriTotalAmount))
            .pretendard(.caption(.b1))
            .foregroundStyle(.textSecondary)
        }
        .padding(.horizontal, 8)
      }
      .padding(.horizontal, 10)
      .padding(.top, 14)
      .padding(.bottom, 24)
      .background(.bgPrimary)

      Divider()

      if isExpanded {
        VStack {
          VStack(spacing: 0) {
            ForEach(partner.recentDoriList, id: \.doriId) { dori in
              TransactionRowView(dori: dori, isChevronHidden: true)
            }

            if partner.recentDoriList.isEmpty {
              Text("최근 도리 내역이 없습니다")
                .pretendard(.regular(.r12))
                .foregroundStyle(.textSecondary)
                .padding(.vertical, 12)
            }
          }
          .padding(.vertical, 12)

          PrimaryButton(title: "전체 보기") {
            onViewAllTapped?()
          }
          .backgroundColor(.bgPrimary)
          .foregroundColor(.brandMain)
          .strokeColor(.brandMain)
          .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity).combined(with: .blurReplace))
      }
    }
    .background(.bgPrimary)
    .cornerRadius(10)
  }
}

// MARK: - Private

fileprivate struct OutspreadChevron: View {
  @Binding var isExpanded: Bool

  var body: some View {
    Image(systemName: "chevron.down")
      .font(.system(size: 18))
      .foregroundStyle(.textPrimary)
      .rotationEffect(.degrees(isExpanded ? 180 : 0))
      .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isExpanded)
  }
}

// MARK: - Preview

#Preview {
  let samplePartner = PartnerSummary(
    partnerId: 1,
    partnerName: "홍길동",
    relationship: "친구",
    recentDoriList: [
      Dori(
        doriId: 1,
        userId: 1,
        partnerId: 1,
        direction: .judori,
        partnerName: "홍길동",
        relationship: "친구",
        eventType: "설날",
        amount: 100_000,
        eventDate: "2026-01-01",
        isVisited: true,
        memo: "",
        createdAt: "2026-01-01"
      )
    ],
    inDoriTotalAmount: 50_000,
    outDoriTotalAmount: 100_000
  )

  VStack(spacing: 16) {
    PersonCardView(partner: samplePartner)
    PersonCardView(partner: samplePartner)
  }
  .padding()
  .background(.bgSecondary)
}
