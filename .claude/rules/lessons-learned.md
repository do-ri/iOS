# Lessons Learned (실수 방지 가이드)

이 파일은 개발 중 발생한 문제와 해결책을 기록하여 같은 실수를 반복하지 않기 위한 문서입니다.

---

## 1. 토큰 검증 전략 (2026-02-25)

### ❌ 잘못된 접근: 클라이언트에서 JWT 만료 시간 체크

```swift
// 하지 말 것!
let expirationDate = Date(timeIntervalSince1970: exp)
let now = Date()  // 디바이스 로컬 시간

if expirationDate <= now {
  // 만료됨으로 판단 → refresh 시도
}
```

**문제점**:
- 디바이스 시간 조작 가능
- 서버와 클라이언트 시간 불일치
- 시간대 변경 시 오류
- 과도한 복잡도

### ✅ 올바른 접근: 서버가 판단, 클라이언트는 반응

```swift
// Splash에서
case .isAppeared:
  let hasToken = (try? tokenStore.exists()) ?? false

  if hasToken {
    // 바로 진입 (만료 여부 체크 안 함)
    await send(.delegate(.authenticated))
  } else {
    await send(.delegate(.unauthenticated))
  }

// AuthInterceptor에서
public func retry(...) {
  guard response.statusCode == 401 else { return }

  // 서버가 401 보냄 → 이제 refresh
  let success = await refreshTokens()
  if success {
    completion(.retry)  // 원래 요청 재시도
  }
}
```

**핵심**:
- **서버만이 토큰 만료를 정확히 판단할 수 있음**
- 클라이언트는 401 응답에 반응만
- RefreshCoordinator가 중복 refresh 방지
- 가장 단순하고 안전

**참고 프로젝트**: Hambug 앱 (실제 운영 검증됨)

---

## 2. AuthInterceptor의 별도 Session (2026-02-25)

### 왜 필요한가?

```swift
public final class AuthInterceptor: RequestInterceptor {
  private let session: Session  // ← 별도 Session 필수!

  public init(tokenStore: any AuthTokenStoring) {
    self.session = Session()  // interceptor 없음
  }

  private func refreshTokens() async -> Bool {
    // 이 session은 interceptor가 없음
    let response = try await session.request(request)
    // adapt 호출 안 됨 → 무한 루프 방지 ✅
  }
}
```

**필요한 이유**:
1. **무한 루프 방지**: refresh 요청에 interceptor 적용되면 안 됨
2. **순환 참조 방지**: NetworkService ↔ AuthInterceptor

**구조**:
```
메인 Session (interceptor O)  → 일반 API용
AuthInterceptor 내부 Session (interceptor X)  → refresh 전용
```

---

## 3. Splash에서 TokenRefreshClient 사용 금지 (2026-02-25)

### ❌ 문제가 있었던 코드

```swift
// Splash에서
if hasToken {
  // 메인 networkService로 refresh 시도
  let isValid = try await tokenRefreshClient.validateAndRefresh()
  // → 메인 networkService 사용
  // → AuthInterceptor.adapt 호출
  // → 만료된 access token 추가
  // → 401 실패!
}
```

### ✅ 해결책

```swift
// Splash에서
if hasToken {
  // refresh 시도 안 함!
  await send(.delegate(.authenticated))
}

// MainTab 진입 후 첫 API 호출 시
// → 401 발생
// → AuthInterceptor.retry → refresh
// → 성공 ✅
```

**핵심**:
- Splash에서는 토큰 존재만 체크
- refresh는 AuthInterceptor가 자동 처리
- 단순하고 안전

---

## 4. RefreshCoordinator의 역할 (2026-02-25)

### 중복 refresh 방지

```swift
private actor RefreshCoordinator {
  private var refreshTask: Task<Bool, Never>?

  func refresh(with refreshTokens: @escaping @Sendable () async -> Bool) async -> Bool {
    if let existingTask = refreshTask {
      return await existingTask.value  // 이미 진행 중이면 기다림
    }

    let task = Task { await refreshTokens() }
    refreshTask = task
    let result = await task.value
    refreshTask = nil

    return result
  }
}
```

