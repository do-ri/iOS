# iOS 라우팅 패턴 가이드: 바닐라 SwiftUI vs TCA

---

## 1. 탭 기반 화면 전환

### 바닐라 SwiftUI

```swift
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarScreen()
                .tag(0)
                .tabItem { Label("캘린더", systemImage: "calendar") }

            HistoryScreen()
                .tag(1)
                .tabItem { Label("내역", systemImage: "list.bullet") }

            MyPageScreen()
                .tag(2)
                .tabItem { Label("마이페이지", systemImage: "person.circle") }
        }
    }
}
```

- `@State`로 탭 인덱스를 관리한다.
- 각 탭의 화면이 독립적인 View로 구성되며, 상위에서 상태 공유가 필요하면 `@Binding` 또는 `@EnvironmentObject`를 사용한다.

### TCA

```swift
@Reducer
struct MainTabFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .calendar
        var calendar = CalendarFeature.State()
        var historyList = HistoryListFeature.State()
        var myPage = MyPageFeature.State()

        enum Tab: Equatable {
            case calendar, history, myPage
        }
    }

    enum Action {
        case tabSelected(State.Tab)
        case calendar(CalendarFeature.Action)
        case historyList(HistoryListFeature.Action)
        case myPage(MyPageFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }
        Scope(state: \.historyList, action: \.historyList) {
            HistoryListFeature()
        }
        Scope(state: \.myPage, action: \.myPage) {
            MyPageFeature()
        }
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .calendar, .historyList, .myPage:
                return .none
            }
        }
    }
}
```

```swift
struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabFeature>

    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            CalendarView(
                store: store.scope(state: \.calendar, action: \.calendar)
            )
            .tag(MainTabFeature.State.Tab.calendar)
            .tabItem { Label("캘린더", systemImage: "calendar") }

            HistoryListView(
                store: store.scope(state: \.historyList, action: \.historyList)
            )
            .tag(MainTabFeature.State.Tab.history)
            .tabItem { Label("내역", systemImage: "list.bullet") }

            MyPageView(
                store: store.scope(state: \.myPage, action: \.myPage)
            )
            .tag(MainTabFeature.State.Tab.myPage)
            .tabItem { Label("마이페이지", systemImage: "person.circle") }
        }
    }
}
```

**핵심 차이점**:
| 항목 | 바닐라 SwiftUI | TCA |
|------|---------------|-----|
| 탭 상태 | `@State` Int | `State.Tab` enum |
| 자식 상태 관리 | 각 View 내부 | 부모 Reducer에서 `Scope` 합성 |
| 자식 간 통신 | `@Binding` / `@EnvironmentObject` | 부모 Reducer에서 Action 중계 |
| 테스트 | UI 테스트 필요 | `TestStore`로 유닛 테스트 가능 |

---

## 2. Feature 간 이동

### 2-1. 같은 탭 내 push (Stack Navigation)

#### 바닐라 SwiftUI

```swift
struct HistoryListScreen: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List(persons) { person in
                Button(person.name) {
                    path.append(person)
                }
            }
            .navigationDestination(for: Person.self) { person in
                HistoryDetailScreen(person: person)
            }
        }
    }
}
```

#### TCA

```swift
@Reducer
struct HistoryListFeature {
    @ObservableState
    struct State: Equatable {
        var persons: [Person] = []
        var path = StackState<HistoryDetailFeature.State>()
    }

    enum Action {
        case path(StackActionOf<HistoryDetailFeature>)
        case personTapped(Person)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .personTapped(person):
                state.path.append(HistoryDetailFeature.State(person: person))
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            HistoryDetailFeature()
        }
    }
}
```

```swift
struct HistoryListView: View {
    @Bindable var store: StoreOf<HistoryListFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                ForEach(store.persons) { person in
                    Button {
                        store.send(.personTapped(person))
                    } label: {
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

**핵심 차이점**:
| 항목 | 바닐라 SwiftUI | TCA |
|------|---------------|-----|
| 네비게이션 스택 | `NavigationPath` | `StackState<Child.State>` |
| push 트리거 | `path.append()` 직접 호출 | Action → Reducer에서 `path.append()` |
| 자식 생명주기 | SwiftUI가 관리 | `.forEach`로 Reducer에서 관리 |
| pop 처리 | SwiftUI 자동 | StackAction으로 자동 처리 |

### 2-2. 다른 탭으로 전환

#### 바닐라 SwiftUI

```swift
// 자식 View에서 탭 전환
struct MyPageScreen: View {
    @Binding var selectedTab: Int

    var body: some View {
        Button("내역 보기") {
            selectedTab = 1  // History 탭으로 전환
        }
    }
}
```

#### TCA

```swift
// MyPageFeature에서 delegate Action을 보냄
@Reducer
struct MyPageFeature {
    enum Action {
        case delegate(Delegate)
        enum Delegate {
            case switchToHistory
        }
    }
}

