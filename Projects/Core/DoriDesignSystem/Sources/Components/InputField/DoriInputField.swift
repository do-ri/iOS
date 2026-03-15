//
//  DoriInputField.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/26/26.
//

import SwiftUI
import ComposableArchitecture

// MARK: - 케이스 타입 정의

/// (A) Variant 축: 입력 필드의 용도/타입
public enum InputFieldVariant: Equatable, Sendable {
  /// 금액 입력 (숫자만, 천단위 콤마 포맷팅)
  case amount(maxAmount: Int? = nil)
  /// 일반 텍스트 입력
  case text(maxLength: Int? = nil)

  public var isAmount: Bool {
    if case .amount = self { return true }
    return false
  }

  public var maxAmount: Int? {
    if case .amount(let max) = self { return max }
    return nil
  }

  public var maxLength: Int? {
    if case .text(let max) = self { return max }
    return nil
  }
}

/// (B) State 축: 입력 필드의 표현 상태
public enum InputFieldState: Equatable, Hashable, Sendable {
  case normal
  case error(message: String)

  public var isError: Bool {
    if case .error = self { return true }
    return false
  }

  public var errorMessage: String? {
    if case .error(let message) = self { return message }
    return nil
  }
}

/// (C) Trailing 요소 축: 우측 액세서리
public enum InputFieldTrailing: Equatable, Sendable {
  case none
  case unitOnly(text: String)
  case clearOnly
  case unitAndClear(unitText: String)

  public var hasUnit: Bool {
    switch self {
    case .unitOnly, .unitAndClear: return true
    case .none, .clearOnly: return false
    }
  }

  public var hasClear: Bool {
    switch self {
    case .clearOnly, .unitAndClear: return true
    case .none, .unitOnly: return false
    }
  }

  public var unitText: String? {
    switch self {
    case .unitOnly(let text), .unitAndClear(let text): return text
    case .none, .clearOnly: return nil
    }
  }
}

// MARK: - 스타일 토큰

/// 입력 필드 스타일 정의
public struct InputFieldStyle: Equatable, Sendable {
  let height: CGFloat
  let cornerRadius: CGFloat
  let horizontalPadding: CGFloat
  let spacing: CGFloat

  // Colors
  let normalBorderColor: Color
  let backgroundColor: Color

  // Text
  let textColor: Color
  let errorTextColor: Color
  let placeholderColor: Color
  let font: TypoSemantic

  // Unit Label
  let unitColor: Color
  let unitFont: TypoSemantic

  // Error Message
  let errorMessageColor: Color
  let errorMessageFont: TypoSemantic

  public static let `default` = InputFieldStyle(
    height: 52,
    cornerRadius: 10,
    horizontalPadding: 16,
    spacing: 8,
    normalBorderColor: UIAsset.Colors.grey300.color,
    backgroundColor: UIAsset.Colors.doriWhite.color,
    textColor: UIAsset.Colors.doriBlack.color,
    errorTextColor: Color(hex: "FF3B30"),
    placeholderColor: UIAsset.Colors.grey400.color,
    font: TypoSemantic.body(.sb3),
    unitColor: UIAsset.Colors.grey500.color,
    unitFont: TypoSemantic.body(.r3),
    errorMessageColor: Color(hex: "FF3B30"),
    errorMessageFont: TypoSemantic.body(.r3),
  )
}

// MARK: - TCA Reducer

@Reducer
public struct InputFieldFeature {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var text: String
    public var variant: InputFieldVariant
    public var state: InputFieldState
    public var trailing: InputFieldTrailing
    public var placeholder: String
    public var style: InputFieldStyle

    /// 표시용 텍스트 (천단위 콤마 포함)
    var displayText: String {
      guard variant.isAmount, !text.isEmpty else { return text }
      return formatAmount(text)
    }

    /// 클리어 버튼 표시 여부
    var shouldShowClearButton: Bool {
      trailing.hasClear && !text.isEmpty
    }

    /// 최대 금액 도달 후 에러 상태에서는 추가 입력을 막는다.
    var isCappedAtLimit: Bool {
      guard
        let maxAmount = variant.maxAmount,
        state.isError
      else { return false }

      return text == String(maxAmount)
    }

