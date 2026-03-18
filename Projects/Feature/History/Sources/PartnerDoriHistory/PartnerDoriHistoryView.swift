//
//  PartnerDoriHistoryView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/21/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem

public struct PartnerDoriHistoryView: View {
  @Bindable var store: StoreOf<PartnerDoriHistoryFeature>
  @Environment(\.dismiss) private var dismiss

  public init(store: StoreOf<PartnerDoriHistoryFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // 요약 카드
        VStack {
          DoriBarGraphView(
            givenAmount: Int(store.outDoriTotalAmount),
            receivedAmount: Int(store.inDoriTotalAmount)
          )

          HStack {
            AmountLabel(Int(store.outDoriTotalAmount))
              .pretendard(.caption(.b1))
              .foregroundStyle(.secondary)

            Spacer()

            AmountLabel(Int(store.inDoriTotalAmount))
              .pretendard(.caption(.b1))
              .foregroundStyle(.grey500)
          }
          .padding(.horizontal, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 36)
        .background(.grey100)

        // 도리 내역
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Text("도리 내역")
              .pretendard(.bold(.b16))

            Spacer()

            Button {
              store.send(.setFilterSheet(true))
            } label: {
              Image(.iconFilter)
            }
          }
          .padding(.horizontal, 16)

          Divider()

          if store.doriByDate.isEmpty && !store.isLoading {
            DoriEmptyView(.doriHistory)
              .frame(height: 200)
          } else {
            ForEach(store.doriByDate, id: \.date) { group in
              VStack(alignment: .leading, spacing: 8) {
                DateHeaderView(date: group.date.parsedEventDate)
                  .padding(.horizontal)

                VStack(spacing: 0) {
                  ForEach(group.doris, id: \.doriId) { dori in
                    Button {
                      store.send(.doriTapped(dori))
                    } label: {
                      TransactionRowView(dori: dori)
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                  }
                }
                .cornerRadius(10)
              }
            }
          }
        }
      }
    }
    .background(.doriWhite)
    .doriNavigationBar(
      DoriNavigationBarConfig.backWithTitleAndActions(
        store.partnerName,
        onBack: { dismiss() },
        trailing: [
          .iconButton(image: Image(.iconDelete), action: { store.send(.bulkDeleteTapped) })
        ]
      )
    )
    .sheet(
      isPresented: Binding(
        get: { store.showFilterSheet },
        set: { if !$0 { store.send(.setFilterSheet(false)) } }
      )
    ) {
      DoriFilterSheet(
        selected: store.filter,
        onSelect: { filter in
          store.send(.filterChanged(filter))
        }
      )
      .presentationBackground(DoriDesignSystem.DoriColors.doriWhite.color)
      .presentationDetents([.height(200)])
    }
    .overlay {
      if store.showDeleteAlert {
        DoriCommonAlert(
          isPresented: Binding(
            get: { store.showDeleteAlert },
            set: { store.send(.setDeleteAlert($0)) }
          ),
          title: "모든 내용을 삭제할까요?",
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
}

// MARK: - Filter Sheet

private struct DoriFilterSheet: View {
  let selected: DoriFilter
  let onSelect: (DoriFilter) -> Void

  var body: some View {
    VStack(spacing: 50) {
      RoundedRectangle(cornerRadius: 2.5)
        .frame(width: 50, height: 5)

      VStack(spacing: 30) {
        ForEach(DoriFilter.allCases, id: \.self) { filter in
          Button {
            onSelect(filter)
          } label: {
            HStack {
              Text(filter.rawValue)
                .pretendard(selected == filter ? .bold(.b16) : .regular(.r16))
                .foregroundStyle(.doriBlack)

              Spacer()

              if selected == filter {
                Image(systemName: "checkmark")
                  .foregroundStyle(.main)
              }
            }
            .padding(.horizontal, 20)
          }
        }
      }
      
    }
    .padding(.top, 12)
  }
}

// MARK: - String Helper

private extension String {
  var parsedEventDate: Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: self) ?? Date()
  }
}

// MARK: - Preview

#Preview {
  NavigationStack {
    PartnerDoriHistoryView(
      store: Store(
        initialState: PartnerDoriHistoryFeature.State(
          partnerId: 1,
          partnerName: "홍길동",
          relationship: "친구"
        )
      ) {
        PartnerDoriHistoryFeature()
      } withDependencies: {
        $0.historyAPIClient = .previewValue
      }
    )
  }
}
