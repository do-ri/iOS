# Dark Mode Validation — (3) Feature 카탈로그 스냅샷

## Context

`docs/decision/supportDarkMode/validateDarkMode/PLAN.md` 가 다크모드 검증을 3단계로 추적 중이다:
- (1) Asset Lint — 진행 중 (별도 PLAN)
- (2) `assertSnapshotPair` 헬퍼 — 별도 PLAN
- (3) **Feature 모듈 카탈로그 스냅샷 페어** — 본 PLAN

`Projects/App/Sources/DoriApp.swift:103` 의 `.preferredColorScheme(.light)` 강제를 안전하게 풀기 위한 마지막 가드. 현재 14장 baseline 은 `Projects/Core/DoriDesignSystem/Tests/Snapshot/` 안의 컴포넌트 수준에 한정. 피처 화면이 다크에서 실제로 어떻게 보이는지에 대한 회귀 자동화는 0건.

## Scope (확정)

- **풀 카탈로그 P0+P1+P2 ≈ 106장 baseline** 일괄 도입
- Mock 데이터는 **`DoriTestSupport` 공용 테스트 모듈 신설** 후 거기에 집중
- Modal/Sheet 화면은 **단독 렌더링** 정책 (부모 합성 없음) — baseline 안정성 우선

## Current TCs (14장 baseline)

| 파일 (`Projects/Core/DoriDesignSystem/Tests/Snapshot/`) | 컴포넌트 | 케이스 |
|---|---|---|
| ColorTokenSnapshotTests | 12 의미 토큰 swatch | swatchSheet × light/dark |
| PrimaryButtonSnapshotTests | PrimaryButton | enabled/disabled × light/dark |
| DoriCommonAlertSnapshotTests | DoriCommonAlert | alert × light/dark |
| DoriToastViewSnapshotTests | DoriToastView | success/error/info × light/dark |

## Prerequisites (단계 0)

1. **validateDarkMode (1) 머지 선행** — `Brand/Secondary.colorset` dark variant 누락 픽스가 들어가야 P0 baseline 이 변색된 다크를 정상으로 굳히지 않음
2. **`DoriTestSupport` 모듈 신설** (`Projects/Core/DoriTestSupport/`):
   - `Projects/Core/Project.swift` 에 `.doriFramework(DoriModules.testSupport.module, dependencies: [DoriModules.core.module.projectDependency])` 추가
   - `DoriModules` enum (`Tuist/ProjectDescriptionHelpers/DoriTargets.swift`) 에 `testSupport` 케이스 추가
   - 내용: `Sources/Mocks/Dori+Mock.swift`, `Partner+Mock.swift` 등 도메인 모델별 `public static let mock` / `mockList` 정적 팩토리. 필요 시 `Clients/` 에 client mockValue 보강 헬퍼
   - 의존: `DoriCore` 만. 테스트 타깃에서만 의존시켜 production 바이너리 영향 차단
3. **테스트 타깃 신설 4개** (`Projects/Feature/Project.swift`):
   - `.doriUnitTests(DoriModules.onboarding.module, ...)`, `.addDori`, `.calendar`, `.myPage`
   - 각 deps: `.external(.composableArchitecture)`, `.external(.snapshotTesting)`, `DoriModules.testSupport.module.projectDependency`
   - History 타깃에도 `.external(.snapshotTesting)`, `.testSupport` 추가
4. **시뮬레이터 디바이스 고정**: iPhone 16 UDID (DoriDesignSystem 스냅샷과 동일)
5. **TCA Feature client mockValue 점검** — `addDoriAPIClient`, `calendarClient`, `myPageAPIClient`, `userNotificationSettingsClient` 등 누락된 경우 본 PLAN 중에 추가

## Catalog

### P0 — Root view (6 TC × 2 = 12장)

| 피처 | TC | 검증 포인트 |
|---|---|---|
| Onboarding | `test_splash` | brandMain · onBrand · hopangche 폰트 |
| Onboarding | `test_intro` | 카카오 로그인 버튼 외부 SDK 색 |
| AddDori | `test_addDoriRoot_step1` | bgPrimary 진입 |
| Calendar | `test_calendarGrid_emptyMonth` | bgPrimary · borderDefault · weekday textSecondary |
| History | `test_doriList_empty` | empty state |
| MyPage | `test_myPage_default` | row · 토글 |

### P1 — 주요 state 분기 (17 TC × 2 = 34장 · 누적 46)

| 피처 | TC 추가 | 검증 포인트 |
|---|---|---|
| Onboarding | `test_intro_loading` | spinner 다크 |
| AddDori | `test_page1_emptySearch`, `test_page1_searchResults`, `test_page3_amountError`, `test_page3_datePickerOpen` | feedbackTextError · **bgScrim** |
| Calendar | `test_calendarGrid_populated`, `test_dayDetailSheet_single`, `test_dayDetailSheet_multiple` | bgSecondary 카드 · sheet |
| History | `test_doriList_populated`, `test_partnerDoriDetail_default`, `test_editDori_default`, `test_editDori_datePickerOpen` | **bgScrim** |
| MyPage | `test_notificationSettings_allOn`, `test_notificationSettings_allOff`, `test_myPage_logoutAlert`, `test_doriToggleSwitch_on`, `test_doriToggleSwitch_off` | **onBrand 토글 knob** (다크에서도 흰색) |