    public init(
      text: String = "",
      variant: InputFieldVariant = .text(),
      state: InputFieldState = .normal,
      trailing: InputFieldTrailing = .none,
      placeholder: String = "",
      style: InputFieldStyle = .default
    ) {
      self.text = text
      self.variant = variant
      self.state = state
      self.trailing = trailing
      self.placeholder = placeholder
      self.style = style
    }
  }

  public enum Action: Equatable, Sendable, BindableAction {
    case binding(BindingAction<State>)
    case textChanged(String)
    case clearButtonTapped
    case validateInput
    case triggerErrorHaptic
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .textChanged(let newText):
        // (케이스별 차이 흡수) Variant에 따라 입력 처리
        switch state.variant {
        case .amount(let maxAmount):
          // 숫자만 허용
          let filtered = newText.filter { $0.isNumber }

          // 최대값 초과 시 자동으로 cap + 에러 상태 표시
          if let max = maxAmount,
             let amount = Int(filtered),
             amount > max {
            let wasNotError = !state.state.isError
            state.text = String(max)
            state.state = .error(message: "*입력 한도")

            // 최초 한도 도달 시에만 햅틱 발생 (중복 방지)
            if wasNotError {
              return .send(.triggerErrorHaptic)
            }
          } else {
            state.text = filtered
            // 에러 상태 해제
            if state.state.isError {
              state.state = .normal
            }
          }
          return .none

        case .text(let maxLength):
          // 최대 길이 제한
          if let max = maxLength {
            state.text = String(newText.prefix(max))
          } else {
            state.text = newText
          }
          return .none
        }

      case .clearButtonTapped:
        state.text = ""
        // 에러 상태 해제
        if state.state.isError {
          state.state = .normal
        }
        return .none

      case .validateInput:
        // textChanged에서 모든 검증 처리
        return .none

      case .triggerErrorHaptic:
        // 햅틱 피드백 발생 (부르르~ 진동)
        return .run { _ in
          await MainActor.run {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
          }
        }
      }
    }
  }
}

// MARK: - Helper Functions

/// 천단위 콤마 포맷팅
private func formatAmount(_ text: String) -> String {
  guard let number = Int(text) else { return text }
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  return formatter.string(from: NSNumber(value: number)) ?? text
}

// MARK: - SwiftUI View

public struct DoriInputFieldView: View {
  @Bindable public var store: StoreOf<InputFieldFeature>
  @State private var localFormattedText: String = ""
  @FocusState private var isFocused: Bool

  public init(store: StoreOf<InputFieldFeature>) {
    self.store = store
    let initialText = store.text
    self._localFormattedText = State(
      initialValue: initialText.isEmpty ? "" : formatAmount(initialText)
    )
  }

  public var body: some View {
    // Main input container
    HStack(spacing: store.style.spacing) {
      // Text Field
      textField
        .pretendard(store.style.font)
        .foregroundColor(textColor)

      Spacer(minLength: 0)

      // Trailing accessories
      trailingView
    }
    .padding(.horizontal, store.style.horizontalPadding)
    .frame(height: store.style.height)
    .background(backgroundColor)
    .overlay(
      RoundedRectangle(cornerRadius: store.style.cornerRadius)
        .stroke(borderColor, lineWidth: 1)
    )
    .clipShape(RoundedRectangle(cornerRadius: store.style.cornerRadius))
  }

  // MARK: - Subviews

  @ViewBuilder
  private var textField: some View {
    // (케이스별 차이 흡수) amount일 때는 포맷팅 적용
    if store.variant.isAmount {
      TextField(store.placeholder, text: $localFormattedText)
        .keyboardType(.numberPad)
        .focused($isFocused)
        .allowsHitTesting(!store.isCappedAtLimit)
        .onChange(of: localFormattedText) { _, newValue in
          handleAmountTextChanged(newValue)
        }
        .onChange(of: store.text) { _, newValue in
          // 외부에서 text가 변경될 때 (+버튼, clear, cap 등) 무조건 동기화
          syncLocalFormattedText(with: newValue)
        }
        .onChange(of: store.state.state) { _, newState in
          // 에러 발생 시 포커스 해제 → 키보드 dismiss
          if newState.isError {
            isFocused = false
          }
        }
    } else {
      TextField(
        store.placeholder,
        text: $store.text.sending(\.textChanged)
      )
      .keyboardType(.default)
    }
  }

  @ViewBuilder
  private var trailingView: some View {
    HStack(spacing: store.style.spacing) {
      // (케이스별 차이 흡수) 에러 시 unit 대신 에러 메시지 표시
      if let errorMessage = store.state.state.errorMessage {
        Text(errorMessage)
          .pretendard(store.style.errorMessageFont)
          .foregroundColor(store.style.errorMessageColor)
      } else if let unitText = store.trailing.unitText {
        // Unit label (에러 없을 때만 표시)
        Text(unitText)
          .pretendard(store.style.unitFont)
          .foregroundColor(store.style.unitColor)
      }

      // Clear button (if should show)
      if store.shouldShowClearButton {
        Button {
          store.send(.clearButtonTapped)
          syncLocalFormattedText(with: store.text)
          isFocused = false
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(Color(hex: "BDBDBD"))
            .frame(width: 20, height: 20)
        }
      }
    }
  }

