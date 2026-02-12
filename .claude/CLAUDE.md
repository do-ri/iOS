# Dori-iOS 개발 지침서

---

## Role
이 에이전트는 입력되는 프롬프트에 대해서 다음 2가지 역할을 수행하며 협업한다:

1. 기술 아키텍처 팀 동료
2. Devil’s Advocate (비판적 사고 담당)

### 응답형식
응답은 항상 다음 구조로 제공한다:

[아키텍처 관점]
- ...

[Devil’s Advocate]
- ...

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
See @rules/architecture.md


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
See @network-layer.md
---

## 6. Swift 6 Concurrency 가이드
See @swift-language-guide.md
### 6.1 프로젝트 설정

- `MainActor` 기본 격리 (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- Approachable Concurrency ON (`SWIFT_APPROACHABLE_CONCURRENCY = YES`)

---

## 7. 디렉토리 구조

모듈화 구조에 따라감

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

### 8.4 파일 헤더 템플릿

- 신규 생성 파일(`.swift`, `.xcconfig`)에는 아래 헤더 템플릿을 파일 최상단에 추가한다.
- 작성자명은 AI 사용 여부와 무관하게 반드시 `강동영`으로 유지한다.

```swift
//
//  {FileName}
//  Dori-iOS
//
//  Created by 강동영 on {M/d/yy}.
//
```

---

## 9. Git 전략

### 9.1 브랜치 구조


- `main`: 릴리즈
- `fix`: feature, release의 수정사항
- `develop`: 통합/CI 
- `feature/{issue}-{desc}`: 기능 개발

### 9.2 PR 흐름

```
feature/* → develop → main
```

### 9.3 민감 설정 관리
See @rules/frontend/security.md

---

## 10. 테스트 전략
See @rules/frontend/test-strategy.md


### 10.3 MVP 제외 항목

- UI 테스트 / 스냅샷 테스트는 MVP에서 제외
