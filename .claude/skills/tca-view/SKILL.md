---
name: tca-view
description: TCA Store를 연결하는 SwiftUI View를 생성한다. Store 주입 + Preview 패턴 자동 생성.
---

# TCA View 생성

사용자가 요청한 Feature에 대한 TCA Store 연결 SwiftUI View를 생성한다.

## 지침

1. `docs/GUIDE.md` 지침서를 읽고 프로젝트 컨텍스트를 파악한다
2. 대응하는 Feature Reducer가 이미 존재하는지 확인한다
3. 기존 View 코드(`temp/` 또는 `Feature/`)의 UI 구조를 참고한다
4. 아래 템플릿을 기반으로 View를 생성한다

## 템플릿

```swift
import ComposableArchitecture
import SwiftUI

struct {Feature}View: View {
    let store: StoreOf<{Feature}Feature>

    var body: some View {
        // iOS 17+ @ObservableState를 사용하므로
        // WithPerceptionTracking은 불필요하다
        NavigationStack {
            content
                .navigationTitle("제목")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }

    private var content: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    store.send(.itemTapped(item))
                } label: {
                    Text(item.name)
                }
            }
        }
    }
}

#Preview {
    {Feature}View(
        store: Store(initialState: {Feature}Feature.State()) {
            {Feature}Feature()
        }
    )
}
```

## Store 주입 방식: `let store` vs `@Bindable var store`

- **`let store`**: 읽기 전용 접근 + `store.send()` 만 사용하는 경우
- **`@Bindable var store`**: `$store.scope(...)`, `$store.property.sending(...)` 등 바인딩이 필요한 경우
  - Alert: `.alert($store.scope(state: \.alert, action: \.alert))`
  - Sheet: `.sheet(item: $store.scope(state: \.destination?.edit, action: \.destination.edit))`
  - NavigationStack: `NavigationStack(path: $store.scope(state: \.path, action: \.path))`
  - TabView selection: `TabView(selection: $store.selectedTab.sending(\.tabSelected))`

## 규칙

- View 이름: `{Screen}View` (예: `CalendarView`, `IntroView`)
- iOS 17+ `@ObservableState`를 사용하므로 `WithPerceptionTracking`은 사용하지 않는다
- 액션 전송: `store.send(.actionName)`
- UI 문자열은 한국어로 작성한다
- 파일 구조: `import` → View 정의 → `#Preview` 순서

## Alert 표시 패턴

```swift
.alert($store.scope(state: \.alert, action: \.alert))
```

## Sheet/FullScreenCover 패턴

```swift
.sheet(item: $store.scope(state: \.destination?.edit, action: \.destination.edit)) { store in
    EditView(store: store)
}
```

## Stack Navigation (리스트 → 디테일)

```swift
struct HistoryListView: View {
    @Bindable var store: StoreOf<HistoryListFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                ForEach(store.persons) { person in
                    NavigationLink(state: HistoryDetailFeature.State(person: person)) {
                        PersonCardView(person: person)
                    }
                }
            }
        } destination: { store in
            HistoryDetailView(store: store)
        }
    }
}
```

## 파일 위치

- `Dori-iOS/Feature/{FeatureName}/{Feature}View.swift`
- 예: `Dori-iOS/Feature/Calendar/CalendarView.swift`
