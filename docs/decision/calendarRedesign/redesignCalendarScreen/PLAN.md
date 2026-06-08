# Calendar Redesign — 캘린더 화면 디자인 리뉴얼

> 짝 문서 예정: 같은 경로의 `Implementation.md`
> 대상 PR: (TBD — `feat/51-calendar-redesign`)
> 관련 이슈: [do-ri/iOS#51](https://github.com/do-ri/iOS/issues/51)

## Context

피그마에서 캘린더 화면의 색상/구성요소 규정이 새로 내려왔다.

- 라이트: https://www.figma.com/design/wnKHvrJtZYDxPKRZu64UeJ/?node-id=4156-34370
- 다크: https://www.figma.com/design/wnKHvrJtZYDxPKRZu64UeJ/?node-id=3532-49178

피그마 vs 현재 구현 차이의 본질은 두 갈래로 나뉜다:

1. **컨테이너 컴포넌트(TotalAmount 카드, Segment container)** 는 selectedType (주도리/받도리) 분기를 제거하고 `bgSecondary` 로 통일.
2. **DayCell 강조 (오늘 원형, today dot)** 는 selectedType 분기를 유지하되, judori 강조 색을 기존 `Brand/Secondary` (#6482AD) → **`Semantic/BrandMain`** (light=`#20346F`, dark=`#6C8FF0`) 으로 업그레이드. baddori 는 `textSecondary` 그대로.

vision 픽셀 분석 근거: 라이트 mockup(받도리 선택)의 "25" today 원형은 회색, 다크 mockup(주도리 선택)의 "25" today 원형은 brand blue. judori 강조 색이 `BrandMain` 으로 올라간 것이 디자인 의도이며, "selectedType 분기 완전 제거" 가설은 틀렸음.

피그마 mockup 의 FAB 진곤색 / 다크 brand blue 가 `Semantic/BrandMain` colorset 의 light/dark 페어와 정확히 일치. **신규 colorset 필요 없음**.

`.preferredColorScheme(.light)` 해제는 본 PLAN 의 종료 시점이 아니라 PLAN(3) Phase D 의 다크 카탈로그 sweep fix 가 모두 완료된 후 별건 PR.

## Scope

### In scope

- `CalendarTotalAmountView` — selectedType 분기 제거, `bgSecondary` + `textSecondary`/`textPrimary` 로 통일
- `MonthSelectorView` — chevron/텍스트 색을 명시 토큰화, SwiftUI 시스템 폰트 → pretendard 토큰 교체
- `DoriSegmentControl` — 선택 indicator 색을 selectedType 분기 제거하고 contrast pill (`bgPrimary`) 로 통일
- `CalendarGridView` / `CalendarDayCell` — "오늘" 강조 원형 색을 selectedType 분기 제거하고 `BrandMain` 으로 통일, 텍스트 색은 `onBrand`
- 위 4개 컴포넌트의 light/dark 스냅샷 페어 baseline 재기록 (기존 3 TC 갱신 + 필요 시 추가 케이스)

### Out of scope (별도 작업)

- `FloatingActionButton` — 이미 `BrandMain` 사용 중. 변경 0.
- `CalendarFeature` (State/Action/Reducer) — 시각 변경만, 도메인 로직 변경 0.
- `DayDetailSheet` 내부 — mockup 에서 sheet 가 열린 상태 없음. 색 회귀 없는지 스냅샷 replay 로만 확인.
- `.preferredColorScheme(.light)` 제거 — PLAN(3) 다크 sweep fix 완료 후 별도 PR.
- 하단 탭바 (`MainTabFeature` 영역, mockup 밖) — 본 PR 미포함.
- 안드로이드 mockup 의 status bar / nav bar 비율 픽셀 매칭 — iOS 안전영역 기준으로 재해석.

## Approach

### A. 컴포넌트별 색 매핑 (핵심 결정)

vision 분석 결과 selectedType 분기는 **컨테이너 컴포넌트에서만 제거**되고, **DayCell 강조에서는 유지**되며 judori 색만 업그레이드됨.

현재 구현 → 새 디자인 매핑:

| 컴포넌트 | 현재 | 새 디자인 | 분기 처리 |
|---|---|---|---|
| `CalendarTotalAmountView` | judori → `secondary` bg + `onBrand` text · baddori → `bgSecondary` bg + `textSecondary` text | 항상 `bgSecondary` bg, label `textSecondary`, amount `textPrimary` | **제거** (selectedType 무관) |
| `DoriSegmentControl` 선택 pill | judori → `secondary` · baddori → `textSecondary` | 항상 `bgPrimary` (container `bgSecondary` 위 contrast pill), 텍스트 `textPrimary` | **제거** (selectedType 무관) |
| `CalendarDayCell` 오늘 원형 | judori → `secondary` (#6482AD) · baddori → `textSecondary` | judori → **`brandMain`** (light #20346F / dark #6C8FF0) · baddori → `textSecondary` 그대로 | **유지** (judori 색 업그레이드) |
| `CalendarDayCell` 모든 current-month dot | judori → `secondary` · baddori → `textSecondary` | judori → **`brandMain`** · baddori → `textSecondary` 그대로 | **유지** (judori 색 업그레이드, today/non-today 동일 처리) |

근거: 디자이너 Q4 확답 "ㅇㅇ" + 추가 mockup (light/judori, dark/baddori) 으로 4 조합 매트릭스 완성. 모든 current-month dot 이 selectedType 분기를 따라감 (today 셀 제한 가설은 틀렸음 — 초기 vision 분석의 오해). 이전/다음 월 dimmed dot 만 별도 처리 가능 (현재 코드는 isCurrentMonth false 면 dot 자체를 렌더 안 함).

이 매핑이 본 PLAN 의 핵심. 컨테이너 unification 과 DayCell judori 색 업그레이드는 별개 의도이며 같은 PR 에 묶는다.

### B. 폰트 토큰 일관성

`MonthSelectorView` 가 SwiftUI 시스템 폰트(`.title2`, `.title3`) 를 직접 쓰고 있다. mockup 의 "5월" 텍스트 굵기/크기는 `pretendard(.body(.sb2))` 또는 유사 토큰으로 매핑. chevron 색은 `textPrimary` 명시.

피그마에서 정확한 폰트 토큰 매핑은 Implementation 단계의 spec 추출에서 확정.

### C. Divider 행 처리

`CalendarDayCell` 이 각 셀의 상단에 `Rectangle().frame(height: 0.5)` 를 그리고 있다. mockup 도 행 사이 가는 divider 가 있어 구조는 그대로 유지. 색만 `borderDefault` (이미 적용) 인지 재확인.

### D. 스냅샷 페어 baseline

기존:
- `CalendarGridSnapshotTests`
- `DayDetailSheetSnapshotTests`
- `DoriSegmentControlSnapshotTests`

색 변경으로 기존 baseline PNG 가 깨질 것. **의도된 깨짐 → record → replay → 회귀 시나리오** 흐름으로 재기록. PLAN(3) Implementation.md 의 record/replay 2단 검증 패턴 그대로 따른다.

추가로 `CalendarTotalAmountSnapshotTests`, `MonthSelectorSnapshotTests` 신설 검토 (현재 없음). 본 PLAN 에 신설 포함할지는 Implementation 단계에서 결정.

`assertSnapshotPair` 헬퍼는 PLAN(2) 의 산출물이므로 본 PLAN 에서 활용 가능 여부는 merge 상태에 의존. 머지 전이면 `UITraitCollection(userInterfaceStyle: .light)` / `.dark` 두 함수 명시 패턴으로 작성 후 헬퍼 도입 시 일괄 마이그레이트.

## Files

| 작업 | 경로 |
|---|---|
| Modify | `Projects/Feature/Calendar/Sources/Components/TotalAmountView.swift` |
| Modify | `Projects/Feature/Calendar/Sources/Components/MonthSelectorView.swift` |
| Modify | `Projects/Feature/Calendar/Sources/Components/DoriSegmentControl.swift` |
| Modify | `Projects/Feature/Calendar/Sources/Components/CalendarGridView.swift` |
| Modify | `Projects/Feature/Calendar/Tests/Snapshot/CalendarGridSnapshotTests.swift` |
| Modify | `Projects/Feature/Calendar/Tests/Snapshot/DoriSegmentControlSnapshotTests.swift` |
| Modify (재기록) | `Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/**/*.png` |
| Create (검토) | `Projects/Feature/Calendar/Tests/Snapshot/CalendarTotalAmountSnapshotTests.swift` |
| Create (검토) | `Projects/Feature/Calendar/Tests/Snapshot/MonthSelectorSnapshotTests.swift` |
| Create | `docs/decision/calendarRedesign/redesignCalendarScreen/Implementation.md` |

## Phasing

본 PR 내부 commit slicing (단일 PR 권장 — 연관도 높음):

1. **TotalAmountView 통일** — 분기 제거 + 토큰 적용 + 해당 컴포넌트 스냅샷 페어 record/replay
2. **DoriSegmentControl 통일** — 동일 패턴
3. **CalendarGridView/DayCell 통일** — 동일 패턴
4. **MonthSelectorView 폰트/색 토큰화** — 동일 패턴
5. **CalendarView.swift 통합 검증** — 부모 렌더 회귀 0건 확인

각 phase 끝에 record → replay → 회귀 시나리오 1건 검증 후 다음 phase. 한 번에 모든 baseline 재기록 금지.

## Verification

1. **State 회귀 0**: `CalendarFeatureTests` (있다면) 전수 통과. State/Action/Reducer 변경 0 이므로 fail 시 잘못된 사이드 이펙트 의심.
2. **스냅샷 페어**: 각 컴포넌트 light/dark 페어 baseline PNG 가 디스크에 존재하고 replay 2회차 통과.
3. **회귀 정확성 (sleep 검증)**: 각 phase 마다 1건 의도적 mock state 변경 → diff 보고 → 원복 → pass.
4. **피그마 vs PNG 대조**: 최종 baseline PNG 를 피그마 mockup 과 시각 대조 1회. divider 두께, 원형 셀 크기, 폰트 굵기 비율.
5. **CI green**: PR push 후 `Build App` workflow build/test step 모두 통과.

## Risk / Gotchas

- **컨테이너 unification vs DayCell 분기 유지의 일관성**: 같은 PR 안에서 한쪽은 selectedType 분기 제거, 다른 쪽은 유지 — 디자이너에게는 "왜 분기 처리가 컴포넌트마다 다른가" 질문이 갈 수 있다. 본 PLAN 은 vision 분석 근거로 두 결정을 분리해 정당화하지만, A1 게이트에서 디자이너 확답으로 잠가야 함.
- **단일 mockup 데이터 점**: (light, baddori) 와 (dark, judori) 두 점만 확보됨. (light, judori) / (dark, baddori) 는 vision 근거 없음 — judori 색이 light 모드에서 실제로 navy 인지, baddori 색이 dark 모드에서 실제로 회색인지 확답 필요. PLAN(1) 의 BrandMain colorset 이 light/dark 페어로 정의돼 있고 PLAN(3) 다크 sweep 에서 "judori 강조 = BrandMain" 가설이 일관되게 적용되리라 가정.
- **기존 baseline 재기록 vs 신규 PR review**: 기존 3 TC 의 baseline PNG 가 깨지는 것이 PR review 에서 "왜 이게 바뀌었지?" 라고 보일 수 있음. PR description 에 "selectedType 분기 제거에 따른 의도된 baseline 갱신" 명시.
- **dot color 의 디자인 진실성**: mockup 의 dot 이 진짜 단일 색인지, 모니터 톤 매핑으로 그렇게 보이는 것뿐인지 피그마 raw 값 검증 필요. PLAN 작성 시점에 가설로 둠.
- **PLAN(2) `assertSnapshotPair` 머지 상태 의존**: 머지 전이면 본 PLAN 의 신규 TC 는 light/dark 두 함수 명시 패턴. 머지 후이면 페어 헬퍼 사용. base branch 결정 시점에 확정.
- **`MonthSelectorView` 시스템 폰트 → pretendard 교체**: 폰트 메트릭 변경으로 baseline 가 다른 컴포넌트(CalendarView 통합 스냅샷, 만약 있다면)에도 미세 회귀 유발 가능. 단독 컴포넌트 스냅샷에서만 검증하고 통합 스냅샷은 본 PR 범위 외.
- **`Brand/Secondary` deprecation 신호**: 현재 `Secondary` 가 light/dark 동일 RGB(#6482AD) 로 박혀 있고 본 PLAN 에서 4곳 모두 빼면 사용처가 거의 사라진다. 완전 제거는 후속 PR 에서 별건.

## Related

- `docs/decision/supportDarkMode/testingDarkMode/PLAN.md` — 본 PLAN 의 스냅샷 페어 검증 방법론 출처
- `docs/decision/supportDarkMode/snapshotPair/PLAN.md` — `assertSnapshotPair` 헬퍼 (도입 시 마이그레이트 대상)
- `docs/frontend/test-strategy.md` — light/dark 페어 검증 규칙
- `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Semantic/BrandMain.colorset` — light=`#20346F` / dark=`#6C8FF0`, FAB 와 신규 셀 강조 색의 출처
