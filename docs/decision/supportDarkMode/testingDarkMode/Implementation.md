# Implementation — (3) Feature 카탈로그 스냅샷

> 짝 문서: 같은 경로의 [`PLAN.md`](./PLAN.md)
> 대상 PR: (TBD — `feat/{이슈}-dark-mode-snapshot-catalog`)

## 1. What

PLAN.md 의 Scope (P0+P1+P2 ≈ 106장) 를 산출물 중심으로 재기술.

### 신규 파일
- `Tuist/ProjectDescriptionHelpers/DoriTargets.swift` 수정 동반의 — `Projects/Core/DoriTestSupport/Sources/Mocks/Dori+Mock.swift`
- `Projects/Core/DoriTestSupport/Sources/Mocks/Partner+Mock.swift` 외 도메인 모델별 `+Mock.swift`
- `Projects/Core/DoriTestSupport/Sources/Clients/*+MockValue.swift` (누락 client 보강 시)
- 피처별 스냅샷 테스트 파일 약 12개 (`Projects/Feature/{X}/Tests/Snapshot/*SnapshotTests.swift`)
- 베이스라인 PNG 약 106장 (`Projects/Feature/{X}/Tests/Snapshot/__Snapshots__/{Y}SnapshotTests/{case}.1.png`)

### 수정 파일
- `Tuist/ProjectDescriptionHelpers/DoriTargets.swift` — `DoriModules.testSupport` 케이스 추가
- `Projects/Core/Project.swift` — `.doriFramework(DoriModules.testSupport.module, dependencies: [DoriModules.core.module.projectDependency])` target 추가
- `Projects/Feature/Project.swift` — Onboarding/AddDori/Calendar/MyPage 의 `.doriUnitTests` 4개 신설, History 의 기존 unit test deps 에 `.external(.snapshotTesting)`, `.testSupport` 추가
- 누락된 client `previewValue`/`mockValue` (Phase A 점검 결과에 따라 결정)

### 산출물 (검증 결과)
- record 1회차 로그 ("Automatically recorded snapshot" + exit code 1 = snapshot-testing 의 의도된 첫 실행 동작)
- replay 2회차 로그 (0 fail)
- 회귀 시나리오 로그 — 의도적 mock 변경 → diff 보고 → 원복
- CI green run URL — 4개 신설 테스트 타깃 모두 실행
- `gh pr checks <PR#>` 전체 PASS

### Scope 외 (이 문서에서 다루지 않음)
- `assertSnapshotPair` 헬퍼 도입 — (2) PLAN 별도
- `.preferredColorScheme(.light)` 제거 — (1)(2)(3) 완료 후 별도 PR
- 부모합성 모달/시트 스냅샷 — PLAN.md 에서 "단독" 으로 결정
- 모든 client mockValue 의 grounds-up 정비 — 본 PLAN 에 필요한 것만 추가

## 2. How

5페이즈 순차. swift-snapshot-testing 의 **record/replay 2단계 특성**을 명시하고 각 페이즈에서 검증.

### Phase A — Prerequisites 확인 (커밋 0건, 검증만)

코드 변경 없이 게이트 통과 확인.

1. validateDarkMode (1) PLAN 머지 여부 확인 — `Brand/Secondary.colorset` 에 dark appearance 존재
   ```bash
   cat Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Brand/Secondary.colorset/Contents.json \
     | python3 -c 'import sys,json; print(any("dark" in str(a) for a in json.load(sys.stdin)["colors"]))'
   # → True 면 통과
   ```
2. iPhone 16 시뮬레이터 UDID 확인 (DoriDesignSystem 스냅샷과 동일)
   ```bash
   xcrun simctl list devices available | grep "iPhone 16 ("
   ```
3. TCA Feature client mockValue 정의 여부 grep
   ```bash
   grep -rn "previewValue\|mockValue" Projects/Core/DoriCore/Sources/Clients \
     Projects/Feature/*/Sources/Clients 2>/dev/null
   ```
   누락 client 목록을 Phase B 에서 보강할 대상으로 기록.

게이트:
- (1) 머지 안 됐으면 본 PLAN 시작 금지. brand secondary 의 다크 변색이 baseline 으로 굳으면 검증 가치 0.