// MainTabFeature에서 delegate를 처리
Reduce { state, action in
    switch action {
    case .myPage(.delegate(.switchToHistory)):
        state.selectedTab = .history
        return .none
    // ...
    }
}
```

**핵심 차이점**: 바닐라 SwiftUI는 `@Binding`으로 직접 수정하지만, TCA는 delegate Action을 부모 Reducer에서 처리한다. TCA 패턴이 Feature 간 결합도를 낮추고 데이터 흐름을 명확하게 한다.

### 2-3. 모달/시트 (Tree Navigation)

#### 바닐라 SwiftUI

```swift
struct CalendarScreen: View {
    @State private var showAddTransaction = false

    var body: some View {
        content
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionScreen()
            }
    }
}
```

#### TCA

```swift
@Reducer
struct CalendarFeature {
    @Reducer
    enum Destination {
        case addTransaction(AddTransactionFeature)
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }

    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case addButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destination = .addTransaction(AddTransactionFeature.State())
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
```

```swift
struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarFeature>

    var body: some View {
        content
            .sheet(
                item: $store.scope(
                    state: \.destination?.addTransaction,
                    action: \.destination.addTransaction
                )
            ) { store in
                AddTransactionView(store: store)
            }
    }
}
```

**핵심 차이점**:
| 항목 | 바닐라 SwiftUI | TCA |
|------|---------------|-----|
| 표시 상태 | `@State Bool` | `@Presents Destination.State?` |
| 자식 상태 | 자식 View 내부 관리 | 부모 Reducer에서 초기화 |
| dismiss | SwiftUI 자동 | `state.destination = nil` |
| 자식 결과 반환 | 콜백/`@Binding` | `PresentationAction`으로 자동 전달 |

---

## 3. 딥링크

### 바닐라 SwiftUI

```swift
@main
struct DoriApp: App {
    @State private var selectedTab = 0
    @State private var historyPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            MainTabView(selectedTab: $selectedTab, historyPath: $historyPath)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        switch components.host {
        case "history":
            selectedTab = 1
            if let personId = components.queryItems?.first(where: { $0.name == "personId" })?.value {
                historyPath.append(UUID(uuidString: personId)!)
            }
        default:
            break
        }
    }
}
```

### TCA

```swift
// AppFeature 또는 MainTabFeature에 딥링크 Action 추가
enum Action {
    case deepLinkReceived(URL)
}

// Reducer에서 URL을 파싱하여 상태를 변경
case let .deepLinkReceived(url):
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        return .none
    }
    switch components.host {
    case "history":
        state.selectedTab = .history
        if let personIdString = components.queryItems?.first(where: { $0.name == "personId" })?.value,
           let personId = UUID(uuidString: personIdString) {
            return .send(.historyList(.navigateToPerson(personId)))
        }
    default:
        break
    }
    return .none
```

```swift
// View에서 onOpenURL → store.send
.onOpenURL { url in
    store.send(.deepLinkReceived(url))
}
```

**핵심 차이점**:
| 항목 | 바닐라 SwiftUI | TCA |
|------|---------------|-----|
| URL 파싱 위치 | View/App 레벨 | Reducer |
| 상태 변경 | `@State`/`@Binding` 직접 수정 | Action → Reducer → State |
| 테스트 | 어려움 | `store.send(.deepLinkReceived(url))`로 쉽게 테스트 |

### URL 스킴 설계 예시

```
dori://history                          → 내역 탭 이동
dori://history?personId={uuid}          → 특정 인물 상세
dori://calendar?month=2026-03           → 특정 월 캘린더
```

---

## Dori 프로젝트 Navigation 맵

```
AppFeature (struct @Reducer, enum State)
├── IntroFeature
│   └── delegate(.loginSucceeded) → 부모가 .mainTab으로 전환
└── MainTabFeature (Tab: Scope 합성)
    ├── CalendarFeature
    │   └── (Tree: 거래 등록 모달 — @Presents Destination)
    ├── HistoryListFeature (Stack: StackState)
    │   └── HistoryDetailFeature
    │       └── (Tree: 수정 모달, 삭제 Alert)
    └── MyPageFeature
        └── (Tree: 로그아웃/탈퇴 Alert)
```

### 패턴 선택 기준

| 시나리오 | 패턴 | 이유 |
|---------|------|------|
| Intro → MainTab 분기 | struct Reducer + enum State | 로그인 상태에 따른 전체 화면 교체 |
| 탭 전환 | Scope 합성 | 각 탭의 자식 Feature를 독립적으로 관리 |
| 리스트 → 상세 push | Stack (StackState) | 동적 깊이의 navigation stack |
| 모달/시트/Alert | Tree (@Presents) | 1:1 부모-자식 관계의 일시적 표시 |
| Feature 간 통신 | delegate Action | Feature 간 직접 참조 없이 부모를 통해 중계 |
