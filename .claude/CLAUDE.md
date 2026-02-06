# Dori-iOS 개발 지침서

---

## 1. 프로젝트 개요

**앱 이름**: Dori(도리)
**목적**: 경조사 금전 거래(주도리/받도리)를 추적하고 관리하는 iOS 앱

### MVP 범위

| 구분 | 항목 |
|------|------|
| **IN** | KakaoLogin, Keychain 인증, 3탭(캘린더/내역/마이페이지), 전체 CRUD(등록/조회/수정/삭제), 서버 API 연동 |
| **OUT** | Apple Login, 알림(Push Notification), 내보내기(CSV/PDF), 소셜 기능 |

---

## 2. 기술 스택

| 항목 | 버전/설정 |
|------|-----------|
| Swift | 6 |
| iOS Deployment Target | 17.6+ |
| Xcode | 26.2 |
| 아키텍처 | TCA (swift-composable-architecture) 최신 안정 버전 |
| 인증 SDK | KakaoSDK (`KakaoSDKAuth`, `KakaoSDKUser`) |
| 보안 저장소 | KeychainAccess |
| Concurrency | Swift 6 Strict Concurrency |

### Swift 6 빌드 설정

| Build Setting | 값 |
|---|---|
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` |

---

## 3. 아키텍처

### 3.1 TCA 단방향 데이터 플로우

기존 `temp/` MVVM 프로토타입 코드를 TCA로 전환한다.

- 각 화면 = 1개 `@Reducer` + 1개 SwiftUI `View`
- 상태 변경은 반드시 Action → Reducer → State 경로를 따른다
- Side Effect는 `Effect<Action>`으로 관리한다

### 3.2 Navigation 전략

| 범위 | 방식 | 설명 |
|------|------|------|
| App Root | Tree-based | `enum State`로 Intro / MainTab 분기 |
| Tab 내부 (History) | Stack-based | `StackState` / `StackAction`로 list → detail push |
| 모달/시트 | Tree-based | `@Presents` / `ifLet`으로 모달 표시 |

### 3.3 의존성 관리

- TCA `@Dependency` 시스템 사용
- Protocol 대신 **struct + closure** 패턴 (`DependencyKey` 준수)
- `liveValue` / `previewValue` / `testValue` 3단 분리

### 3.4 코드 패턴 참조

**자동화 스킬** (boilerplate 생성용):

| Skill | 용도 |
|-------|------|
| `/tca-reducer` | @Reducer 구조 생성 |
| `/tca-view` | TCA Store 연결 SwiftUI View |
| `/tca-client` | @Dependency Client 구조 |

**레퍼런스 문서** (분기/도메인 지식 필요):

| 문서 | 용도 |
|------|------|
| `docs/tca-navigation.md` | Tree/Stack/Tab/AppRoot Navigation 패턴 |
| `docs/tca-test.md` | TestStore 기반 테스트 패턴 |
| `docs/tca-network.md` | API Client + 에러 핸들링 |

---

## 4. Feature 명세

### 4.1 Intro (인트로/인증)

**흐름**: KakaoLogin → 토큰 획득 → Keychain 저장 → MainTab 전환

**IntroFeature State**:
- `isLoading: Bool`
- `errorMessage: String?`

**Dependencies**:
- `KakaoAuthClient` — 카카오 로그인/로그아웃 처리
- `KeychainClient` — 토큰 저장/조회/삭제

**주요 Action**:
- `loginButtonTapped` → `.run`에서 KakaoAuthClient 호출
- `loginResponse(Result<String, Error>)` → 성공 시 Keychain 저장, 부모에게 전환 알림

### 4.2 Calendar (캘린더 탭)

**기능**: 월별 경조사 캘린더 뷰, 주도리/받도리 필터링

**CalendarFeature State**:
- `currentMonth: Date`
- `selectedType: TransactionType` — `.given` / `.received`
- `transactions: [Transaction]`

**주요 컴포넌트**:
- `MonthSelectorView` — 이전/다음 월 네비게이션
- `DoriSegmentControl` — 주도리/받도리 전환
- `CalendarGridView` — 7열 그리드 캘린더
- `AmountLabel` — 금액 표시

**FAB(Floating Action Button)**: 새 거래 등록 화면 진입

### 4.3 History (내역 탭)

**기능**: 인물 목록 + 검색 → 상세 내역 (Stack navigation)

**HistoryListFeature State**:
- `persons: [Person]`
- `searchText: String`
- `path: StackState<HistoryDetailFeature.State>`

**HistoryDetailFeature State**:
- `person: Person`
- `transactions` (person 내 거래 내역)
- 수정/삭제 기능

**주요 컴포넌트**:
- `PersonCardView` — 인물 카드 (이름, 관계, 바 그래프, 합계)
- `DoriBarGraphView` — 주도리/받도리 비율 바 차트
- `TransactionRowView` — 개별 거래 행
- `DateHeaderView` — 날짜 헤더

### 4.4 MyPage (마이페이지 탭)

**기능**: 사용자 프로필 (카카오 정보), 로그아웃, 회원 탈퇴

**MyPageFeature State**:
- `userName: String`
- `profileImageURL: URL?`

**주요 Action**:
- `logoutButtonTapped` → 로그아웃 확인 Alert
- `deleteAccountButtonTapped` → 회원 탈퇴 확인 Alert
- `confirmLogout` → KakaoAuthClient.logout + Keychain 삭제
- `confirmDeleteAccount` → KakaoAuthClient.unlink + Keychain 삭제

---

## 5. 네트워크 레이어

### 5.1 설계 원칙

- API Client를 TCA `@Dependency`로 정의 (인터페이스 우선 설계)
- 서버 API 스펙 전달 전까지 **Mock 구현**으로 개발 진행
- `liveValue` / `previewValue` / `testValue` 3단 분리

### 5.2 API Client 구조

```swift
@DependencyClient
struct DataClient: Sendable {
    var fetchPersons: @Sendable () async throws -> [Person]
    var fetchPerson: @Sendable (UUID) async throws -> Person
    var fetchTransactions: @Sendable (Date, TransactionType?) async throws -> [Transaction]
    var deletePerson: @Sendable (UUID) async throws -> Void
    // ... CRUD 메서드 추가
}
```

### 5.3 에러 핸들링

```swift
enum APIError: Error, Equatable, Sendable {
    case networkError(String)
    case decodingError
    case unauthorized
    case serverError(Int)
    case unknown
}
```

### 5.4 코드 패턴

`/tca-network` skill 참조

---

## 6. Swift 6 Concurrency 가이드

### 6.1 프로젝트 설정

- `MainActor` 기본 격리 (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- Approachable Concurrency ON (`SWIFT_APPROACHABLE_CONCURRENCY = YES`)

### 6.2 규칙

| 항목 | 규칙 |
|------|------|
| 도메인 모델 | `Sendable` + `Equatable` 준수 |
| Dependency Client struct | `Sendable` 준수 |
| Client closure 프로퍼티 | `@Sendable` 어노테이션 |
| `@unchecked Sendable` | **사용 금지** |
| TCA Effect 내 async 작업 | `.run { send in }` 패턴 사용 |

### 6.3 도메인 모델 예시

```swift
struct Person: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var relationship: Relationship
    var transactions: [Transaction]
}
```

### 6.4 Effect 패턴

```swift
case .loginButtonTapped:
    state.isLoading = true
    return .run { send in
        let result = await Result {
            try await kakaoAuthClient.login()
        }
        await send(.loginResponse(result))
    }