### Phase B — DoriTestSupport 모듈 신설 (커밋 1)

`DoriModules` enum 에 케이스 추가 → `Projects/Core/Project.swift` 에 target 추가 → mock factory 작성.

도메인 모델 mock 패턴 (예: `Dori+Mock.swift`):
```swift
import DoriCore

public extension Dori {
  static let mock = Dori(
    doriId: 100, userId: 1, partnerId: 100,
    direction: .judori, partnerName: "조카 1",
    relationship: "가족", eventType: "생일",
    amount: 50_000, eventDate: "2025-05-01",
    isVisited: true, memo: "",
    createdAt: "2026-02-17T09:00:00"
  )

  static let mockList: [Dori] = (0..<5).map { i in
    Dori(doriId: 100+i, ..., partnerName: "파트너 \(i)", ...)
  }
}
```

Phase A 에서 식별된 누락 client mockValue 도 같이 보강.

검증:
```bash
tuist install && tuist generate --no-open
xcodebuild build -workspace Dori-iOS.xcworkspace -scheme DoriTestSupport \
  -destination 'id=<iPhone 16 UDID>' | tail
```

커밋:
```bash
git add Tuist/ProjectDescriptionHelpers/DoriTargets.swift \
  Projects/Core/Project.swift Projects/Core/DoriTestSupport/
git commit -m "chore: add DoriTestSupport module with domain mock factories"
```

### Phase C — 4개 unit test target 신설 (커밋 2)

`Projects/Feature/Project.swift` 에 `.doriUnitTests` 4개 추가, 각 deps 에 `.external(.composableArchitecture)`, `.external(.snapshotTesting)`, `DoriModules.testSupport.module.projectDependency`. History 기존 target 의 deps 에도 동일 추가.

검증 (빈 테스트 클래스라도 컴파일 통과):
```bash
tuist generate --no-open
for scheme in DoriOnboarding DoriAddDori DoriCalendar DoriMyPage DoriHistory; do
  xcodebuild build -workspace Dori-iOS.xcworkspace -scheme "${scheme}Tests" \
    -destination 'id=<iPhone 16 UDID>' | tail -3
done
```

커밋:
```bash
git add Projects/Feature/Project.swift
git commit -m "chore: scaffold snapshot test targets for 4 feature modules"
```

### Phase D — 카탈로그 작성 + Record/Replay 루프 (커밋 3~5)

P0 → P1 → P2 각 tier 별로 같은 패턴 반복.

#### D1: P0 — Root view (커밋 3)

1. 6개 TC 파일 작성 (`SplashSnapshotTests`, `IntroSnapshotTests`, `AddDoriRootSnapshotTests`, `CalendarGridSnapshotTests`, `DoriListSnapshotTests`, `MyPageSnapshotTests`)
2. **Record 1회차** — baseline 없으면 자동 생성 + 모든 TC fail 로 표기 (snapshot-testing 의 의도된 동작):
   ```bash
   xcodebuild test -workspace Dori-iOS.xcworkspace -scheme DoriOnboarding \
     -only-testing:DoriOnboardingTests -destination 'id=<UDID>' 2>&1 | tail
   # 로그: "No reference was found on disk. Automatically recorded snapshot..."
   # exit code: 1 (정상)
   # PNG: __Snapshots__/SplashSnapshotTests/test_splash.1.png 등 자동 생성
   ```
3. **Replay 2회차** — 같은 명령 재실행. 이번엔 모든 TC pass 해야 정상:
   ```bash
   xcodebuild test -workspace Dori-iOS.xcworkspace -scheme DoriOnboarding \
     -only-testing:DoriOnboardingTests -destination 'id=<UDID>' 2>&1 | tail
   # exit code: 0
   ```
4. baseline PNG git add + 커밋:
   ```bash
   git add Projects/Feature/Onboarding/Tests/Snapshot \
     Projects/Feature/AddDori/Tests/Snapshot \
     Projects/Feature/Calendar/Tests/Snapshot \
     Projects/Feature/History/Tests/Snapshot \
     Projects/Feature/MyPage/Tests/Snapshot
   git commit -m "test: P0 dark-mode snapshot baselines (6 TC × light/dark = 12)"
   ```
