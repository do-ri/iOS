---
name: tca-reducer
description: TCA @Reducer 구조를 생성한다. Feature별 State/Action/body 골격을 자동 생성.
---

# TCA Reducer 생성

사용자가 요청한 Feature에 대한 TCA `@Reducer`를 생성한다.

## 지침

1. `docs/GUIDE.md` 지침서를 읽고 프로젝트 컨텍스트를 파악한다
2. 기존 코드의 패턴과 네이밍 컨벤션을 확인한다
3. 아래 템플릿을 기반으로 Feature에 맞는 Reducer를 생성한다

## 템플릿

```swift
import ComposableArchitecture
import Foundation

@Reducer
struct {Feature}Feature {
    @ObservableState
    struct State: Equatable {
        // 화면에 필요한 상태를 정의한다
        // 예: var items: [Item] = []
        //     var isLoading = false
        //     var errorMessage: String?
    }

    enum Action {
        // 사용자 액션 (View에서 발생)
        // 예: case onAppear
        //     case itemTapped(Item)
        //     case deleteButtonTapped

        // 내부 액션 (Effect 결과)
        // 예: case itemsResponse(Result<[Item], Error>)
    }

    // 의존성 선언
    @Dependency(\.dataClient) var dataClient
    // @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let result = await Result {
                        try await dataClient.fetchItems()
                    }
                    await send(.itemsResponse(result))
                }

            case let .itemsResponse(.success(items)):
                state.isLoading = false
                state.items = items
                return .none

            case let .itemsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
```

## 규칙

- Reducer 이름: `{Screen}Feature` (예: `CalendarFeature`, `IntroFeature`)
- State: `@ObservableState struct State: Equatable`
- 모든 State 프로퍼티는 `Equatable` + `Sendable` 타입이어야 한다
- Action enum은 사용자 액션과 내부 액션(Effect 결과)을 구분하여 정의한다
- 비동기 작업은 `.run { send in }` 패턴을 사용한다
- 자식 Feature 합성이 필요한 경우 `Scope`를 사용한다
- Navigation이 필요한 경우 `docs/tca-navigation.md` 레퍼런스를 참조한다

## 자식 Feature 합성 예시

```swift
var body: some ReducerOf<Self> {
    Scope(state: \.childFeature, action: \.childFeature) {
        ChildFeature()
    }
    Reduce { state, action in
        // ...
    }
}
```

## 파일 위치

- `Dori-iOS/Feature/{FeatureName}/{Feature}Feature.swift`
- 예: `Dori-iOS/Feature/Calendar/CalendarFeature.swift`
