//
//  CalendarView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/5/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem
import FeatureAddDori
import FeatureNotification

public struct CalendarView: View {
  @Bindable var store: StoreOf<CalendarFeature>

  public init(store: StoreOf<CalendarFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          // 총 금액 표시
          CalendarTotalAmountView(store.selectedType, totalAmount: store.totalAmount)

          HStack(spacing: 0) {
            // 월 선택기
            MonthSelectorView(
              currentMonth: store.currentMonth,
              onPrevious: { store.send(.goToPreviousMonth) },
              onNext: { store.send(.goToNextMonth) },
              onMonthTapped: { store.send(.monthLabelTapped) }
            )

            Spacer()

            // 세그먼트 컨트롤
            DoriSegmentControl(
              selectedType: $store.selectedType.sending(\.selectedTypeChanged)
            )
            .frame(maxWidth: 120)
            .frame(height: 32)
          }

          // 캘린더 그리드
          CalendarGridView(
            days: store.calendarDays,
            selectedType: store.selectedType,
            onDayTapped: { day in
              store.send(.dayTapped(day))
            }
          )

          if let errorMessage = store.errorMessage {
            Text(errorMessage)
              .font(.caption)
              .foregroundColor(.red)
              .padding(.horizontal)
          }
        }
        .padding(.top, 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 80)
      }
      .scrollDisabled(true)
      .background(.bgPrimary)
      .doriNavigationBar(
        DoriNavigationBarConfig.titleWithActions(
          "캘린더",
          trailing: [
            .iconButton(
              image: UIAsset.Icons.notificaitonOff.image.renderingMode(.template),
              action: { store.send(.notificationBellTapped) }
            )
          ]
        )
      )
      .onAppear { store.send(.onAppear) }
      .overlay(alignment: .bottomTrailing) {
        FloatingActionButton {
          store.send(.fabTapped)
        }
        .padding(20)
      }
      .navigationDestination(
        item: $store.scope(state: \.addDori, action: \.addDori)
      ) { addDoriStore in
        AddDoriView(store: addDoriStore)
      }
      .navigationDestination(
        item: $store.scope(state: \.notificationList, action: \.notificationList)
      ) { notificationStore in
        NotificationListView(store: notificationStore)
      }
      .sheet(
        isPresented: Binding(
          get: { store.selectedDay != nil },
          set: { if !$0 { store.send(.sheetDismissed) } }
        )
      ) {
        if let selectedDay = store.selectedDay, let date = selectedDay.date {
          DayDetailSheet(
            date: date,
            doris: store.dayDoris
          )
          .presentationDetents([.medium, .large])
        }
      }
      .sheet(
        isPresented: Binding(
          get: { store.isMonthPickerPresented },
          set: { if !$0 { store.send(.monthPickerDismissed) } }
        )
      ) {
        MonthPickerBottomSheet(
          selectedDate: store.pickerDate,
          onDateChanged: { store.send(.pickerDateChanged($0)) },
          onConfirm: { store.send(.monthPickerConfirmed) }
        )
      }
    }
  }
}

#Preview {
  CalendarView(
    store: Store(initialState: CalendarFeature.State()) {
      CalendarFeature()
    }
  )
}