**시나리오**:
```
MainTab 진입 → 3개 API 동시 호출 → 모두 401
  ↓
Calendar: AuthInterceptor.retry → RefreshCoordinator
History: AuthInterceptor.retry → RefreshCoordinator (기다림)
MyPage: AuthInterceptor.retry → RefreshCoordinator (기다림)
  ↓
1번만 refresh 실행 ✅
  ↓
3개 모두 재시도 → 성공
```

**핵심**: 여러 API가 동시에 실패해도 refresh는 1번만

---

## 5. 아키텍처 결정 시 참고

### 다른 프로젝트 패턴 검증

**Hambug 프로젝트**:
- Splash: 토큰 존재만 체크
- refresh: AuthInterceptor에서만 처리
- 실제 운영 검증됨

**교훈**:
- 실제 운영 중인 앱의 패턴을 참고하면 검증된 솔루션을 얻을 수 있음
- 과도한 최적화보다 단순하고 검증된 방법이 더 안전

---

## 요약

| 항목 | ❌ 하지 말 것 | ✅ 해야 할 것 |
|------|-------------|-------------|
| **토큰 검증** | 클라이언트에서 만료 시간 체크 | 서버 401 응답에 반응 |
| **Splash** | refresh 시도 | 토큰 존재만 체크 |
| **AuthInterceptor** | 메인 Session 사용 | 별도 Session 사용 |
| **복잡도** | 과도한 최적화 | 단순하고 검증된 방법 |

---

## 6. TCA StackAction.popFrom 타이밍 (2026-02-25)

### ❌ 잘못된 접근: isEmpty로 root 복귀 체크

```swift
// 하지 말 것!
case .path(.popFrom(id: _)):
  if state.path.isEmpty {  // pop 완료 전 시점이므로 항상 false
    return .send(.delegate(.showTabBar))
  }
  return .none
```

**문제점**:
- `.popFrom`은 pop **시작** 시점에 호출됨 (pop 완료 전)
- 1depth → root로 pop 시:
  - `.popFrom` 호출 시점: `path.count = 1` (아직 pop 전)
  - `isEmpty` 체크 → `false` ❌
  - pop 완료 후: `path.count = 0`
- 결과: root로 돌아가도 TabBar가 표시되지 않음

### ✅ 올바른 접근: count == 1로 root 복귀 체크

```swift
case .path(.popFrom(id: _)):
  // popFrom은 pop 시작 시점이므로 count == 1이면 root로 돌아감
  if state.path.count == 1 {
    return .send(.delegate(.showTabBar))
  }
  return .none
```

**타임라인**:
```
1depth → root로 pop:
  1. .popFrom 호출 → path.count = 1 ✅
  2. count == 1 체크 → true
  3. TabBar 표시 액션 전송
  4. pop 완료 → path.count = 0

2depth → 1depth로 pop:
  1. .popFrom 호출 → path.count = 2
  2. count == 1 체크 → false
  3. TabBar 숨김 유지
  4. pop 완료 → path.count = 1
```

**핵심**:
- **`.popFrom`은 pop 시작 시점, pop 완료 전**
- `path.count == 1`로 체크해야 root 복귀 감지 가능
- `isEmpty`는 절대 true가 될 수 없음 (pop 전이므로)

**참고**: TCA Navigation 문서 - StackAction lifecycle

---

## 7. Custom Navigation Bar의 Swipe Back Gesture (2026-02-26)

### 문제 상황

Custom Navigation Bar 구현 시 **swipe back 제스처가 작동하지 않는** 두 가지 문제 발생:

1. **기본 문제**: `.navigationBarBackButtonHidden(true)` 사용 시 swipe back 비활성화
2. **ScrollView 충돌**: 스크롤 후 swipe 시 ScrollView가 제스처를 먼저 소비

### ❌ 잘못된 접근: 제스처만 활성화

```swift
// 1단계: interactivePopGestureRecognizer만 활성화
func updateUIViewController(...) {
  navigationController.interactivePopGestureRecognizer?.isEnabled = true
  navigationController.interactivePopGestureRecognizer?.delegate = context.coordinator
}

class Coordinator: NSObject, UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    // ❌ 문제: gestureRecognizer.view는 UINavigationController가 아님!
    if let navigationController = gestureRecognizer.view as? UINavigationController {
      return navigationController.viewControllers.count > 1
    }
    return false  // 항상 false 반환 → 작동 안 함
  }
}
```

