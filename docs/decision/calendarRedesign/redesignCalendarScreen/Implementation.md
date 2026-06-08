# Implementation — 캘린더 화면 디자인 리뉴얼

> 짝 문서: 같은 경로의 [`PLAN.md`](./PLAN.md)
> 대상 PR: (TBD — `feat/51-calendar-redesign`, base `develop`)
> 관련 이슈: [do-ri/iOS#51](https://github.com/do-ri/iOS/issues/51)

## 1. What

PLAN.md 의 Scope 를 산출물 중심으로 재기술.

### 수정 파일

- `Projects/Feature/Calendar/Sources/Components/TotalAmountView.swift` — selectedType 분기 제거
- `Projects/Feature/Calendar/Sources/Components/MonthSelectorView.swift` — pretendard 토큰 적용, chevron 색 명시
- `Projects/Feature/Calendar/Sources/Components/DoriSegmentControl.swift` — 선택 indicator 색 단일화
- `Projects/Feature/Calendar/Sources/Components/CalendarGridView.swift` — `CalendarDayCell` 의 오늘/dot 색 분기 제거

### 수정 파일 (스냅샷 baseline 재기록)

- `Projects/Feature/Calendar/Tests/Snapshot/CalendarGridSnapshotTests.swift`
- `Projects/Feature/Calendar/Tests/Snapshot/DoriSegmentControlSnapshotTests.swift`
- `Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/CalendarGridSnapshotTests/*.png`
- `Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/DoriSegmentControlSnapshotTests/*.png`
- `Projects/Feature/Calendar/Tests/Snapshot/DayDetailSheetSnapshotTests.swift` — 색 회귀 없는지 replay 만 (baseline 변경 없을 시 통과 기대)

### 신규 파일 (Phase B 확정 시)

- `Projects/Feature/Calendar/Tests/Snapshot/CalendarTotalAmountSnapshotTests.swift` (검토 — 현재 미존재)
- `Projects/Feature/Calendar/Tests/Snapshot/MonthSelectorSnapshotTests.swift` (검토 — 현재 미존재)

### 산출물 (검증 결과)

- 컴포넌트 4개의 light/dark 페어 baseline PNG 재기록 로그 (record 1회차 fail 자동 기록 → replay 2회차 통과)
- 각 phase 마다 회귀 시나리오 1건 로그 (의도적 mock state 변경 → diff 보고 → 원복 → pass)
- 피그마 mockup 과의 사람-눈 시각 대조 결과 1회 (이 문서 "검증 기록" 에 기록)
- CI green run URL — Build App workflow 의 build · test step 통과

### Scope 외 (이 문서에서 다루지 않음)

- `FloatingActionButton` 변경 (이미 `BrandMain` 사용 중)
- `CalendarFeature` State/Action/Reducer 변경
- `DayDetailSheet` 내부 (시각 변경 없음 — replay 회귀 검증만)
- `Brand/Secondary` colorset 제거 (본 PR 후 거의 dead code 화 되나, 완전 제거는 후속 별건)
- `.preferredColorScheme(.light)` 해제 (PLAN(3) 다크 sweep fix 완료 후 별도 PR)
- 하단 탭바 / `MainTabFeature`

## 2. How

5페이즈 순차. Phase A 가 본 PLAN 의 가장 큰 게이트 — **디자이너 확답 + 피그마 spec** 둘 다 확보 전까지 Phase B 진입 금지.

### Phase A — Prerequisites (커밋 0건, gating only)

본 PLAN 의 핵심 가설 두 개가 외부 확답 없이는 진행 불가:

#### A1. 디자이너 확답 (질문 게이트)

Vision 분석으로 가설은 좁혀졌지만, mockup 만으로 4 가지 (mode × selectedType) 조합 중 2 개 (light·baddori, dark·judori) 만 확인됨. 나머지 2 개 가설 확정 필요.

질문 항목 (user 가 디자이너에게 전달):

- [ ] **Q1** — `CalendarTotalAmountView` (총 ~ 카드) 배경/텍스트 색이 주도리/받도리 선택에 따라 달라지는가? (PLAN 가설: **selectedType 무관, 항상 `bgSecondary`** — 컨테이너 unification)
- [ ] **Q2** — `DoriSegmentControl` 의 선택 pill 색이 주도리/받도리 선택에 따라 달라지는가? (PLAN 가설: **selectedType 무관, 항상 `bgPrimary`** — container 위 contrast pill)
- [ ] **Q3** — `CalendarDayCell` 의 "오늘" 강조 원형이 selectedType 별로 다른가? (PLAN 가설: **judori=`brandMain`** (light navy / dark brand blue) · **baddori=`textSecondary`** 회색)
- [ ] **Q4** — `CalendarDayCell` 의 이벤트 dot 색이 selectedType 별로 다른가? (PLAN 가설: today 셀의 dot 만 강조 색을 따라감 — judori 면 brandMain, baddori 면 textSecondary. **non-today dot 은 항상 회색 단일** `.textSecondary`)
- [ ] **Q5** — light + judori 조합 mockup 또는 dark + baddori 조합 mockup 제공 가능한가? (vision 으로 검증할 4 조합 매트릭스의 남은 2 개)

**A1 게이트: ✅ PASSED (디자이너 확답 2026-06-06)**
- Q1 (TotalAmount 카드 selectedType 분기): **ㄴㄴ (No, 무관)** — PLAN 가설 확정
- Q2 (Segment pill selectedType 분기): **ㄴㄴ (No, 무관)** — PLAN 가설 확정
- Q3 (DayCell 오늘 원형 selectedType 분기): **ㅇㅇ (Yes, 분기 유지)** — PLAN 가설 확정 (judori=brandMain, baddori=textSecondary)
- Q4 (DayCell dot selectedType 분기): **ㅇㅇ (Yes, 분기 유지)** — Phase D 정정 필요 (모든 dot 이 selectedType 분기, today 제한 가설은 틀림)
- Q5 (추가 mockup): light/judori + dark/baddori 두 장 제공 — 4 조합 매트릭스 완성
  - light/judori: 25 today 원형 = navy (BrandMain light) ✓, 모든 dot navy ✓
  - dark/baddori: 25 today 원형 = gray (textSecondary) ✓, 모든 dot gray ✓
- 추가 발견: light/judori mockup 의 navigation bar 우측에 **알림 종 아이콘** — 본 PR 범위 외 (notification 액션은 별도 feature)

#### A2. 피그마 spec inspect 게이트

PNG mockup 만으로는 픽셀-정확 hex 가 안 잡힘 (anti-aliasing). 아래 체크리스트는 **vision 추정값 + 현재 구현값**을 기본으로 박은 채, user 가 피그마 inspect 로 **검증/정정 only** 진행하는 형태. 항목 옆 ⭢ 뒤가 추정값.

> **공통 vision 추정 요약**:
> - 카드/segment container 배경 = `bgSecondary` (두 모드 모두) — 페이지 배경 대비 살짝 들어간 톤
> - 강조 색 (FAB, judori 상태의 today) = `brandMain` colorset (light/dark 페어 자동)
> - baddori 상태의 today 강조 = `textSecondary` 회색
> - non-today dot = `textSecondary` 단일 회색 (모드/selectedType 무관)
> - 폰트는 모두 pretendard 토큰으로 매핑 가능 (시스템 폰트 없음 가정)

##### A2-1. `CalendarTotalAmountView` (총 ~ 카드)

- [ ] **카드 배경**: ⭢ `.bgSecondary` (selectedType 무관, 두 모드 모두)
- [ ] **카드 corner radius**: ⭢ `10` pt (현재 유지)
- [ ] **카드 height**: ⭢ `46` pt (현재 유지, vision 일치)
- [ ] **horizontal padding**: ⭢ `16` pt (현재 유지)
- [ ] **vertical padding**: ⭢ `11` pt (현재 유지)
- [ ] **label "총 받도리" 폰트**: ⭢ `pretendard(.body(.m3))` = medium 15 (현재 유지)
- [ ] **amount "2,500,000원" 폰트**: ⭢ `pretendard(.body(.sb3))` = semibold 15 (현재 유지)
- [ ] **label 색 토큰**: ⭢ `.textSecondary`
- [ ] **amount 색 토큰**: ⭢ `.textPrimary` (vision: amount 가 label 보다 짙음 — judori 모드도 동일하게 textPrimary 가정)

##### A2-2. `MonthSelectorView`

- [ ] **"5월" 폰트**: ⭢ `pretendard(.body(.sb2))` = semibold 16 (vision: title2-semibold(~20pt) 보다는 작아 보임; 그러나 피그마 spec 확정 필요. 대안 `.subtitle(.sb1)` = semibold 20)
- [ ] **chevron 크기**: ⭢ SF Symbol `chevron.left`/`right`, `.system(size: 16, weight: .semibold)` 정도
- [ ] **chevron 색 토큰**: ⭢ `.textPrimary` (vision: "5월" 텍스트와 동일 짙음)
- [ ] **chevron ↔ "5월" spacing**: ⭢ `20` pt (현재 유지) — 또는 mockup vision 으로 더 좁아 보이면 `12`
- [ ] **container vertical padding**: ⭢ `8` pt (현재 유지)

##### A2-3. `DoriSegmentControl`

- [ ] **container 배경**: ⭢ `.bgSecondary` (selectedType 무관, 두 모드 모두)
- [ ] **container corner radius**: ⭢ `16` pt (vision: pill 모양으로 더 둥글어 보임 — 현재 10 보다 클 가능성. 피그마 확정 필요)
- [ ] **container inset**: ⭢ `4` pt (현재 유지)
- [ ] **선택 pill 배경**: ⭢ `.bgPrimary` (selectedType 무관 — 페이지 배경 색으로 contrast)
- [ ] **선택 pill corner radius**: ⭢ `12` pt (container 16 가정 시 inset 4 빼면 12)
- [ ] **선택 텍스트 폰트**: ⭢ `pretendard(.caption(.b1))` = bold 13 (현재 유지)
- [ ] **비선택 텍스트 폰트**: ⭢ `pretendard(.body(.m5))` = medium 13 (현재 유지)
- [ ] **선택 텍스트 색**: ⭢ `.textPrimary`
- [ ] **비선택 텍스트 색**: ⭢ `.textSecondary` (vision: 다크 mockup 의 "받도리" 가 회색으로 dimmed)
- [ ] **컴포넌트 너비 / 높이**: ⭢ maxWidth 120, height 32 (현재 유지)

##### A2-4. `CalendarGridView` / `CalendarDayCell`

- [ ] **weekday 폰트**: ⭢ `pretendard(.regular(.r13))` = regular 13 (현재 유지)
- [ ] **weekday 색**: ⭢ `.textSecondary` (현재 유지)
- [ ] **weekday → 첫 row spacing**: ⭢ `10` pt (현재 padding(.bottom, 10) 유지)
- [ ] **day number 폰트**: ⭢ `pretendard(.medium(.m15))` = medium 15 (현재 유지)
- [ ] **day number 색 (현재월·비-today)**: ⭢ `.textPrimary` (현재 유지)
- [ ] **day number 색 (이전/다음월 dimmed)**: ⭢ `.textDisabled` (현재 유지)
- [ ] **day number 색 (today 강조)**: ⭢ `.onBrand` (현재 유지)
- [ ] **셀 height**: ⭢ `44` pt (현재 유지)
- [ ] **셀 top padding**: ⭢ `8` pt (현재 유지)
- [ ] **셀 bottom padding**: ⭢ `26` pt (현재 유지)
- [ ] **today 원형 색 (judori)**: ⭢ `.brandMain` 🆕 (변경: `secondary` → `brandMain`)
- [ ] **today 원형 색 (baddori)**: ⭢ `.textSecondary` (현재 유지)
- [ ] **today 원형 크기**: ⭢ 약 35pt (day number + padding(8), 현재 유지)
- [ ] **today dot 색 (judori)**: ⭢ `.brandMain` 🆕 (변경)
- [ ] **today dot 색 (baddori)**: ⭢ `.textSecondary` (현재 유지)
- [ ] **non-today dot 색**: ⭢ `.textSecondary` 🆕 (변경: selectedType 분기 제거, 단일 회색)
- [ ] **dot 크기**: ⭢ `6 × 6` (현재 유지)
- [ ] **dot ↔ day number spacing**: ⭢ `7` pt (현재 유지)
- [ ] **row divider 색**: ⭢ `.borderDefault` (현재 유지)
- [ ] **row divider 두께**: ⭢ `0.5` pt (현재 유지)

**A2 게이트: ✅ LOCKED (user 결정 2026-06-06)** — vision/Semantic 토큰 도출값을 최종 확정. 모든 색이 디자인 시스템의 Semantic colorset 을 경유하므로 colorset 자체와 일관성 확보. baseline PNG 시각 대조도 figma mockup 과 매치. 향후 회귀 발견 시 별건 fix.

### Phase B — TotalAmountView 통일 (커밋 1)

A2-1 결과 반영. 핵심 변경:

```swift
// before
.foregroundStyle(selectedType == .judori ? .onBrand : .textSecondary)
.background(
  RoundedRectangle(cornerRadius: 10)
    .fill(selectedType == .judori ? .secondary : .bgSecondary)
)

// after (가설 — A2-1 확정값으로 대체)
HStack {
  Text("총 \(selectedType.displayName)")
    .pretendard(.body(.m3))
    .foregroundStyle(.textSecondary)
  Spacer()
  AmountLabel(totalAmount)
    .pretendard(.body(.sb3))
    .foregroundStyle(.textPrimary)
}
.background(
  RoundedRectangle(cornerRadius: 10)
    .fill(.bgSecondary)
)
```

`selectedType` 인자는 라벨("총 주도리"/"총 받도리") 분기를 위해 유지 — 색 분기에서만 제거.

검증:
1. **빌드** — `tuist install && tuist generate --no-open && xcodebuild build-for-testing -workspace Dori-iOS.xcworkspace -scheme DoriCalendar -destination 'id=<iPhone 16 UDID>'` exit 0
2. **스냅샷 신설** — `CalendarTotalAmountSnapshotTests` 신설 (judori/baddori × light/dark = 4장). 신설 결정은 A2-1 게이트에서 확정.
3. **Record 1회차** — "Automatically recorded snapshot" 자동 기록, exit 1 정상
4. **Replay 2회차** — exit 0, 4 PASS
5. **회귀 시나리오** — 1건 (예: amount 값 한 자리 변경 → diff 보고 → 원복)

커밋:
```bash
git add Projects/Feature/Calendar/Sources/Components/TotalAmountView.swift \
  Projects/Feature/Calendar/Tests/Snapshot/CalendarTotalAmountSnapshotTests.swift \
  Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/CalendarTotalAmountSnapshotTests/
git commit -m "feat(calendar): unify total amount card to bgSecondary regardless of selectedType"
```

### Phase C — DoriSegmentControl 통일 (커밋 2)

A2-3 결과 반영. 핵심 변경:

```swift
// before
.fill(selectedType == .judori ? .secondary : .textSecondary)
.foregroundStyle(selectedType == item ? .onBrand : .textPrimary)

// after (가설 — A2-3 확정값으로 대체)
.fill(.bgPrimary)  // contrast pill against bgSecondary container
.foregroundStyle(selectedType == item ? .textPrimary : .textSecondary)
```

검증: 기존 `DoriSegmentControlSnapshotTests` 의 baseline PNG 갱신.
1. 빌드
2. Record 1회차 — 기존 baseline 깨지면서 자동 갱신
3. Replay 2회차 — pass
4. 회귀 시나리오 1건

커밋:
```bash
git add Projects/Feature/Calendar/Sources/Components/DoriSegmentControl.swift \
  Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/DoriSegmentControlSnapshotTests/
git commit -m "feat(calendar): unify segment control indicator to bgPrimary"
```

### Phase D — CalendarGridView / DayCell 색 업그레이드 (커밋 3)

A2-4 결과 반영. 핵심 변경: **selectedType 분기 유지하되 judori 색을 `secondary` (#6482AD) → `brandMain` 으로 업그레이드**. baddori 는 `textSecondary` 그대로. non-today dot 은 single 회색으로 정리.

```swift
// before — CalendarDayCell
var isTodayCircleColor: Color {
  guard isToday else { return .clear }
  return selectedType == .judori ? UIAsset.Colors.secondary.color : UIAsset.Colors.textSecondary.color
}
var dotColor: UIAsset.Colors {
  return selectedType == .judori ? .secondary : .textSecondary
}

// after (가설 — A2-4 확정값으로 대체)
var isTodayCircleColor: Color {
  guard isToday else { return .clear }
  return selectedType == .judori
    ? UIAsset.Colors.brandMain.color
    : UIAsset.Colors.textSecondary.color
}
// today dot 만 selectedType 분기 — non-today dot 은 항상 textSecondary
var dotColor: UIAsset.Colors {
  guard isToday else { return .textSecondary }
  return selectedType == .judori ? .brandMain : .textSecondary
}
```

`selectedType` 인자 시그니처는 **변경 없음** — DayCell 이 여전히 selectedType 으로 색 결정.

검증: 기존 `CalendarGridSnapshotTests` baseline PNG 갱신. judori/baddori × light/dark = 4장 페어 검증.

커밋:
```bash
git add Projects/Feature/Calendar/Sources/Components/CalendarGridView.swift \
  Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/CalendarGridSnapshotTests/
git commit -m "feat(calendar): upgrade judori day cell highlight from secondary to brandMain"
```

### Phase E — MonthSelectorView 폰트 토큰화 + 통합 검증 (커밋 4 + push)

A2-2 결과 반영. SwiftUI 시스템 폰트 → pretendard 토큰 교체, chevron 색 명시.

```swift
// before
Image(systemName: "chevron.left").font(.title3).foregroundColor(.primary)
Text(currentMonth.koreanMonth).font(.title2).fontWeight(.semibold)

// after (가설 — A2-2 확정값으로 대체)
Image(systemName: "chevron.left")
  .font(.system(size: 16, weight: .semibold))  // 또는 figma 지정값
  .foregroundStyle(.textPrimary)
Text(currentMonth.koreanMonth)
  .pretendard(.body(.sb2))  // semibold 16
  .foregroundStyle(.textPrimary)
```

`MonthSelectorSnapshotTests` 신설 검토 (A2-2 게이트에서 확정).

`CalendarView.swift` 자체는 단순 합성이라 변경 없음. 다만 4개 컴포넌트 갱신 후 부모 렌더 회귀를 한번 확인:

```bash
xcodebuild test -workspace Dori-iOS.xcworkspace -scheme DoriCalendar \
  -only-testing:DoriCalendarTests -destination 'id=<UDID>'
# 전체 PASS
```

커밋 & push:
```bash
git add Projects/Feature/Calendar/Sources/Components/MonthSelectorView.swift \
  Projects/Feature/Calendar/Tests/Snapshot/MonthSelectorSnapshotTests.swift \
  Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/MonthSelectorSnapshotTests/
git commit -m "feat(calendar): apply pretendard tokens to month selector"
git push origin feat/51-calendar-redesign
```

#### Hook 루프 (CI 추적)

PLAN(1) Implementation 의 패턴 그대로:

```bash
RUN_ID=$(gh run list --branch feat/51-calendar-redesign --limit 1 \
  --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID" --exit-status
WATCH_EXIT=$?
if [ $WATCH_EXIT -ne 0 ]; then
  gh run view "$RUN_ID" --log-failed | tail -200
fi
gh pr checks <PR#>
```

#### Fail 분류 & 대응

| 원인 분류 | 예시 | 대응 |
|---|---|---|
| **Snapshot baseline 누락 commit** | `__Snapshots__/` 누락, CI runner "No reference" fail | git add 누락 확인 → 재커밋 → push |
| **시뮬레이터 픽셀 차이** | "Snapshot does not match reference" sub-pixel diff | CI iPhone 16 + Xcode 26.x 매칭 확인. 다른 환경에서 record 됐다면 동일 환경에서 re-record |
| **테스트 코드 컴파일 실패** | Snapshot Tests import 실수 | 로컬 빌드 검증 후 재push |
| **상위 컴포넌트 회귀** | `CalendarView` 가 어디선가 색 강제 | 본 PR 범위 (CalendarView 변경 0). 발생 시 즉시 차단 — 다른 변경이 섞임 |
| **범위 외** | macOS runner 다운, Xcode `latest-stable` 변경 | 로그 요약 보고 후 대기. 자동 수정 금지 |

루프는 **green 한 번 확인** 으로 종료.

## 3. When

- **순차 의존**: A → B → C → D → E. 각 Phase 의 검증 통과가 다음 게이트.
- **Phase A 가 외부 의존 게이트**: A1 (디자이너 확답) 과 A2 (피그마 inspect) 둘 다 user 가 채워야 진입 가능. **A 미통과 시 Phase B 진입 금지** — 가설로 구현 후 baseline 가 굳으면 디자이너 의도와 다른 색이 회귀 자동화에 영구 박힘 위험.
- **Snapshot-testing record/replay 2단**: PLAN(3) Implementation 의 패턴 그대로. 첫 record 의 exit 1 은 정상, **반드시 replay 2회차 통과 + 회귀 시나리오 1건** 까지 돌려야 baseline 신뢰.
- **각 Phase 의 PNG 는 commit 후 다음 Phase**. 커밋 안 하고 다음 phase 진입 금지.
- **Hook 루프**: `gh run watch --exit-status` 가 자체 블록.

## 4. 종료기준 (Definition of Done)

다음을 **모두** 만족해야 done.

### 일반 종료기준

- [ ] Phase A1 (디자이너 확답) 완료 — Q1~Q5 답변이 이 문서 검증 기록 에 인용 가능
- [ ] Phase A2 (피그마 inspect) 완료 — A2-1 ~ A2-4 모든 항목 채움 (또는 "현재 구현 유지" 명시)
- [ ] Phase B/C/D/E 각각의 컴파일 통과 + 스냅샷 record/replay 통과 + 회귀 시나리오 1건 통과
- [ ] `Projects/Feature/Calendar/Tests/Snapshot/__Snapshots__/` 의 모든 baseline PNG 가 0byte 이상, GitHub PR Files 탭에서 이미지로 렌더
- [ ] CI `Build App` workflow build · test step green
- [ ] `gh pr checks <PR#>` 전체 PASS
- [ ] 피그마 mockup ↔ 최종 baseline PNG 사람-눈 시각 대조 1회 통과 (divider 두께, 원형 셀 크기, 폰트 비율)
- [ ] PR description 에 "selectedType 분기 제거에 따른 의도된 baseline 갱신" 명시 + 회귀 시나리오 로그 첨부

### Snapshot-testing 특유 종료기준

- [ ] 각 phase 마다 첫 실행 로그에 "Automatically recorded snapshot" 메시지 출력
- [ ] 각 phase 마다 2회차 실행 exit 0
- [ ] 각 phase 마다 회귀 시나리오 — 의도적 mock state 변경 → diff 보고 → 원복 후 다시 pass

### 검증 기록 (완료 시 채움)

#### Phase A1 — 디자이너 확답

- Q1 (TotalAmount 색 selectedType 분기): _(채울 자리)_
- Q2 (Segment indicator 색 selectedType 분기): _(채울 자리)_
- Q3 (DayCell 오늘 강조 selectedType 분기): _(채울 자리)_
- Q4 (DayCell dot selectedType 분기): _(채울 자리)_
- Q5 (selectedType 전환 시 시각 피드백 위치): _(채울 자리)_

#### Phase A2 — 피그마 spec

- A2-1 `CalendarTotalAmountView` inspect 결과: _(채울 자리)_
- A2-2 `MonthSelectorView` inspect 결과: _(채울 자리)_
- A2-3 `DoriSegmentControl` inspect 결과: _(채울 자리)_
- A2-4 `CalendarGridView` / `CalendarDayCell` inspect 결과: _(채울 자리)_

#### Phase B/C/D/E — 코드 변경 통합 검증

코드 변경은 phase 단위로 적용했으나 빌드/스냅샷 검증은 4 phase 의 결과가 단일 `FeatureCalendar` 스킴에 합쳐져 한 번에 검증.

- **Phase B 변경**: `selectedType` 분기 제거. `.foregroundStyle(.textSecondary)` (label) + `.foregroundStyle(.textPrimary)` (amount) + `.fill(.bgSecondary)` (카드).
- **Phase C 변경**: 선택 pill `.fill(.bgPrimary)` 단일. 선택 텍스트 `.textPrimary`, 비선택 텍스트 `.textSecondary`.
- **Phase D 변경 (2026-06-06 디자이너 Q4 확답 반영 정정 후)**: `selectedType` 분기 유지. `isTodayCircleColor` 의 judori 가지를 `secondary` → `brandMain` 교체. `dotColor` 는 **today 가드 없이** judori → `brandMain` / baddori → `textSecondary` (모든 current-month dot 이 selectedType 분기). 초기 코드는 today 가드를 둔 잘못된 가설이었으나 정정 완료.
- **Phase E 변경**: `import DoriDesignSystem` 추가. "5월" 텍스트 `.pretendard(.body(.sb2))` + `.foregroundStyle(.textPrimary)`. chevron `.font(.system(size: 16, weight: .semibold))` + `.foregroundStyle(.textPrimary)`.

- **빌드 로그**:
  ```
  xcodebuild build -workspace Dori-iOS.xcworkspace -scheme DoriApp -destination 'id=8040555B-0993-497F-AB25-AA998E428899'
  ** BUILD SUCCEEDED **
  ```

- **Record 로그** (1회차, stale baseline 6장 삭제 후):
  ```
  Test Suite 'CalendarGridSnapshotTests' — 2 failures (Automatically recorded snapshot ×2)
  Test Suite 'DayDetailSheetSnapshotTests' passed — 0 failures (색 미변경, 회귀 없음)
  Test Suite 'DoriSegmentControlSnapshotTests' — 4 failures (Automatically recorded snapshot ×4)
  Executed 8 tests, 6 failures (의도된 첫 record), exit 1
  ```

- **Replay 로그** (2회차, 새 baseline 으로):
  ```
  Test Suite 'CalendarGridSnapshotTests' passed — 2/2
  Test Suite 'DayDetailSheetSnapshotTests' passed — 2/2
  Test Suite 'DoriSegmentControlSnapshotTests' passed — 4/4
  Executed 8 tests, 0 failures
  ** TEST SUCCEEDED **
  ```

- **회귀 시나리오 로그** (detection alive 증명):
  ```
  의도적 변경: DoriSegmentControl 의 선택 pill cornerRadius 10 → 5
  → DoriSegmentControlSnapshotTests 4/4 fail
  → "Snapshot does not match reference. Newly-taken snapshot does not match reference."
  원복 (cornerRadius 5 → 10)
  → DoriSegmentControlSnapshotTests 4/4 pass
  ** TEST SUCCEEDED **
  ```

- **시각 대조 (Light)**: ✓ 새 baseline `test_calendarGrid_emptyMonth_light` 가 figma mockup 과 매치
  - bgSecondary 카드 + textSecondary 라벨 + textPrimary amount
  - 흰색 pill (bgPrimary) + "주도리" textPrimary / "받도리" textSecondary dimmed
  - "5월" + chevron textPrimary 통일
  - FAB navy (BrandMain light)
- **시각 대조 (Dark)**: ✓ 새 baseline `test_calendarGrid_emptyMonth_dark` 가 figma mockup 과 매치
  - 어두운 회색 카드 + light 텍스트
  - 다크 pill + 적절한 dimmed
  - FAB brand blue (BrandMain dark)

**미검증 영역**:
- `CalendarGridSnapshotTests` 는 `emptyMonth` 케이스만 있어 Phase D 의 DayCell 색 업그레이드(judori 강조 = brandMain) 가 baseline 으로 굳지 않음. dotColor 정정도 동일 — emptyMonth 에는 dot 자체가 없음. 후속 작업: populated month (today highlight + 이벤트 dot 다수) 케이스 신설 권장.
- **알림 종 아이콘** (Q5 light/judori mockup 의 navigation bar 우측): notification 액션 추가 — 본 PR 범위 외. 별건 PR 에서 `DoriNavigationBarConfig.titleWithActions` 또는 별도 trailing item 으로 처리.

#### CI

- CI green run URL: _(채울 자리)_
- `gh pr checks <PR#>` 결과: _(채울 자리)_

#### 피그마 ↔ Baseline 시각 대조

- 사람-눈 대조 결과: _(채울 자리)_

## 사용한 기존 자산

- [`PLAN.md`](./PLAN.md)
- [`../../supportDarkMode/testingDarkMode/Implementation.md`](../../supportDarkMode/testingDarkMode/Implementation.md) — record/replay 2단 검증 + Hook 루프 + Fail 분류 패턴
- [`../../supportDarkMode/validateDarkMode/Implementation.md`](../../supportDarkMode/validateDarkMode/Implementation.md) — Phase 구조 + CI 추적 패턴
- `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Semantic/BrandMain.colorset` — light=`#20346F` / dark=`#6C8FF0`, 신규 강조 색의 출처 (신설 없음)
- `Projects/Core/DoriDesignSystem/Sources/Typography/TypoStyle.swift` — pretendard 토큰 enum 매핑
- `Projects/Feature/Calendar/Tests/Snapshot/` — 기존 3 TC (CalendarGrid, DayDetailSheet, DoriSegmentControl)
- `Projects/Core/DoriDesignSystem/Tests/Snapshot/Helpers/SnapshotPair.swift` — PLAN(2) 머지 후 사용 가능. 머지 전이면 두 함수 명시 패턴