### P2 — 전체 카탈로그 (~30 TC × 2 = 60장 · 누적 ~106)

| 피처 | TC 추가 |
|---|---|
| AddDori | `test_page1_selected`, `test_page2_default`, `test_page2_selected_birthday`, `test_page2_customEventInput`, `test_page3_amountTyped`, `test_page3_amountZero`, `test_addDoriRoot_step3` |
| Calendar | `test_doriSegmentControl_judori`, `test_doriSegmentControl_baddori`, `test_dayDetailSheet_empty` |
| History | `test_search_empty`, `test_search_typedNoResults`, `test_search_typedWithResults`, `test_partnerDoriHistory_all`, `test_partnerDoriHistory_judoriOnly`, `test_partnerDoriHistory_baddoriOnly`, `test_doriBarGraph_zero`, `test_doriBarGraph_judoriHeavy`, `test_doriBarGraph_balanced`, `test_personCard_collapsed`, `test_personCard_expanded`, `test_transactionRow_judori`, `test_transactionRow_baddori`, `test_editDori_amountError`, `test_editDori_deleteAlert` |
| MyPage | `test_fcmPushTest_default`, `test_fcmPushTest_loading`, `test_notificationSettings_partialEnabled` |

## File Layout

```
Projects/Core/DoriTestSupport/
  Sources/
    Mocks/
      Dori+Mock.swift
      Partner+Mock.swift
      ...
    Clients/
      (필요 시 client mockValue 보강 helper)

Projects/Feature/{X}/Tests/Snapshot/{Y}SnapshotTests.swift
Projects/Feature/{X}/Tests/Snapshot/__Snapshots__/{Y}SnapshotTests/{case}.1.png
```

각 TC 는 명시적 두 어설션 — `UITraitCollection(userInterfaceStyle: .light)` / `.dark`. PLAN(2) 의 `assertSnapshotPair` 도입 후 일괄 한 줄로 마이그레이트.

## Phasing

본 PLAN 내부 단계:

1. **Prerequisites 커밋** — `DoriTestSupport` 모듈 + 테스트 타깃 4개 + Tuist install/generate + 누락 client mockValue 보강
2. **P0 커밋** — 6 TC 작성 + record. 다크 활성화 사전 검증 가능 시점
3. **P1 커밋** — 17 TC 작성 + record
4. **P2 커밋** — ~30 TC 작성 + record

PR 분할은 추후 결정. 연관도 높아 단일 PR 권장.

`assertSnapshotPair` 헬퍼는 별도 PLAN(2) — 본 PLAN 완료 후 도입 시 모든 TC 두 줄 → 한 줄 일괄 치환.

## Verification

1. 각 단계 record 1회차 → 자동 baseline 생성 (No reference 자동 기록)
2. replay 2회차 → 전 TC 통과
3. CI 통합: `xcodebuild test` 가 신설 테스트 타깃 4개를 포함하도록 scheme 갱신
4. **`.preferredColorScheme(.light)` 제거 후보 PR 에서 baseline diff 발생량 = 시각 회귀 잠재 영역**. 0건이면 다크 활성화 가능, 다수면 픽스 후 re-record

## Risk / Gotchas

- **시뮬레이터 의존**: CI runner 에 iPhone 16 + Xcode 26.x 강제 필요. 호스트 차이로 깨지는 baseline 과 진짜 회귀를 분간해야 함.
- **TCA 외부 client mockValue 누락**: P0 진입 전 모든 client 의 mockValue 정의 확인 필수. 없으면 본 PLAN 중에 추가.
- **Stack/Tree navigation 단독 스냅샷의 시각 진실성**: 부모 합성 안 함 결정. scrim 위 컨텍스트가 일부 빠지지만 baseline 안정성 우선.
- **`Brand/Secondary.colorset` dark 누락**: validateDarkMode (1) 머지 선행 필수.
- **~106장 baseline = repo ~3MB 증가**: LFS 없이도 무방하나 시간 누적 시 재평가.

## Related

- `docs/decision/supportDarkMode/validateDarkMode/PLAN.md` — 본 PLAN 은 그 (3)
- `docs/frontend/test-strategy.md` — 상태 전이 우선 원칙
- `docs/reference/tca-test.md` — TestStore + withDependencies
- `Projects/Core/DoriDesignSystem/Tests/Snapshot/` — 컴포넌트 스냅샷 선행 예시
- `Projects/Feature/History/Tests/SearchFeatureTests.swift` — 인라인 mock 예시 (DoriTestSupport 로 이전 대상)
