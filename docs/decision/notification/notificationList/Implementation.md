# Implementation — 알림 리스트 화면 추가 (#33)

> 짝 문서: 같은 경로의 [`PLAN.md`](./PLAN.md)
> 브랜치: `feat/33-notification-list` (base `develop`)
> 관련 이슈: [do-ri/iOS#33](https://github.com/do-ri/iOS/issues/33)

## 1. What

캘린더 nav 우상단 종 아이콘 → 탭 → 알림 리스트 화면(push) → `GET /notifications` cursor 무한 스크롤.

### 확정 결정 (사용자)
- 종 아이콘: **단일 고정** (배지 on/off 로직은 후속)
- 항목 탭: **동작 없음**
- 페이징: **cursor 무한 스크롤**
- 모듈: **새 `Projects/Feature/Notification`**

### 신규 파일
- `Projects/Infra/DoriNetwork/Sources/Endpoints/NotificationListEndpoints.swift` — `FetchNotificationsEndpoint(cursor:size:)`, 첫 페이지는 cursor 생략
- `Projects/Infra/DoriNetwork/Sources/Responses/NotificationListResponses.swift` — `NotificationItemResponse`, `NotificationPageResponse`. 응답의 중첩 `data` 객체는 미디코딩(범위 외)
- `Projects/Feature/Notification/Sources/NotificationListAPIClient.swift` — `NotificationSettingsAPIClient` 패턴 복제. `live(networkService:)` + `SuccessResponse<NotificationPageResponse>`
- `Projects/Feature/Notification/Sources/NotificationListFeature.swift` — cursor 무한 스크롤 reducer
- `Projects/Feature/Notification/Sources/NotificationListView.swift` — 목록 + 빈 상태 + 초기/추가 로딩 인디케이터
- `Projects/Feature/Notification/Sources/NotificationRowView.swift` — 제목/본문/시간 + 안읽음 점. 고정밀 타임스탬프는 소수초 절단 후 파싱
- `Projects/Feature/Notification/Tests/NotificationListFeatureTests.swift` — 6 케이스

### 수정 파일
- `Tuist/ProjectDescriptionHelpers/DoriTargets.swift` — `DoriModules.notification` 추가
- `Projects/Feature/Project.swift` — Notification framework/test 타깃 + Calendar 의존(`notification.targetDependency`)
- `Projects/App/Project.swift` — App → notification 의존
- `Projects/App/Sources/DoriApp.swift` — `notificationListAPIClient = .live(networkService:)`
- `Projects/Feature/Calendar/Sources/CalendarFeature.swift` — `@Presents notificationList` + `notificationBellTapped` + `.ifLet`
- `Projects/Feature/Calendar/Sources/CalendarView.swift` — 종 아이콘 trailing(`UIAsset.Icons.notificaitonOff`) + `navigationDestination`
- `Projects/Core/DoriDesignSystem/Sources/DoriEmptyView.swift` — `notificationList` empty content
- `Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/CalendarGridSnapshotTests/*.png` — 종 아이콘 추가에 따른 의도된 baseline 재기록(light/dark)

## 2. 검증 기록
- 빌드: `xcodebuild build -scheme DoriApp` → **BUILD SUCCEEDED**
- 유닛: `FeatureNotificationTests` 6/6 PASS (첫 로드 / 재진입 가드 / 무한스크롤 다음페이지 / 마지막항목 아님 가드 / hasNext=false 가드 / 에러 errorMessage)
- 회귀: `FeatureCalendarTests` 8/8 PASS (CalendarGrid baseline 2장 재기록 → replay 통과)
- 시각: 종 아이콘 nav 렌더 확인. 알림 리스트 목록(제목/본문/날짜/안읽음 점/구분선) + 무한스크롤 스피너 + 빈상태 로딩→empty 전환 확인 (throwaway 스냅샷, 커밋 제외)

## 3. 보류 / 후속
- **종 배지(on/off)**: unread 개수/존재 API 부재로 단일 아이콘 고정. unread API 확정 후 별건.
- **항목 탭 네비게이션**: targetType/targetId 보유. 도리 상세 연결은 별건.
- **타임존**: `pushedAt`에 오프셋 없음 → `timeZone = .current`로 파싱. 서버 기준 확정 시 재검토.
- **아이콘 렌더링**: imageset이 template 아님 → `foregroundStyle` 재색 미적용. 라이트 강제 상태라 무방. 다크 활성화 시 dark variant 검토.
- **스냅샷 baseline**: 알림 리스트 light/dark 정식 baseline은 피그마 spec 확정 후 별건(`test-strategy.md`).
