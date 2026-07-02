# 알림 리스트 화면 추가 (#33)

> 짝 문서: 같은 경로의 [`Implementation.md`](./Implementation.md)
> 브랜치: `feat/33-notification-list` (base `develop`)
> 관련 이슈: [do-ri/iOS#33](https://github.com/do-ri/iOS/issues/33)

## Context

캘린더 nav 우상단에 알림 진입점이 없었다. 본 작업은 (1) 캘린더 nav 우상단 종 아이콘, (2) 탭 시 알림 리스트 화면 push, (3) `GET /notifications`(cursor 페이징, 최신순) 조회로 목록/빈 상태 렌더를 추가한다.

알림 *설정*은 MyPage에 있으나 알림 *리스트*는 캘린더에서 진입하는 독립 흐름이라 새 `Feature/Notification` 모듈로 분리한다.

## 확정 결정 (사용자)

| 항목 | 결정 |
|---|---|
| 종 아이콘 on/off 배지 | 단일 아이콘 고정 (unread API 부재, 배지 로직 후속) |
| 항목 탭 | 동작 없음 (목록 표시까지) |
| 페이징 | cursor 무한 스크롤 (`nextCursor`/`hasNext`) |
| 모듈 위치 | 새 `Projects/Feature/Notification` |

## Scope

### In
- DoriNetwork: `FetchNotificationsEndpoint`(cursor+size), `NotificationItemResponse`/`NotificationPageResponse`
- 새 Feature/Notification 모듈: Client(`NotificationSettingsAPIClient` 패턴) + Feature(무한스크롤) + View(목록/빈상태/로딩) + Row
- Calendar 통합: `@Presents notificationList` + `navigationDestination` + 종 아이콘 trailing (addDori push 패턴 복제)
- App 조합 client 주입, Tuist 모듈/의존 등록

### Out
- 종 배지 on/off 로직, 항목 탭 네비게이션, 읽음 처리 API
- 알림 리스트 정식 스냅샷 baseline (피그마 spec 확정 후)
- `.preferredColorScheme(.light)` 해제

## Verification
1. `xcodebuild build -scheme DoriApp` 성공
2. `FeatureNotificationTests` 로드/페이징/에러 PASS
3. `FeatureCalendarTests` 회귀 PASS (종 아이콘 추가로 CalendarGrid baseline 재기록)
4. 시뮬레이터: 캘린더 → 종 탭 → 리스트(목록/빈상태) 확인

## Risk
- `pushedAt` 9자리 소수초 → 표준 ISO8601 파서 실패 가능 → 소수초 절단 후 고정 포맷 파싱
- 아이콘 imageset이 template 아님 → nav `foregroundStyle` 재색 미적용 (라이트 강제라 무방)
- Calendar→Notification 단방향 의존 신설

## Related
- `docs/decision/calendarRedesign/redesignCalendarScreen/` — 캘린더 nav/스냅샷 재기록 패턴
- `Projects/Feature/MyPage/Sources/NotificationSettingsFeature.swift` — Client 패턴 출처
- `Projects/Feature/History/Sources/DoriList/` — 리스트/페이징 패턴 출처
