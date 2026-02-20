//
//  Page3AmountDateView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem
import DoriCore

struct Page3AmountDateView: View {
  @Bindable var store: StoreOf<AddDoriFeature>
  
  private let amountPresets: [AmountPreset] = .presets
  private let options1x2: [DoriSegmentOption<Visited>] = Visited.allCases.map {
    $0.toSegmentOptions()
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      // 금액
      amountSection

      // 날짜
      dateSection

      // 방문 여부
      visitedSection

      // 메모
      memoSection

      Spacer()

      // 다음 버튼
      PrimaryButton(title: "완료") {
        store.send(.submitTapped)
      }
      .isEnable(store.isPage3Valid)
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 20)
    .overlay {
      if store.isDatePickerVisible {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture { store.send(.datePickerToggled) }
          .overlay {
            AddDoriCalendarView(initialDate: store.eventDate) {
              store.send(.datePickerToggled)
            } selecionAction: { date in
              store.send(.eventDateChanged(date))
              store.send(.datePickerToggled)
            }
          }
      }
    }
  }
  
  // MARK: - Sections
  
  private var amountSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("도리")
        .addDoriSectionTitleStyle()
      
      TextField(
        "금액을 입력해주세요",
        text: $store.amountText.sending(\.amountTextChanged)
      )
      .keyboardType(.numberPad)
      .pretendard(.body(.sb3))
      .roundedStyle()
      
      HStack(spacing: 8) {
        ForEach(
          amountPresets,
          id: \.self
        ) { preset in
          Button {
            store.send(.addAmountTapped(preset.amount))
          } label: {
            Text(preset.title)
              .pretendard(.body(.r3))
              .foregroundStyle(DoriColors.grey600.color)
              .padding(.horizontal, 20)
              .padding(.vertical, 14)
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(DoriColors.grey300.color)
              )
          }
        }
      }
    }
  }
  
  private var dateSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("날짜")
        .addDoriSectionTitleStyle()
      
      let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f
      }()
      
      HStack {
        Text(dateFormatter.string(from: store.eventDate))
          .pretendard(.body(.sb3))
          .foregroundStyle(.doriBlack)

        Spacer()

        Button {
          store.send(.datePickerToggled)
        } label: {
          Image(.iconCalendar)
        }
      }
      .roundedStyle()

    }
  }
  
  private var visitedSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("방문 여부")
        .addDoriSectionTitleStyle()
      
      DoriSegmentGridWithMemo(
        options: options1x2,
        selection: $store.isVisited.sending(\.isVisitedChanged),
        memo: $store.memo.sending(\.memoChanged)
      )
    }
  }
  
  private var memoSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("메모(선택)")
        .addDoriSectionTitleStyle()
      
      DoriTextField(
        "메모를 입력해주세요 (40자)",
        memo: $store.memo.sending(\.memoChanged),
        maxLength: 40
      )
      .lineLimit(3...5)
    }
  }
}

struct AmountPreset: Hashable {
  let title: String
  let amount: Int
  
  init(_ title: String, _ amount: Int) {
    self.title = title
    self.amount = amount
  }
}

extension [AmountPreset] {
  static let presets: [AmountPreset] = [
    .init("+1만", 10_000),
    .init("+3만", 30_000),
    .init("+5만", 50_000),
    .init("+10만", 100_000)
  ]
}

#Preview {
  Page3AmountDateView(
    store: Store(initialState: AddDoriFeature.State(mode: .create)) {
      AddDoriFeature()
    }
  )
}

struct AddDoriCalendarView: View {
  @State private var selection: Date

  private let dismissAction: () -> Void
  private let selecionAction: (Date) -> Void

  init(
    initialDate: Date,
    dismissAction: @escaping () -> Void,
    selecionAction: @escaping (Date) -> Void
  ) {
    self._selection = State(initialValue: initialDate)
    self.dismissAction = dismissAction
    self.selecionAction = selecionAction
  }
  
  var body: some View {
    VStack {
      DatePicker(
        "",
        selection: $selection,
        displayedComponents: .date
      )
      .datePickerStyle(.graphical)
      .tint(DoriColors.main.color)
      .padding()
      .background(DoriColors.doriWhite.color)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      
      
      HStack {
        PrimaryButton(title: "나가기") {
          dismissAction()
        }
        .backgroundColor(.grey100)
        .foregroundColor(.doriBlack)
        
        PrimaryButton(title: "날짜 선택") {
          selecionAction(selection)
        }
      }
    }
    .padding(.horizontal, 16)
    
  }
}