5. **회귀 시나리오** — 정확성 증거. 임의 1건 mock state 약간 변경 → replay → diff 보고 확인 → 원복:
   ```bash
   # 예: SplashSnapshotTests 의 mock 메시지 한 글자 변경
   # 재실행 → fail with diff
   # 원복 → 재실행 → pass
   ```

#### D2: P1 — 주요 state 분기 (커밋 4)
17 TC × 2 = 34장. D1 과 동일 패턴 (record → replay → 커밋 → 회귀 시나리오).

#### D3: P2 — 전체 카탈로그 (커밋 5)
~30 TC × 2 = ~60장. 동일.

### Phase E — CI 통합 + Hook 루프

`.github/workflows/build.yml` 의 test step 이 신설 4개 scheme 을 자동 픽업하는지 확인. 보통 `xcodebuild test -workspace` 전체 실행이면 추가 작업 없음. 누락 시 `-scheme` 또는 `-only-testing` 옵션 보강.

push & 추적:
```bash
git push origin <branch>
RUN_ID=$(gh run list --branch <branch> --limit 1 --json databaseId --jq '.[0].databaseId')
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
| **Snapshot baseline 누락 commit** | `__Snapshots__/` 가 git add 안 됐고 CI runner 가 새로 record 시도 → "No reference" fail | 로컬에서 git add 누락 확인 → 재커밋 → push |
| **시뮬레이터 픽셀 차이** | "Snapshot does not match reference" with sub-pixel diff | CI macOS runner 의 iPhone 16 + Xcode 26.x 매칭 확인. 다른 머신에서 record 됐다면 동일 환경에서 re-record |
| **테스트 코드 컴파일 실패** | mock factory public 접근 실수, missing import | 로컬 빌드 검증 후 재push |
| **TCA / strict concurrency 회귀** | Sendable 류 에러 | PR1 의 TCA 1.25.5 bump 이후 발생하면 별건 — 별도 PR 로 처리 |
| **범위 외** | macOS runner 다운, Xcode `latest-stable` 변경 | 로그 요약 보고 후 대기. 자동 수정 금지 |

루프는 **green 한 번 확인** 으로 종료. snapshot 만 green 이고 build/test 가 fail 인 부분 성공도 fail 로 간주.

## 3. When

- **순차 의존**: A → B → C → D1 → D2 → D3 → E. 각 phase 의 검증 통과가 다음 게이트.
- **Phase A 의 게이트**: validateDarkMode (1) PLAN 머지 안 됐으면 본 PLAN 시작 금지.
- **Snapshot-testing 의 record/replay 2단 검증** — 가장 중요한 특성:
  - **첫 record 의 exit 1 은 정상**. 새 PNG 가 디스크에 떨어졌으면 의도된 동작.
  - **반드시 replay 2회차 까지 돌려 통과해야** baseline 신뢰 가능. 1회차만 보고 끝나면 깨진 baseline 이 영구 박힐 위험 — 그 baseline 이 어떻게 보이는지 사람 눈이 검토한 적 없음.
  - replay 2회차 통과 후에도 **회귀 시나리오 (의도적 fail) 1건 확인** 으로 detection 정확성 검증.
- **각 phase 의 PNG 는 git commit 이후 다음 phase**. 푸시 안 한 채 다음 phase 들어가지 말 것.
- **Hook 루프**: `gh run watch --exit-status` 가 자체 블록. 사람 timeout 없이 CI 종료까지 기다림.
- **D1 → D2 → D3 의 cadence**: 한 tier 가 record/replay/회귀 시나리오 3중 검증 통과해야 다음 tier. 한 번에 106장 record 후 일괄 검증은 금지 — 어느 layer 가 깨졌는지 분리 불가.

## 4. 종료기준 (Definition of Done)

다음을 **모두** 만족해야 done.

### 일반 종료기준
- [ ] Phase A 게이트 통과 — validateDarkMode (1) PLAN 머지 완료, `Brand/Secondary.colorset` 에 dark appearance 존재
- [ ] `DoriTestSupport` 모듈 빌드 성공, 외부 import 가능
- [ ] 4개 신설 테스트 타깃 (DoriOnboardingTests, DoriAddDoriTests, DoriCalendarTests, DoriMyPageTests) 컴파일 통과 + 기존 DoriHistoryTests 도 deps 보강 후 통과
- [ ] P0 12장 baseline PNG 생성 + replay 통과
- [ ] P1 34장 추가 baseline + replay 통과
- [ ] P2 ~60장 추가 baseline + replay 통과 (누계 ~106장)
- [ ] CI 의 `Build App` 워크플로 에서 신설 테스트 타깃 모두 실행 + green
- [ ] `gh pr checks <PR#>` 전체 PASS
- [ ] 최종 CI run URL 이 이 문서 "검증 기록" 섹션 에 첨부

