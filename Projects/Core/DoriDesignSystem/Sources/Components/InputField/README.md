# DoriInputField

재사용 가능한 입력 필드 컴포넌트 (TCA 기반)

## 설계 원칙

### 1. 케이스 기반 설계

**세 가지 독립적인 축으로 케이스를 분리:**

#### (A) Variant 축 - 입력 필드의 용도/타입
```swift
enum InputFieldVariant {
  case amount(maxAmount: Int? = nil)  // 금액 입력
  case text(maxLength: Int? = nil)    // 텍스트 입력
}
```

**케이스별 차이 흡수:**
- `amount`: 숫자만 허용, 천단위 콤마 자동 포맷팅, 최대 금액 검증 + cap
- `text`: 일반 텍스트, 최대 길이 제한

#### (B) State 축 - 입력 필드의 표현 상태
```swift
enum InputFieldState {
  case normal
  case error(message: String)
}
```

**케이스별 차이 흡수:**
- `normal`: 기본 보더 색상, 기본 텍스트 색상
- `error`: 빨간 텍스트 + trailing 영역에 에러 메시지 표시, 포커스 자동 해제

> **참고**: `focused` / `disabled` 상태는 별도 enum이 없습니다.
> - 포커스는 View 내부의 `@FocusState private var isFocused`로 관리합니다.
> - 비활성화가 필요한 경우 SwiftUI의 `.disabled()` modifier를 사용합니다.

#### (C) Trailing 축 - 우측 액세서리
```swift
enum InputFieldTrailing {
  case none
  case unitOnly(text: String)          // 단위 라벨만
  case clearOnly                       // 클리어 버튼만
  case unitAndClear(unitText: String)  // 둘 다
}
```

**케이스별 차이 흡수:**
- `unitOnly`: "원" 등의 단위 표시 (에러 시 에러 메시지로 대체)
- `clearOnly`: X 버튼 (텍스트 비어있을 때 숨김)
- `unitAndClear`: 단위 라벨 + X 버튼 동시 표시 (에러 시 단위 대신 에러 메시지)

---

## 구조

### 1. 스타일 분리 (InputFieldStyle)
색상, 폰트, 패딩, 높이 등 시각적 요소를 토큰화

```swift
public struct InputFieldStyle {
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
}
```

> **참고**: `focusedBorderColor`, `errorBorderColor`는 없습니다. 보더 색상은 항상 `normalBorderColor`를 사용하며, 에러 상태는 텍스트 색상 + trailing 에러 메시지로 표현합니다.

### 2. TCA Reducer (InputFieldFeature)
상태 관리 및 비즈니스 로직

**Action:**
- `binding(BindingAction<State>)`: TCA BindingReducer 연동
- `textChanged(String)`: 입력 값 변경 (Variant에 따라 필터링)
- `clearButtonTapped`: 클리어 버튼 탭
- `validateInput`: 입력 검증 (현재 textChanged에서 통합 처리)
- `triggerErrorHaptic`: 에러 햅틱 피드백 발생

**State:**
- `text`: 실제 값 (숫자만 저장)
- `variant`: 입력 타입 및 제한값
- `state`: 현재 표현 상태 (normal / error)
- `trailing`: 우측 액세서리 구성
- `placeholder`: 플레이스홀더 문자열
- `style`: 시각 토큰
- `displayText` (computed): 표시용 값 (amount일 때 천단위 콤마 포함)
- `shouldShowClearButton` (computed): 클리어 버튼 표시 여부
- `isCappedAtLimit` (computed): 최대 금액 도달 + 에러 상태일 때 true → 추가 입력 차단

### 3. SwiftUI View (DoriInputFieldView)
TCA Store를 받아 UI 렌더링

**amount Variant 특이사항:**
- `@State private var localFormattedText` 패턴으로 천단위 콤마를 키보드 유지 상태에서 즉시 업데이트
- 에러(최대값 초과) 발생 시 포커스 자동 해제 (키보드 dismiss)
- `isCappedAtLimit == true`이면 TextField 터치를 막아 추가 입력 차단

**text Variant:**
- `$store.text.sending(\.textChanged)` 직접 바인딩 사용

---

## 사용 예시

### 1. 금액 입력 (단위 + 클리어 버튼)
```swift
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
```