```

---

## 7. 디렉토리 구조

```
Dori-iOS/
  DoriApp.swift
  Core/
    Models/               → Person, Transaction, Relationship, TransactionType
    Clients/              → DataClient, KeychainClient, KakaoAuthClient
      DataClient.swift
      DataClient+Live.swift
      DataClient+Mock.swift
      KeychainClient.swift
      KeychainClient+Live.swift
      KakaoAuthClient.swift
      KakaoAuthClient+Live.swift
    DesignSystem/
      Components/         → AmountLabel, PersonCardView, DoriBarGraphView,
                            TransactionRowView, DateHeaderView,
                            DoriSegmentControl, MonthSelectorView,
                            CalendarGridView, PrimaryButton,
                            DoriCommonAlert, AlertButton,
                            FloatingActionButton
      Extensions/         → Color+Extensions, Date+Extensions, Int+Extensions
  Feature/
    App/                  → AppFeature (Root reducer), AppView
      AppFeature.swift
      AppView.swift
    Intro/                → IntroFeature, IntroView
      IntroFeature.swift
      IntroView.swift
    MainTab/              → MainTabFeature, MainTabView
      MainTabFeature.swift
      MainTabView.swift
    Calendar/             → CalendarFeature, CalendarView
      CalendarFeature.swift
      CalendarView.swift
    History/
      HistoryList/        → HistoryListFeature, HistoryListView
        HistoryListFeature.swift
        HistoryListView.swift
      HistoryDetail/      → HistoryDetailFeature, HistoryDetailView
        HistoryDetailFeature.swift
        HistoryDetailView.swift
    MyPage/               → MyPageFeature, MyPageView
      MyPageFeature.swift
      MyPageView.swift