**문제점**:
- `gestureRecognizer.view`는 `UILayoutContainerView`이지 `UINavigationController`가 아님
- 캐스팅 실패 → 항상 `false` 반환
- **스크롤 후 swipe 시 ScrollView가 우선권**을 가져 pop이 작동 안 함

### ✅ 올바른 접근: Responder Chain + Gesture 우선순위

```swift
private struct NavigationControllerConfigurator: UIViewControllerRepresentable {
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    DispatchQueue.main.async {
      if let navigationController = uiViewController.navigationController {
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = context.coordinator
      }
    }
  }

  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    // 1. Responder Chain 탐색으로 UINavigationController 찾기
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      var responder: UIResponder? = gestureRecognizer.view
      while let current = responder {
        if let navigationController = current as? UINavigationController {
          return navigationController.viewControllers.count > 1
        }
        responder = current.next
      }
      return true  // SwiftUI가 자체 처리
    }

    // 2. ScrollView와 동시 인식 허용
    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      return true
    }

    // 3. 🔑 핵심: Pop gesture에 우선권 부여
    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      // ScrollView의 pan gesture가 pop gesture에게 우선권 양보
      return otherGestureRecognizer is UIPanGestureRecognizer
    }
  }
}
```

### 해결 과정

**1단계: 기본 swipe 활성화**
- `interactivePopGestureRecognizer.isEnabled = true`
- Responder chain 탐색으로 `UINavigationController` 찾기

**2단계: ScrollView 충돌 해결** 🔑
- `shouldRecognizeSimultaneouslyWith`: 두 제스처 동시 인식 허용
- `shouldBeRequiredToFailBy`: **Pop gesture에 우선권 부여**
  - ScrollView의 `UIPanGestureRecognizer`가 pop gesture에게 양보
  - 화면 가장자리 swipe → pop 우선 실행
  - 중앙 swipe → ScrollView 처리

### 작동 원리

```
사용자가 화면 왼쪽 가장자리에서 swipe
  ↓
Pop gesture: "내가 먼저 확인!" (shouldBeRequiredToFailBy)
  ↓
Pop gesture: "화면 가장자리야? YES"
  ↓
Pop 실행! 🎉 (ScrollView는 양보)
  ↓
(가장자리 아니면 ScrollView가 처리)
```

### 적용 방법

```swift
public struct DoriNavigationBarModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
      .safeAreaInset(edge: .top, spacing: 0) {
        DoriNavigationBar(config: config)
      }
      .background(
        NavigationControllerConfigurator()  // ← 여기에 추가
          .frame(width: 0, height: 0)
      )
  }
}
```

### 핵심 포인트

1. **Responder Chain 탐색**: `gestureRecognizer.view`는 container view이므로 chain을 따라 `UINavigationController` 찾기
2. **Gesture 우선순위 설정**: `shouldBeRequiredToFailBy`로 pop gesture가 ScrollView보다 우선하도록 설정
3. **동시 인식 허용**: `shouldRecognizeSimultaneouslyWith`로 두 제스처를 동시에 평가
4. **자동 적용**: ViewModifier의 `.background()`에 configurator 추가하여 모든 뷰에 자동 적용

### 테스트 시나리오

- ✅ 화면 진입 직후 swipe → 정상 작동
- ✅ 스크롤 후 즉시 swipe → 정상 작동 (ScrollView 양보)
- ✅ 스크롤 중 swipe → 정상 작동 (Pop 우선)
- ✅ 일반 스크롤 → 정상 작동

**참고**: iOS의 기본 NavigationBar도 동일한 방식으로 작동함

---

## 요약

