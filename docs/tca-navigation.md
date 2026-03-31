# TCA Navigation 패턴 레퍼런스

이 문서는 템플릿과 학습용 예시다. 현재 프로젝트의 실제 구조 설명이 아니며, 충돌 시 `docs/constitution.md`와 `ARCHITECTURE.md`를 우선한다.

Navigation 유형에 따라 적절한 패턴(Tree/Stack/Tab/AppRoot)을 선택하여 적용한다.

## 참조

- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/feature-spec.md`

---

## 패턴 1: Tree-based Navigation (모달, 시트, Alert)

App Root에서 Intro/MainTab 분기, 또는 모달/시트 표시에 사용한다.

### Reducer

```swift
@Reducer
struct ParentFeature {
    @Reducer
    enum Destination {
        case edit(EditFeature)
        case detail(DetailFeature)
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }

    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case editButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .editButtonTapped:
                state.destination = .edit(EditFeature.State())
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
```

### View

```swift
struct ParentView: View {
    @Bindable var store: StoreOf<ParentFeature>

    var body: some View {
        content
            .sheet(
                item: $store.scope(
                    state: \.destination?.edit,
                    action: \.destination.edit
                )
            ) { store in
                EditView(store: store)
            }
    }
}
```

---

## 패턴 2: Stack-based Navigation (Push)

History 리스트 → 디테일 등 push navigation에 사용한다.

### Reducer

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

### View

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

---

## 패턴 3: Tab Navigation (iOS 17+)

MainTab에서 자식 Feature들을 탭으로 합성한다.

### Reducer

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

### View (iOS 17+ tabItem API)

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

---

## 패턴 4: App Root (Intro → MainTab 분기)

`@Reducer enum`을 사용하여 앱 루트 상태를 분기한다.

### Reducer

```swift
@Reducer
enum AppFeature {
    case intro(IntroFeature)
    case mainTab(MainTabFeature)
}
```

TCA의 `@Reducer enum`은 자동으로 State/Action/body를 합성한다.
로그인 완료 시 상태 전환이 필요한 경우, 부모에서 처리하거나
별도의 AppCoordinator Reducer를 두어 전환 로직을 관리한다.

### View

```swift
struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        switch store.state {
        case .intro:
            if let introStore = store.scope(state: \.intro, action: \.intro) {
                IntroView(store: introStore)
            }
        case .mainTab:
            if let mainTabStore = store.scope(state: \.mainTab, action: \.mainTab) {
                MainTabView(store: mainTabStore)
            }
        }
    }
}
```

---

## 프로젝트 Navigation 맵

```
AppFeature (@Reducer enum)
├── IntroFeature
└── MainTabFeature (Tab: Scope)
    ├── CalendarFeature
    │   └── (Tree: 거래 등록 모달)
    ├── HistoryListFeature (Stack: StackState)
    │   └── HistoryDetailFeature
    │       └── (Tree: 수정 모달, 삭제 Alert)
    └── MyPageFeature
        └── (Tree: 로그아웃/탈퇴 Alert)
```