```

### 의존 방향

```
Feature/ → Core/Clients/ → Core/Models/
Feature/ → Core/DesignSystem/
```

- **모듈화 대비**: `Core/` → `DoriCore`, `DoriClients`, `DoriUI` 패키지로 분리 가능하도록 의존 방향을 유지한다
- **Feature 간 직접 참조 금지**: Feature 간 통신은 부모 Reducer를 통한다

---

## 8. 코딩 컨벤션

### 8.1 네이밍

| 구분 | 패턴 | 예시 |
|------|------|------|
| Feature Reducer | `{Screen}Feature` | `CalendarFeature`, `IntroFeature` |
| View | `{Screen}View` | `CalendarView`, `IntroView` |
| TCA Client | `{Service}Client` | `DataClient`, `KeychainClient` |
| Extension 파일 | `{Type}+{Purpose}.swift` | `Color+Extensions.swift` |
| Live 구현 | `{Client}+Live.swift` | `DataClient+Live.swift` |
| Mock 구현 | `{Client}+Mock.swift` | `DataClient+Mock.swift` |

### 8.2 파일 구조

각 파일은 아래 순서를 따른다:

```swift
import ComposableArchitecture
import SwiftUI

// 1. 타입 정의 (Reducer 또는 View)
@Reducer
struct CalendarFeature {
    // ...
}

// 2. Preview (View 파일인 경우)
#Preview {
    CalendarView(store: Store(initialState: .init()) {
        CalendarFeature()
    })
}
```

### 8.3 문자열 규칙

- UI 표시 문자열: **한국어** (`"로그아웃"`, `"주도리"`, `"받도리"`)
- 코드 식별자: **영어** (`loginButtonTapped`, `fetchPersons`)

---

## 9. Git 전략

### 9.1 브랜치 구조

| 브랜치 | 용도 |
|--------|------|
| `master` | 릴리즈 |
| `develop` | 통합/CI |
| `feature/{issue}-{desc}` | 기능 개발 |

### 9.2 PR 흐름

```
feature/* → develop → master
```

### 9.3 민감 설정 관리

- Kakao App Key 등 민감 값: `.xcconfig` 파일로 관리
- `.xcconfig` 파일은 `.gitignore`에 등록하여 저장소에 포함하지 않는다

---

## 10. 테스트 전략

### 10.1 Reducer 테스트

- TCA `TestStore`를 사용하여 Reducer 로직을 검증한다
- `withDependencies`로 Mock 의존성을 주입한다
- `store.send()` → State 변경 검증
- `store.receive()` → Effect 결과 검증
- 코드 패턴: `/tca-test` skill 참조

### 10.2 유틸리티 테스트

- `Date+Extensions`, `Int+Extensions` 등 Extension 유틸 함수 단위 테스트

### 10.3 MVP 제외 항목

- UI 테스트 / 스냅샷 테스트는 MVP에서 제외