| 항목 | ❌ 하지 말 것 | ✅ 해야 할 것 |
|------|-------------|-------------|
| **토큰 검증** | 클라이언트에서 만료 시간 체크 | 서버 401 응답에 반응 |
| **Splash** | refresh 시도 | 토큰 존재만 체크 |
| **AuthInterceptor** | 메인 Session 사용 | 별도 Session 사용 |
| **복잡도** | 과도한 최적화 | 단순하고 검증된 방법 |
| **StackAction.popFrom** | isEmpty로 체크 | count == 1로 체크 |
| **Custom NavBar Swipe** | 제스처만 활성화 | Responder chain + 우선순위 설정 |
| **Amount TextField 포맷팅** | `.id()` 재생성 | `@State localFormattedText` 패턴 |
| **ZStack DatePicker 탭 차단** | overlay 레이어 분리만 시도 | `allowsHitTesting(false)` 로 하위 gesture 완전 차단 |

---

## 8. Amount TextField 포맷팅 + 키보드 유지 (2026-03-13)

### 문제 상황

금액 TextField에서 숫자 삭제 시 콤마 위치가 즉시 업데이트되지 않는 문제 발생.

### ❌ 잘못된 접근: `.id()` modifier로 TextField 재생성

```swift
textField
  .id("\(store.state.state)-\(store.variant.isAmount ? store.text : "")")
```

**문제점**:
- text 변경마다 TextField 재생성 → 키보드 dismiss
- 숫자를 입력/삭제할 때마다 소프트웨어 키보드가 닫힘
- UX 심각하게 저하

### ✅ 올바른 접근: `@State private var localFormattedText` 패턴

```swift
public struct DoriInputFieldView: View {
  @Bindable public var store: StoreOf<InputFieldFeature>
  @State private var localFormattedText: String = ""

  public init(store: StoreOf<InputFieldFeature>) {
    self.store = store
    let initialText = store.text
    self._localFormattedText = State(
      initialValue: initialText.isEmpty ? "" : formatAmount(initialText)
    )
  }
}

// textField에서
TextField(store.placeholder, text: $localFormattedText)
  .keyboardType(.numberPad)
  .onChange(of: localFormattedText) { _, newValue in
    let filtered = newValue.filter { $0.isNumber }
    let formatted = filtered.isEmpty ? "" : formatAmount(filtered)
    if localFormattedText != formatted {
      localFormattedText = formatted  // 콤마 즉시 업데이트
    }
    store.send(.textChanged(filtered))
  }
  .onChange(of: store.text) { _, newValue in
    // 외부 변경(+버튼, clear 등) 동기화
    let formatted = newValue.isEmpty ? "" : formatAmount(newValue)
    if localFormattedText != formatted {
      localFormattedText = formatted
    }
  }
```

**핵심**:
- `localFormattedText`를 직접 변경 → TextField 내부 버퍼와 동기화됨
- TextField 재생성 없음 → 키보드 유지
- `if localFormattedText != formatted` 조건으로 무한 루프 방지
- 외부 변경(+버튼, clear)도 `.onChange(of: store.text)`로 동기화

**적용 범위**: `DoriTextField`의 `@State private var localText` 패턴과 동일한 원리

---

## 9. TextField 글자 수 제한 — Binding.set은 내부 버퍼를 건드리지 않는다 (2026-03-17)

### 문제 상황

이름 TextField에 10자 제한을 `Binding.set`에서 구현했으나, 시뮬레이터에서 11자 이상 입력이 시각적으로 가능했음.

### ❌ 잘못된 접근: `Binding.set`에서 prefix 적용

```swift
TextField(
  "...",
  text: Binding(
    get: { store.searchQuery },
    set: { store.send(.searchQueryChanged(String($0.prefix(10)))) }
  )
)
```

**문제점**:
- `Binding.set`은 store 값만 10자로 저장
- TextField의 **내부 버퍼**는 여전히 11자를 유지
- SwiftUI re-render가 즉각 반영을 보장하지 않아 화면에 11자가 그대로 표시됨

### ✅ 올바른 접근: `@State localText` + `onChange`

```swift
@State private var localNameText: String = ""

TextField("...", text: $localNameText)
  .onChange(of: localNameText) { _, newValue in
    let truncated = String(newValue.prefix(10))
    if localNameText != truncated {
      localNameText = truncated  // TextField가 바라보는 변수 직접 수정 → 즉시 반영
    }
    store.send(.searchQueryChanged(truncated))
  }
  .onChange(of: store.searchQuery) { _, newValue in
    if localNameText != newValue {
      localNameText = newValue  // 외부 변경(파트너 선택, clear 등) 동기화
    }
  }
```

