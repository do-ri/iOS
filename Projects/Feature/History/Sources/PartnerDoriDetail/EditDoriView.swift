//
//  EditDoriView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/23/26.
//

import SwiftUI
import UIKit
import ComposableArchitecture
import DoriDesignSystem
import DoriCore

public struct EditDoriView: View {
  @Bindable var store: StoreOf<EditDoriFeature>
  @Environment(\.dismiss) private var dismiss

  private let options2x2: [DoriSegmentOption<TransactionType>] = [
    .init(id: .judori, title: TransactionType.judori.displayName, role: .normal),
    .init(id: .baddori, title: TransactionType.baddori.displayName, role: .normal),
  ]
  private let options3x2: [DoriSegmentOption<EventType>] = EventType.allCases.map {
    $0.toSegmentOptions()
  }
  private let options1x2: [DoriSegmentOption<Visited>] = Visited.allCases.map {
    $0.toSegmentOptions()
  }

  public init(store: StoreOf<EditDoriFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        // 도리(금액)
        VStack(alignment: .leading, spacing: 12) {
          Text("도리")
            .addDoriSectionTitleStyle()

          DoriInputFieldView(
            store: store.scope(
              state: \.amountInput,
              action: \.amountInput
            )
          )
        }

        // 내역 구분
        VStack(alignment: .leading, spacing: 10) {
          Text("내역 구분")
            .addDoriSectionTitleStyle()

          DoriSegmentGridWithMemo(
            options: options2x2,
            selection: $store.transactionType.sending(\.transactionTypeChanged)
          )
        }

        // 경조사
        VStack(alignment: .leading, spacing: 12) {
          Text("경조사")
            .addDoriSectionTitleStyle()

          DoriSegmentGridWithMemo(
            options: options3x2,
            selection: $store.selectedEventType.sending(\.eventTypeSelected),
            memo: $store.customEventType.sending(\.customEventTypeChanged),
            memoPlaceholder: "경조사를 입력하세요. (10자)"
          )
        }

        // 날짜
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

        // 방문 여부
        VStack(alignment: .leading, spacing: 12) {
          Text("방문 여부")
            .addDoriSectionTitleStyle()

          DoriSegmentGridWithMemo(
            options: options1x2,
            selection: $store.isVisited.sending(\.isVisitedChanged)
          )
        }

        // 메모(선택)
        VStack(alignment: .leading, spacing: 12) {
          Text("메모(선택)")
            .addDoriSectionTitleStyle()

          EditDoriMemoField(
            "메모를 입력해주세요 (40자)",
            text: $store.memo.sending(\.memoChanged),
            maxLength: 40
          )
        }

        // 저장 버튼
        PrimaryButton(title: "저장") {
          store.send(.submitTapped)
        }
        .isEnable(store.isFormValid)
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 20)
    }
    .doriKeyboardDismissable()
    .scrollDismissesKeyboard(.interactively)
    .doriNavigationBar(
      DoriNavigationBarConfig.backWithTitle(
        store.dori.partnerName,
        onBack: { dismiss() }
      )
    )
    .overlay {
      if store.isDatePickerVisible {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture { store.send(.datePickerToggled) }
          .overlay {
            EditDoriCalendarView(initialDate: store.eventDate) {
              store.send(.datePickerToggled)
            } selectionAction: { date in
              store.send(.eventDateChanged(date))
              store.send(.datePickerToggled)
            }
          }
      }
    }
  }
}

// MARK: - Memo Field

struct EditDoriMemoField: View {
  @Binding private var text: String

  private let placeholder: String
  private let maxLength: Int

  static let minHeight: CGFloat = 46

  init(
    _ placeholder: String,
    text: Binding<String>,
    maxLength: Int
  ) {
    self._text = text
    self.placeholder = placeholder
    self.maxLength = maxLength
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      EditDoriMemoTextView(
        text: $text,
        maxLength: maxLength
      )
      .frame(minHeight: Self.minHeight)

      if text.isEmpty {
        Text(placeholder)
          .pretendard(.body(.r3))
          .foregroundStyle(.grey400)
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .allowsHitTesting(false)
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(.doriWhite)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(.grey300, lineWidth: 1)
    )
  }
}

struct EditDoriMemoTextView: UIViewRepresentable {
  @Binding var text: String

  let maxLength: Int

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  func makeUIView(context: Context) -> UITextView {
    FontManager.registerFontIfNeeded("Pretendard-Regular")

    let textView = UITextView()
    textView.delegate = context.coordinator
    textView.backgroundColor = .clear
    textView.isScrollEnabled = false
    textView.font = UIFont(name: "Pretendard-Regular", size: 15) ?? .systemFont(ofSize: 15)
    textView.textColor = UIColor.label
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textView.text = String(text.prefix(maxLength))
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    context.coordinator.parent = self

    let truncated = String(text.prefix(maxLength))
    if uiView.text != truncated {
      uiView.text = truncated
    }

    if truncated != text {
      DispatchQueue.main.async {
        text = truncated
      }
    }
  }

  func sizeThatFits(
    _ proposal: ProposedViewSize,
    uiView: UITextView,
    context: Context
  ) -> CGSize? {
    let width = proposal.width ?? UIScreen.main.bounds.width
    let fittingSize = uiView.sizeThatFits(
      CGSize(width: width, height: .greatestFiniteMagnitude)
    )

    return CGSize(
      width: width,
      height: max(EditDoriMemoField.minHeight, fittingSize.height)
    )
  }

  final class Coordinator: NSObject, UITextViewDelegate {
    var parent: EditDoriMemoTextView

    init(parent: EditDoriMemoTextView) {
      self.parent = parent
    }

    func textViewDidChange(_ textView: UITextView) {
      let truncated = String(textView.text.prefix(parent.maxLength))
      if textView.text != truncated {
        textView.text = truncated
      }

      if parent.text != truncated {
        parent.text = truncated
      }
    }
  }
}

// MARK: - Calendar Picker

private struct EditDoriCalendarView: View {
  @State private var selection: Date

  private let dismissAction: () -> Void
  private let selectionAction: (Date) -> Void

  init(
    initialDate: Date,
    dismissAction: @escaping () -> Void,
    selectionAction: @escaping (Date) -> Void
  ) {
    self._selection = State(initialValue: initialDate)
    self.dismissAction = dismissAction
    self.selectionAction = selectionAction
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
          selectionAction(selection)
        }
      }
    }
    .padding(.horizontal, 16)
  }
}

// MARK: - Preview

//#Preview {
//  NavigationStack {
//    EditDoriView(
//      store: Store(
//        initialState: EditDoriFeature.State(
//          dori: DoriResponsesDTO(
//            doriId: 1,
//            userId: 1,
//            partnerId: 1,
//            direction: "OUT",
//            partnerName: "홍길동",
//            relationship: "친구",
//            eventType: "결혼식",
//            amount: 100_000,
//            eventDate: "2025-08-15",
//            isVisited: true,
//            memo: "축하해요",
//            createdAt: "2026-02-17T09:00:00"
//          )
//        )
//      ) {
//        EditDoriFeature()
//      } withDependencies: {
//        $0.historyAPIClient = .previewValue
//      }
//    )
//  }
//}