  // MARK: - Computed Properties

  private var textColor: Color {
    store.state.state.isError
      ? store.style.errorTextColor
      : store.style.textColor
  }

  private var backgroundColor: Color {
    store.style.backgroundColor
  }

  private var borderColor: Color {
    store.style.normalBorderColor
  }

  private func handleAmountTextChanged(_ newValue: String) {
    let filtered = newValue.filter { $0.isNumber }
    let maxAmountText = store.variant.maxAmount.map(String.init)

    if let maxAmount = store.variant.maxAmount,
       let amount = Int(filtered),
       amount > maxAmount {
      localFormattedText = formatAmount(String(maxAmount))
      isFocused = false
      store.send(.textChanged(filtered))
      return
    }

    if store.isCappedAtLimit {
      localFormattedText = formatAmount(store.text)
      isFocused = false
      return
    }

    let formatted = filtered.isEmpty ? "" : formatAmount(filtered)
    if localFormattedText != formatted {
      localFormattedText = formatted
    }
    if store.text != filtered || (filtered == maxAmountText && store.state.state.isError) {
      store.send(.textChanged(filtered))
    }
  }

  private func syncLocalFormattedText(with rawText: String) {
    let formatted = rawText.isEmpty ? "" : formatAmount(rawText)
    if localFormattedText != formatted {
      localFormattedText = formatted
    }
  }
}

// MARK: - Preview

#Preview("Input Field Cases") {
  ScrollView {
    VStack(spacing: 24) {
      Group {
        // Case 1: amount + unitAndClear + normal
        VStack(alignment: .leading, spacing: 8) {
          Text("금액 입력 (단위 + 클리어)")
          DoriInputFieldView(
            store: Store(
              initialState: InputFieldFeature.State(
                text: "50000",
                variant: .amount(maxAmount: 1000000),
                state: .normal,
                trailing: .unitAndClear(unitText: "원"),
                placeholder: "금액을 입력하세요"
              )
            ) {
              InputFieldFeature()
            }
          )
        }

        // Case 2: amount + unitOnly + normal
        VStack(alignment: .leading, spacing: 8) {
          Text("금액 입력 (단위만)")
          DoriInputFieldView(
            store: Store(
              initialState: InputFieldFeature.State(
                text: "100000",
                variant: .amount(),
                state: .normal,
                trailing: .unitOnly(text: "원"),
                placeholder: "금액을 입력하세요"
              )
            ) {
              InputFieldFeature()
            }
          )
        }

        // Case 3: amount + unitAndClear + 최대값 (자동 cap)
        VStack(alignment: .leading, spacing: 8) {
          Text("금액 입력 (21억 한도)")
          DoriInputFieldView(
            store: Store(
              initialState: InputFieldFeature.State(
                text: "2100000000",
                variant: .amount(maxAmount: 2_100_000_000),
                state: .normal,
                trailing: .unitAndClear(unitText: "원"),
                placeholder: "금액을 입력하세요"
              )
            ) {
              InputFieldFeature()
            }
          )
        }
      }

      Group {
        // Case 4: text + clearOnly + normal
        VStack(alignment: .leading, spacing: 8) {
          Text("텍스트 입력 (일반)")
          DoriInputFieldView(
            store: Store(
              initialState: InputFieldFeature.State(
                text: "검색어",
                variant: .text(),
                state: .normal,
                trailing: .clearOnly,
                placeholder: "검색어를 입력하세요"
              )
            ) {
              InputFieldFeature()
            }
          )
        }

        // Case 5: text + none + normal (empty)
        VStack(alignment: .leading, spacing: 8) {
          Text("텍스트 입력 (빈 상태)")
          DoriInputFieldView(
            store: Store(
              initialState: InputFieldFeature.State(
                text: "",
                variant: .text(),
                state: .normal,
                trailing: .clearOnly,
                placeholder: "내용을 입력하세요"
              )
            ) {
              InputFieldFeature()
            }
          )
        }
      }
    }
    .padding()
  }
}

// MARK: - Color Extension

extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)

    let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
    let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
    let b = Double(rgbValue & 0x0000FF) / 255.0

    self.init(red: r, green: g, blue: b)
  }
}