### Snapshot-testing 특유 종료기준

- [ ] **Record 단계 증거**: 각 tier 의 첫 실행 로그에서 "Automatically recorded snapshot" 메시지가 모든 신규 TC 에 대해 출력됨 (자동 생성 실패는 file system 권한 / 디스크 가득 등의 이슈)
- [ ] **Replay 단계 증거**: 각 tier 의 2회차 실행 exit code 0, 0 fail
- [ ] **PNG 무결성**: 모든 baseline PNG 가 0byte 이상, GitHub PR Files 탭 에서 이미지로 렌더됨 (raw binary 가 아닌)
- [ ] **회귀 정확성**: 각 tier 마다 의도적 fail 시나리오 1건 — mock state 살짝 변경 → snapshot diff 보고됨 → 원복 후 다시 pass. snapshot-testing 의 detection 이 살아있다는 증거.
- [ ] **device-pinning 일관성**: CI runner 의 시뮬레이터 디바이스(iPhone 16) + Xcode 26.x 가 로컬 baseline 생성 환경과 일치. 다른 환경에서 baseline 깨지면 그것이 회귀가 아니라 환경 차이임을 분리 보고할 수 있는 가설 기록 남김.

### 검증 기록 (완료 시 채움)

- Phase A 게이트 통과 증거:
  ```
  1. Brand/Secondary.colorset has dark variant: True (validateDarkMode (1) 머지 확인됨)
  2. iPhone 16 simulator: 8040555B-0993-497F-AB25-AA998E428899
  3. TCA client previewValue 점검 — 9개 중 6개 존재. 누락 3개:
     - AuthTokenStoreClient (liveValue + testValue 만)
     - KakaoServerLoginClient (liveValue + testValue 만)
     - UserNotificationSettingsClient (liveValue + testValue 만)
     → Phase B 에서 보강
  ```
- Phase B DoriTestSupport 빌드 로그: _(채울 자리)_
- Phase C 4개 unit test target 컴파일 로그: _(채울 자리)_
- Phase D1 (P0) record 로그: _(채울 자리)_
- Phase D1 replay 로그: _(채울 자리)_
- Phase D1 회귀 시나리오 로그 (fail → 원복 → pass): _(채울 자리)_
- Phase D2 (P1) record/replay/회귀 로그: _(채울 자리)_
- Phase D3 (P2) record/replay/회귀 로그: _(채울 자리)_
- CI green run URL: _(채울 자리)_
- `gh pr checks <PR#>` 결과: _(채울 자리)_

## 사용한 기존 자산

- [`PLAN.md`](./PLAN.md) — Scope/카탈로그/Risk 원본
- [`../validateDarkMode/Implementation.md`](../validateDarkMode/Implementation.md) — 본 문서 구조 참조 (Phase/Hook 루프/Fail 분류 패턴)
- `Projects/Core/DoriDesignSystem/Tests/Snapshot/` — 컴포넌트 스냅샷 선행 예시 (assertSnapshot API, traits, layout 설정)
- `Projects/Feature/History/Tests/SearchFeatureTests.swift` — 인라인 mock 패턴 (DoriTestSupport 로 이전 대상)
- `Tuist/Package.swift` — `swift-snapshot-testing` 1.18+ 이미 등록 (1.19.2 resolved)
- `Tuist/ProjectDescriptionHelpers/Target+Extension.swift` — `doriUnitTests` 헬퍼
- `Tuist/ProjectDescriptionHelpers/TargetDependency+Extension.swift` — `DoriDependency.snapshotTesting`
- `.github/workflows/build.yml` — CI test step 위치
