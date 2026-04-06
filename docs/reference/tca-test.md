# TCA TestStore 기반 테스트 레퍼런스

이 문서는 테스트 패턴 예시다. 현재 프로젝트의 실제 dependency 이름이나 파일 구조와 다를 수 있다.

Feature Reducer 테스트 작성 시 참조하는 문서. 각 Feature의 State 전이가 다르므로 도메인을 이해한 후 작성한다.

## 참조

- `AGENTS.md`
- `docs/frontend/test-strategy.md`

---

## 템플릿: 기본 Reducer 테스트

```swift
import ComposableArchitecture
import Testing

@testable import Dori_iOS

@MainActor
struct {Feature}FeatureTests {
    // MARK: - 초기 로딩 테스트

    @Test
    func onAppear_데이터를_로드한다() async {
        let store = TestStore(
            initialState: {Feature}Feature.State()
        ) {
            {Feature}Feature()
        } withDependencies: {
            $0.dataClient.fetch = { [.mock] }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.itemsResponse.success) {
            $0.isLoading = false
            $0.items = [.mock]
        }
    }

    // MARK: - 에러 처리 테스트

    @Test
    func onAppear_에러시_메시지를_표시한다() async {
        let store = TestStore(
            initialState: {Feature}Feature.State()
        ) {
            {Feature}Feature()
        } withDependencies: {
            $0.dataClient.fetch = { throw APIError.networkError("연결 실패") }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.itemsResponse.failure) {
            $0.isLoading = false
            $0.errorMessage = "연결 실패"
        }
    }

    // MARK: - 사용자 액션 테스트

    @Test
    func 삭제버튼_탭시_항목을_삭제한다() async {
        let deletedID = LockIsolated<UUID?>(nil)
        let mockItem = Item.mock

        let store = TestStore(
            initialState: {Feature}Feature.State(items: [mockItem])
        ) {
            {Feature}Feature()
        } withDependencies: {
            $0.dataClient.delete = { id in
                deletedID.setValue(id)
            }
        }

        await store.send(.deleteButtonTapped(mockItem.id)) {
            $0.items = []
        }

        #expect(deletedID.value == mockItem.id)
    }
}
```

## 테스트 패턴

### 동기 액션 (State만 변경, Effect 없음)

```swift
@Test
func 탭_선택시_상태가_변경된다() async {
    let store = TestStore(
        initialState: MainTabFeature.State()
    ) {
        MainTabFeature()
    }

    await store.send(.tabSelected(.history)) {
        $0.selectedTab = .history
    }
}
```

### 비동기 액션 (Effect → receive)

```swift
@Test
func 로그인시_토큰을_저장한다() async {
    let savedToken = LockIsolated<String?>(nil)

    let store = TestStore(
        initialState: IntroFeature.State()
    ) {
        IntroFeature()
    } withDependencies: {
        $0.kakaoAuthClient.login = { "mock_token" }
        $0.keychainClient.save = { key, value in
            savedToken.setValue(value)
        }
    }

    await store.send(.loginButtonTapped) {
        $0.isLoading = true
    }

    await store.receive(\.loginResponse.success) {
        $0.isLoading = false
    }

    #expect(savedToken.value == "mock_token")
}
```

### Navigation 테스트

```swift
@Test
func 인물_탭시_디테일로_이동한다() async {
    let person = Person.mock

    let store = TestStore(
        initialState: HistoryListFeature.State(persons: [person])
    ) {
        HistoryListFeature()
    }

    await store.send(.personTapped(person)) {
        $0.path[id: 0] = HistoryDetailFeature.State(person: person)
    }
}
```

### Exhaustive 테스트 비활성화 (복잡한 Effect 체인)

```swift
@Test
func 복잡한_흐름_테스트() async {
    let store = TestStore(
        initialState: SomeFeature.State()
    ) {
        SomeFeature()
    }
    store.exhaustivity = .off

    await store.send(.someAction)
    // receive를 일일이 검증하지 않아도 된다
}
```

## 규칙

- `@MainActor struct` 으로 테스트 구조체 선언 (Swift Testing)
- `@Test` 매크로로 테스트 메서드 선언
- 테스트 메서드 이름은 한국어로 동작을 설명한다
- `withDependencies`로 모든 외부 의존성을 Mock으로 주입한다
- `store.send()` → State 변경 클로저로 기대값 검증
- `store.receive()` → Effect 결과에 대한 State 변경 검증
- Side effect 호출 여부는 `LockIsolated`로 캡처하여 검증한다

## 파일 위치

- `Dori-iOSTests/Feature/{FeatureName}/{Feature}FeatureTests.swift`
- 예: `Dori-iOSTests/Feature/Calendar/CalendarFeatureTests.swift`