**핵심**:
- TextField가 직접 바인딩하는 `@State` 변수를 잘라내면 즉시 반영됨
- `Binding.set`은 store만 업데이트할 뿐, TextField 내부 버퍼를 바꾸지 않음
- `if localNameText != truncated` 조건으로 무한 루프 방지

**규칙**: **글자 수 제한이 필요한 모든 TextField는 반드시 `@State localText` + `onChange` 패턴을 사용한다.**

---

---

## 10. ZStack Overlay에서 DatePicker Day Cell 선택 불가 (2026-03-18)

### 문제 상황

`AddDoriCalendarView`를 ZStack overlay로 표시할 때 `< >` 버튼, "나가기", "날짜 선택" 버튼은 동작하지만 **DatePicker day cell (날짜 숫자)만 탭이 안 되는** 버그 발생.

### 원인

`doriKeyboardDismissable()`이 적용된 VStack이 Calendar overlay 뒤에 있어도 `simultaneousGesture(TapGesture())`가 DatePicker의 내부 gesture를 방해함.

```swift
// doriKeyboardDismissable() 내부
content
  .contentShape(Rectangle())
  .simultaneousGesture(
    TapGesture().onEnded { /* 키보드 dismiss */ }
  )
```

- `simultaneousGesture`는 다른 gesture와 동시에 인식 시도
- DatePicker day cell은 단순 Button이 아닌 내부 gesture 처리 로직 보유
- ZStack 하위 레이어의 `simultaneousGesture`가 day cell gesture를 intercept

### ❌ 잘못된 접근들

1. **overlay 분리** (Color.black + CalendarView 별도 overlay): 효과 없음
2. **simultaneousGesture 유지한 채 레이어 조정**: 효과 없음
3. **sheet 방식**: 팝업 형식이라 UX 요구사항 불충족

### ✅ 올바른 접근: allowsHitTesting으로 하위 레이어 완전 차단

```swift
ZStack {
  VStack { /* Page 콘텐츠 */ }
    .doriKeyboardDismissable()
    .allowsHitTesting(!store.isDatePickerVisible)  // ← 핵심

  if store.isDatePickerVisible {
    Color.black.opacity(0.4)
      .ignoresSafeArea()
      .allowsHitTesting(false)  // dimming만, gesture 없음

    Color.clear
      .ignoresSafeArea()
      .contentShape(Rectangle())
      .onTapGesture { store.send(.datePickerToggled) }  // 외부 탭 → dismiss

    AddDoriCalendarView(...)  // 최상위 레이어 → 단독으로 터치 수신
  }
}
```

**핵심**:
- `allowsHitTesting(false)`: 해당 뷰와 **모든 하위 뷰**의 터치를 완전 차단 (`.disabled()`와 달리 gesture까지 차단)
- Calendar 표시 중에는 VStack 전체가 hit test에서 제외 → `simultaneousGesture` 방해 없음
- `Color.clear`의 `onTapGesture`가 Calendar 외부 탭을 처리 (exclusive, simultaneous 아님)
- `AddDoriCalendarView`가 최상위에서 터치를 온전히 수신

### allowsHitTesting vs disabled 차이

| | `allowsHitTesting(false)` | `.disabled(true)` |
|---|---|---|
| 터치 수신 | 차단 | 차단 |
| gesture 전파 | 차단 | **통과 (하위 뷰에 전달됨)** |
| 상위 레이어 영향 | 없음 | 없음 |

→ Overlay 뒤의 gesture를 완전히 막으려면 반드시 `allowsHitTesting(false)` 사용

---

**업데이트 일자**: 2026-03-18
**관련 이슈**: 자동 로그인 기능 구현, History Stack 네비게이션 전환, Custom Navigation Bar 구현, 금액 입력 버그 수정, TextField 글자 수 제한 버그 수정, DatePicker Overlay 날짜 선택 버그 수정
