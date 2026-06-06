# Dark Mode Validation — (2) assertSnapshotPair Helper

## Context

다크모드 검증 자동화의 3단계 중 2단계.
- (1) Asset Lint — 완료 (`../validateDarkMode/PLAN.md`, PR #48)
- (2) **`assertSnapshotPair` 헬퍼** — 본 PLAN
- (3) Feature 모듈 카탈로그 스냅샷 페어 — 별도 PLAN (`../testingDarkMode/PLAN.md`)

`DoriDesignSystem/Tests/Snapshot/*` 의 4개 TC 가 light/dark 두 함수로 분리돼 있다.

```swift
func test_enabled_light() {
  assertSnapshot(
    of: host { PrimaryButton(title: "저장") },
    as: .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light))
  )
}

func test_enabled_dark() {
  assertSnapshot(
    of: host { PrimaryButton(title: "저장") },
    as: .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
  )
}
```

PLAN(3) 카탈로그가 같은 패턴을 그대로 늘리면 ~106장이 1개 화면당 두 함수 × view-builder 중복으로 확산된다. 한쪽만 추가하고 다른 쪽을 잊는 사각지대도 생긴다.

이 PLAN 은 **"light/dark 페어 보장"** 을 한 호출에 강제하는 얇은 헬퍼만 도입한다. 기존 4개 TC 의 마이그레이션과 PLAN(3) 의 신규 카탈로그 작성은 별도 작업.

## Scope

### In scope
- `assertSnapshotPair` 헬퍼 신설 (`Projects/Core/DoriDesignSystem/Tests/Snapshot/Helpers/SnapshotPair.swift`)
- `named:` 인자로 light/dark suffix 부여 → baseline 파일명 충돌 방지
- `docs/frontend/test-strategy.md` 에 페어 검증 규칙 1줄 명문화 → 미래 에이전트가 패턴을 잊지 않게

### Out of scope (별도 작업)
- 기존 4개 TC (`ColorTokenSnapshotTests`, `PrimaryButtonSnapshotTests`, `DoriCommonAlertSnapshotTests`, `DoriToastViewSnapshotTests`) 의 마이그레이션 — baseline 재기록 비용 별도 PR
- `DoriTestSupport` 모듈로 헬퍼 이전 — PLAN(3) Phase B 합류 시
- Feature 카탈로그 작성 — PLAN(3)

## Approach

### A. 헬퍼 시그니처

```swift
@MainActor
func assertSnapshotPair<V: View>(
  of view: @autoclosure () -> V,
  layout: SwiftUISnapshotLayout = .sizeThatFits,
  record: Bool? = nil,
  fileID: StaticString = #fileID,
  file: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column
)
```

내부적으로 `assertSnapshot(of:as:named:...)` 을 두 번 호출 — `named: "light"` / `named: "dark"`. `testName` 그대로 전달하여 호출자-함수-기반 baseline 디렉토리 규칙 유지.

### B. baseline 파일명 규칙

- 기존 (별도 함수 × 2): `__Snapshots__/PrimaryButtonSnapshotTests/test_enabled_light.1.png`
- 신규 (페어 헬퍼): `__Snapshots__/<TestClass>/test_enabled.light-<n>.png` (정확한 포맷은 swift-snapshot-testing 1.18+ `named:` 동작)

헬퍼는 새 TC 만 만들면 기존 baseline 과 충돌하지 않음.

### C. 문서화

`docs/frontend/test-strategy.md` 의 Stable Rules 에 1줄 추가:

> 다크모드를 그리는 View 스냅샷은 light/dark 한 쌍으로만 baseline 을 생성한다. 헬퍼는 `Projects/Core/DoriDesignSystem/Tests/Snapshot/Helpers/SnapshotPair.swift` 의 `assertSnapshotPair`.

AGENTS.md Read Order 에 `docs/frontend/test-strategy.md` 가 이미 포함돼 있어 변경 없음.

## Files

| 작업 | 경로 |
|---|---|
| Create | `Projects/Core/DoriDesignSystem/Tests/Snapshot/Helpers/SnapshotPair.swift` |
| Modify | `docs/frontend/test-strategy.md` |
| Create | `docs/decision/supportDarkMode/snapshotPair/PLAN.md` |
| Create | `docs/decision/supportDarkMode/snapshotPair/Implementation.md` |

## Verification

1. **빌드 통과** — `tuist generate && xcodebuild build-for-testing -scheme DoriDesignSystem` 컴파일 OK
2. **헬퍼 smoke** — 임시 TC 1개로 light/dark PNG 2장 자동 기록 확인 후 정리 (커밋 제외)
3. **기존 baseline 무손상** — 마이그레이션 안 함. 기존 16장 PNG 파일명/내용 변경 0건
4. **CI green** — PR push 후 Build App workflow build/test step 통과

## Out of Scope but Tracked

- 기존 4개 TC 마이그레이션 — 헬퍼 안정성 확인 후 별도 PR. baseline 재기록 + diff 0건 검증 필요.
- `DoriTestSupport` 이전 — PLAN(3) Phase B 합류 시 모듈로 이동, feature 테스트 import.
- `.preferredColorScheme(.light)` 제거 — (1)(2)(3) 전부 완료 + 카탈로그 다크 스냅샷 전수 통과 후.
