//
//  PartnerDoriDetailView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem
import DoriCore

public struct PartnerDoriDetailView: View {
  @Bindable var store: StoreOf<PartnerDoriDetailFeature>
  @Environment(\.dismiss) private var dismiss

  public init(store: StoreOf<PartnerDoriDetailFeature>) {
    self.store = store
  }

  public var body: some View {
    Group {
      if let dori = store.doriDetail {
        ScrollView {
          VStack(spacing: 16) {
            HStack {
              Text(Int(dori.amount).wonFormatted)
                .pretendard(.bold(.b30))
                .foregroundStyle(.doriBlack)

              Spacer()
            }
            .padding(.top, 24)

            VStack(spacing: 32) {
              ForEach(makeProps(from: dori), id: \.self) { prop in
                DetailRow(prop: prop)
              }
            }

            Spacer()
          }
          .padding(.horizontal, 16)
        }
      } else {
        ContentUnavailableView(
          "데이터 없음",
          systemImage: "doc.slash",
          description: Text("도리 정보를 찾을 수 없습니다.")
        )
      }
    }
    .background(.doriWhite)
    .doriNavigationBar(
      DoriNavigationBarConfig.backWithTitleAndActions(
        store.doriDetail?.partnerName ?? "",
        onBack: { dismiss() },
        trailing: [
          .iconButton(image: Image(.iconEdit), action: { store.send(.editTapped) }),
          .iconButton(image: Image(.iconDelete), action: { store.send(.deleteTapped) })
        ]
      )
    )
    .overlay {
      if store.showDeleteAlert {
        DoriCommonAlert(
          isPresented: Binding(
            get: { store.showDeleteAlert },
            set: { store.send(.setDeleteAlert($0)) }
          ),
          title: "해당 내역을 삭제할까요?",
          description: "삭제한 도리는 다시 복구할 수 없어요",
          secondaryButton: AlertButton(title: "취소") {
            store.send(.setDeleteAlert(false))
          },
          primaryButton: AlertButton(title: "삭제") {
            store.send(.confirmDeleteTapped)
          }
        )
      }
    }
    .doriToast(store.toast) {
      store.send(.toastDismissed)
    }
    .onAppear {
      store.send(.onAppear)
    }
  }

  private func makeProps(from dori: Dori) -> [DetailProp] {
    let isGiven = dori.direction == .judori
    let directionText = isGiven ? "주도리" : "받도리"

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateText: String
    if let date = formatter.date(from: dori.eventDate) {
      let displayFormatter = DateFormatter()
      displayFormatter.locale = Locale(identifier: "ko_KR")
      displayFormatter.dateFormat = "yyyy년 M월 d일"
      dateText = displayFormatter.string(from: date)
    } else {
      dateText = dori.eventDate
    }

    return [
      DetailProp(category: "내역구분", description: directionText),
      DetailProp(category: "경조사", description: dori.eventType),
      DetailProp(category: "나와의관계", description: dori.relationship),
      DetailProp(category: "날짜", description: dateText),
      DetailProp(category: "방문 여부", description: dori.isVisited ? "예" : "아니오"),
      DetailProp(category: "메모", description: dori.memo.isEmpty ? "-" : dori.memo),
    ]
  }
}

// MARK: - Supporting Views

struct DetailProp: Hashable {
  let category: String
  let description: String
}

struct DetailRow: View {
  private let prop: DetailProp

  init(prop: DetailProp) {
    self.prop = prop
  }

  var body: some View {
    HStack {
      Text(prop.category)
        .pretendard(.medium(.m14))
        .foregroundStyle(.grey600)

      Spacer()

      Text(prop.description)
        .pretendard(.semiBold(.sb15))
        .foregroundStyle(.doriBlack)
    }
  }
}

// MARK: - Preview

#Preview {
  NavigationStack {
    PartnerDoriDetailView(
      store: Store(
        initialState: PartnerDoriDetailFeature.State(
          dori: Dori(
            doriId: 1,
            userId: 1,
            partnerId: 1,
            direction: .baddori,
            partnerName: "홍길동",
            relationship: "친구",
            eventType: "생일",
            amount: 50_000,
            eventDate: "2024-05-01",
            isVisited: true,
            memo: "생일 축하합니다",
            createdAt: "2026-02-17T09:00:00"
          )
        )
      ) {
        PartnerDoriDetailFeature()
      } withDependencies: {
        $0.historyAPIClient = .previewValue
      }
    )
  }
}
