# Implementation — (2) assertSnapshotPair Helper

> 짝 문서: 같은 경로의 [`PLAN.md`](./PLAN.md)
> 대상 PR: `feat/47-snapshot-pair` (base `feat/47-dark-mode-support` — PLAN(1) PR #48 merge 후 develop 으로 rebase)

## 1. What

PLAN.md 의 In-scope 를 산출물 중심으로 재기술.

### 신규 파일
- `Projects/Core/DoriDesignSystem/Tests/Snapshot/Helpers/SnapshotPair.swift` — `assertSnapshotPair` 헬퍼
- `docs/decision/supportDarkMode/snapshotPair/{PLAN.md, Implementation.md}` — 본 문서 페어

### 수정 파일
- `docs/frontend/test-strategy.md` — Stable Rules 에 페어 검증 1줄 + 헬퍼 위치 명시

### 산출물 (검증 결과)
- 로컬 build-for-testing 성공 로그 (DoriDesignSystemTests 컴파일 OK)
- 헬퍼 smoke TC 의 record 결과 (light/dark 2장 PNG 자동 생성 후 정리)
- CI green run URL

### Scope 외
- 기존 4개 TC 마이그레이션 — 별도 PR
- `DoriTestSupport` 이전 — PLAN(3) 합류 시점
- `.preferredColorScheme(.light)` 제거

## 2. How

3페이즈 순차.

### Phase A — 헬퍼 작성 (커밋 1)

`SnapshotPair.swift` 신설. 핵심 요점:
- `@autoclosure` 로 view-builder 한 번만 평가 후 두 trait 으로 재사용
- `@MainActor` 로 UIKit Trait 접근 안전성 보장
- `named: "light"` / `named: "dark"` 으로 baseline 파일명 충돌 방지
- 모든 source location 인자 (`fileID`, `file`, `testName`, `line`, `column`) 전달하여 실패 메시지가 호출자 함수로 안내

### Phase B — 로컬 smoke 검증 (no commit)

1. `tuist install && tuist generate --no-open`
2. `xcodebuild build-for-testing -workspace Dori-iOS.xcworkspace -scheme DoriDesignSystem -destination 'id=<iPhone 16 UDID>'` 로 컴파일 확인
3. 임시 TC 1개 추가 후 record/replay:
   ```swift
   func test_pairHelper_smoke() {
     assertSnapshotPair(of: PrimaryButton(title: "smoke").padding(16).frame(width: 200))
   }
   ```
   - 1회차: "No reference" 로 PNG 2장 자동 기록
   - 2회차: exit 0
4. 검증 완료 후 임시 함수 + 생성 PNG 삭제. **커밋에 포함하지 않는다.**

### Phase C — 문서 + push (커밋 2)

`docs/frontend/test-strategy.md` Stable Rules 에 1줄, PLAN/Implementation 문서 같은 커밋. push.

#### Hook 루프

```bash
git push origin feat/47-snapshot-pair
RUN_ID=$(gh run list --branch feat/47-snapshot-pair --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch "$RUN_ID" --exit-status
```

build/test green 이면 done. fail 분류는 PLAN(1) Implementation 의 표 그대로.

## 3. When

- **순차 의존**: A → B → C
- **smoke 결과는 커밋 외**: 임시 TC/PNG 가 PR 에 새지 않도록 검증 직후 정리
- **기존 baseline 비건드림**: 헬퍼는 새 TC 만 쓰기 때문에 기존 16장 PNG 는 변경 0. 이 분리가 PR review 의 핵심 안전선
- **base branch**: PLAN(1) 의 swift-snapshot-testing 의존성에 의존하므로 PR #48 머지 전까진 base 가 `feat/47-dark-mode-support`. PR #48 머지 후 develop 으로 rebase

## 4. 종료기준 (Definition of Done)

- [ ] `Projects/Core/DoriDesignSystem/Tests/Snapshot/Helpers/SnapshotPair.swift` 생성, 빌드 통과
- [ ] 로컬 smoke TC 로 light/dark PNG 2장 자동 기록 확인 (검증 후 삭제)
- [ ] `docs/frontend/test-strategy.md` 에 헬퍼 규칙 1줄 명시
- [ ] PR CI 의 build · test step green
- [ ] 기존 4개 TC 의 baseline PNG 파일명/내용 변경 0건
- [ ] 본 Implementation.md "검증 기록" 에 CI URL 첨부

### 검증 기록 (완료 시 채움)

- 컴파일 로그: _(채울 자리)_
- smoke record 로그: _(채울 자리)_
- CI green run URL: _(채울 자리)_

## 사용한 기존 자산

- [`PLAN.md`](./PLAN.md)
- `../validateDarkMode/Implementation.md` — Phase/Hook 루프 패턴 참조
- `Projects/Core/DoriDesignSystem/Tests/Snapshot/PrimaryButtonSnapshotTests.swift` — 헬퍼가 대체할 기존 패턴
- swift-snapshot-testing 1.18+ `assertSnapshot(of:as:named:...)` — `named:` 인자 동작
- `Tuist/Package.swift` — swift-snapshot-testing 1.18.0 이미 등록 (PLAN(1) PR #48)