**동작:**
- 숫자만 입력 가능
- 자동 천단위 콤마 (50,000)
- 100만원 초과 시 자동으로 `.error(message: "*입력 한도")` 전환 + 에러 햅틱
- 에러 시 trailing 영역에 "*입력 한도" 표시 (단위 텍스트 대체)
- 에러 시 포커스 자동 해제 (키보드 dismiss)
- 클리어 버튼으로 초기화 가능 (에러 상태도 함께 해제)

### 2. 텍스트 입력 (클리어 버튼만)
```swift
DoriInputFieldView(
  store: Store(
    initialState: InputFieldFeature.State(
      text: "홍길동",
      variant: .text(maxLength: 20),
      state: .normal,
      trailing: .clearOnly,
      placeholder: "이름을 입력하세요"
    )
  ) {
    InputFieldFeature()
  }
)
```

**동작:**
- 일반 텍스트 입력
- 최대 20자 제한 (초과 입력 시 즉시 잘림)
- 클리어 버튼으로 초기화 가능

### 3. 에러 상태
```swift
DoriInputFieldView(
  store: Store(
    initialState: InputFieldFeature.State(
      text: "1000000",
      variant: .amount(maxAmount: 1000000),
      state: .error(message: "*입력 한도"),
      trailing: .unitAndClear(unitText: "원"),
      placeholder: "금액을 입력하세요"
    )
  ) {
    InputFieldFeature()
  }
)
```

**UI 변화:**
- 빨간 텍스트
- trailing 영역에 "*입력 한도" 표시 (단위 텍스트 대신)
- 추가 입력 차단 (`isCappedAtLimit == true`)

---

## 실전 사용 (Parent Feature에서)

```swift
@Reducer
struct AddDoriFeature {
  @ObservableState
  struct State {
    var amountInput = InputFieldFeature.State(
      variant: .amount(maxAmount: 10_000_000),
      trailing: .unitAndClear(unitText: "원"),
      placeholder: "금액을 입력하세요"
    )

    var nameInput = InputFieldFeature.State(
      variant: .text(maxLength: 10),
      trailing: .clearOnly,
      placeholder: "이름을 입력하세요"
    )
  }

  enum Action {
    case amountInput(InputFieldFeature.Action)
    case nameInput(InputFieldFeature.Action)
    case submitButtonTapped
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.amountInput, action: \.amountInput) {
      InputFieldFeature()
    }
    Scope(state: \.nameInput, action: \.nameInput) {
      InputFieldFeature()
    }

    Reduce { state, action in
      switch action {
      case .submitButtonTapped:
        // state.amountInput.text 사용
        let amount = Int(state.amountInput.text) ?? 0
        let name = state.nameInput.text
        return .none

      case .amountInput, .nameInput:
        return .none
      }
    }
  }
}
```

---

## 확장 포인트

### 1. 커스텀 스타일 적용
```swift
var customStyle = InputFieldStyle.default
customStyle.normalBorderColor = .blue
customStyle.height = 60

InputFieldFeature.State(
  variant: .text(),
  style: customStyle
)
```

### 2. 커스텀 검증 로직 (Parent에서 에러 상태 직접 제어)
```swift
// Parent Reducer에서
case .amountInput(.textChanged):
  if let amount = Int(state.amountInput.text),
     amount < 1000 {
    state.amountInput.state = .error(message: "*최소 1,000원")
  }
  return .none
```

### 3. 포커스 제어
```swift
// View에서 — DoriInputFieldView 내부의 @FocusState는 외부 접근 불가이므로
// 포커스 제어가 필요한 경우 SwiftUI의 .focused() modifier를 View 레벨에서 조합
DoriInputFieldView(store: store.scope(state: \.amountInput, action: \.amountInput))
```

---

## 케이스별 차이 흡수 전략 요약

| 케이스 | 차이점 | 흡수 방법 |
|--------|--------|-----------|
| **Variant** | 입력 필터링, 포맷팅 | `textChanged` 액션에서 분기 처리 |
| **State** | 텍스트 색상, 에러 메시지 | Computed property로 색상 계산, trailing 영역 조건부 렌더링 |
| **Trailing** | 우측 요소 조합 | enum + `@ViewBuilder`로 조건부 렌더링 |

**핵심**: 각 축을 독립적인 enum으로 분리 → Reducer에서 조합 로직 처리 → View는 단순 렌더링
