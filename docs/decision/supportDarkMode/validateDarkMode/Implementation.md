# Implementation — (1) Asset Lint

> 짝 문서: 같은 경로의 [`PLAN.md`](./PLAN.md)
> 대상 PR: [do-ri/iOS#48](https://github.com/do-ri/iOS/pull/48) (base `develop`, head `feat/47-dark-mode-support`)

## 1. What

PLAN.md 의 In-scope 를 산출물 중심으로 재기술.

### 신규 파일
- `Scripts/lint_color_assets.py` — Python 3 표준 라이브러리 기반 정적 lint 스크립트
- `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Brand/KakaoYellow.colorset/Contents.json` — 카카오 옐로 `#FEE500` light/dark 동일 정의

### 수정 파일
- `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Brand/Secondary.colorset/Contents.json` — dark appearance 추가 (RGB == light)
- `.github/workflows/build.yml` — "Generate workspace" 다음에 "Lint color assets" step 삽입

### 산출물 (검증 결과)
- 로컬 lint 실행 로그 (결함 정리 전 fail · 정리 후 pass · 회귀 시나리오 fail 의 3종)
- PR #48 의 최신 GitHub Actions run URL — 모든 step green

### Scope 외 (이 문서에서 다루지 않음)
- 카카오 버튼 코드가 `DoriColors.kakaoYellow` 를 실제로 참조하도록 리팩터
- pre-commit hook / Tuist build phase 통합
- `assertSnapshotPair` 헬퍼 ((2) PLAN)
- Feature 모듈 카탈로그 다크 스냅샷 ((3) PLAN)
- `.preferredColorScheme(.light)` 제거 ((2)(3) 완료 후)

## 2. How

4페이즈 순차 진행. 각 페이즈는 자체 git 커밋을 가지며, **Phase D 의 push 한 번으로 lint 3커밋이 함께 CI 트리거** 된다.

### Phase A — 베이스라인 정리 (커밋 0)

현재 working tree 에 lint 와 무관한 변경이 섞여 있다. 분리 안 하면 PR review 가 더러워지고 CI fail 시 원인 격리가 어렵다.

대상:
- Modified: `AGENTS.md`, `ARCHITECTURE.md`, `Projects/App/Sources/DoriApp.swift`, `README.md`, `docs/core/directory-structure.md`
- Deleted: `docs/core/constitution.md`, `docs/core/feature-spec.md`, `docs/core/project-overview.md`
- Added: `docs/decision/supportDarkMode/validateDarkMode/{PLAN.md, Implementation.md}`
- Ignored: `build/` (`.gitignore` 에 이미 포함 가정)

순서:
1. `git status` 로 대상 재확인
2. `git add` 로 위 파일들 스테이징 (build/ 제외)
3. `git commit -m "chore: refresh docs and stage dark-mode work prep"`
4. `git push origin feat/47-dark-mode-support`
5. CI green 확인 (아래 "Hook 루프" 참조). green 이면 Phase B 진입. fail 이면 이 페이즈 안에서 해결.

### Phase B — 로컬 구현 & 검증 (커밋 1)

`Scripts/lint_color_assets.py` 작성. 핵심 룰:

| 카테고리 | 룰 |
|---|---|
| `Brand/` | dark appearance 존재 |
| `Brand/` | dark RGB == light RGB (정규화 후 비교) |
| `Semantic/` | dark appearance 존재 |

구현 요점:
- 입력 루트: `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/`
- 순회: `**/*.colorset/Contents.json`
- 색상 정규화: `components.red/green/blue` 가 `0xFF` 형식이면 16진수 → 정수, `0.500` 형식이면 0~1 실수 → 반올림 정수
- 색공간 불일치(`color-space` 가 다름) 도 mismatch 로 fail
- 첫 위반에서 abort 하지 말고 전체 순회 후 stderr 에 위반 전체 + 위반 개수 출력, exit 1
- pip 의존성 0 (json/pathlib/sys 만)

로컬 검증 (스크립트만, 데이터는 아직 그대로):
```bash
python3 Scripts/lint_color_assets.py
# → "Brand/Secondary.colorset is missing dark appearance" 보고 + exit 1
echo $?  # → 1
```

회귀 시나리오 (스크립트 정확성 증거):
```bash
# Semantic 의 dark 일시 제거
# (Edit 또는 임시 git stash)
python3 Scripts/lint_color_assets.py
# → "Semantic/BgPrimary.colorset is missing dark appearance" 추가 보고
# 원복
git restore Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Semantic/BgPrimary.colorset/Contents.json
```

커밋:
```bash
git add Scripts/lint_color_assets.py
git commit -m "chore: add color asset lint script"
```

### Phase C — 데이터 정리 (커밋 2)

`Brand/Secondary.colorset/Contents.json` 에 dark appearance 추가. RGB 는 light 와 동일하게 박아 Brand 룰(`dark == light`) 만족.

`Brand/KakaoYellow.colorset/Contents.json` 신규 생성. light/dark 모두 `#FEE500` (sRGB, alpha 1.000).

로컬 검증:
```bash
python3 Scripts/lint_color_assets.py
echo $?  # → 0
```

`tuist generate` 후 ResourceSynthesizer 가 `DoriColors.kakaoYellow` (혹은 동등) 를 자동 생성하는지 확인:
```bash
tuist generate --no-open
grep -r "kakaoYellow\|KakaoYellow" Projects/Core/DoriDesignSystem/Derived/Sources/ | head
```

커밋:
```bash
git add Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Brand/
git commit -m "fix: add dark appearance to brand colorsets"
```

### Phase D — CI 통합 (커밋 3) + Hook 루프

`.github/workflows/build.yml` 의 "Generate workspace" step 다음, "Build project" step 이전에 삽입:

```yaml
      - name: Lint color assets
        run: python3 Scripts/lint_color_assets.py
```

커밋 & push:
```bash
git add .github/workflows/build.yml
git commit -m "ci: wire color asset lint into build workflow"
git push origin feat/47-dark-mode-support
```

#### Hook 루프 (핵심)

PR #48 에 push 가 닿으면 `Build App` 워크플로가 자동 트리거된다. 다음 루프로 green 까지 추적:

```bash
# 1. 최신 run ID 와 상태
RUN_ID=$(gh run list --branch feat/47-dark-mode-support --limit 1 \
  --json databaseId --jq '.[0].databaseId')

# 2. 진행 hook — CI 끝날 때까지 블록, exit code 로 성공(0)/실패(1)
gh run watch "$RUN_ID" --exit-status
WATCH_EXIT=$?

# 3. 실패 시 원인 추출
if [ $WATCH_EXIT -ne 0 ]; then
  gh run view "$RUN_ID" --log-failed | tail -200
fi

# 4. 최종 확인
gh pr checks 48
```

#### Fail 분류 & 대응

| 원인 분류 | 예시 | 대응 |
|---|---|---|
| **Lint/Asset 범위** | 스크립트 버그(false positive/negative), colorset JSON 파싱 오류, 누락된 dark 가 추가 발견, RGB 정규화 불일치 | 로컬에서 자동 수정 → 재커밋(같은 페이즈 위에 누적 또는 amend 대신 fix 커밋) → 재push → 재watch |
| **범위 외** | macOS runner 다운, Xcode `latest-stable` 변경으로 빌드 깨짐, mise/Tuist 설치 실패, 네트워크 timeout, Common.xcconfig fallback 충돌 | 사용자에게 로그 요약 보고 후 대기. 자동 수정 시도 금지 |

루프는 **green 한 번 확인** 으로 종료. lint step 만 green 이고 build/test 가 fail 인 부분 성공도 fail 로 간주.

## 3. When

- **순차 의존**: Phase A → B → C → D. A 가 분리되지 않으면 lint 커밋이 다른 변경과 섞여 PR review 와 CI fail 원인 격리가 모두 어려워진다.
- **Phase A 의 게이트**: 베이스라인 push 의 CI 가 green 이어야 Phase B 진입. 베이스라인이 빨간 상태에서 lint 를 얹으면 빨강이 둘이 되어 원인 구별 불가.
- **로컬 검증 후 push**: 각 Phase 내에서는 로컬에서 의도한 exit code/결과를 확인하기 전까지 push 하지 않는다. CI 시간 낭비 방지.
- **Phase D 의 push 는 lint 3커밋이 모두 쌓인 후 한 번에**: 중간 커밋만 push 하면 lint script 만 있고 데이터 fix/CI step 이 없는 상태라 CI 가 fail 한다. 의미 없는 빨강이 PR 에 박힌다.
- **Hook 루프의 타임아웃**: `gh run watch` 가 자체적으로 종료까지 블록. 사람 timeout 은 두지 않고 CI 완료를 기다린다.

## 4. 종료기준 (Definition of Done)

다음을 **모두** 만족해야 done.

- [ ] `python3 Scripts/lint_color_assets.py` 가 결함 정리 후 exit 0
- [ ] 회귀 시나리오 — `Semantic/BgPrimary.colorset` 의 dark 일시 제거 시 스크립트가 fail 보고 (스크립트 정확성 증거, 원복 후 다시 pass)
- [ ] PR #48 의 최신 CI run 에서 "Lint color assets" step 이 green
- [ ] 같은 run 의 "Build project" 와 "Run unit tests" 도 green (회귀 없음)
- [ ] `gh pr checks 48` 출력이 전부 PASS
- [ ] 최종 GitHub Actions run URL 이 이 문서 아래 "검증 기록" 섹션에 첨부됨

### 검증 기록 (완료 시 채움)

- 로컬 lint 결함 보고 로그: _(채울 자리)_
- 로컬 lint pass 로그: _(채울 자리)_
- 회귀 시나리오 fail 로그: _(채울 자리)_
- CI green run URL: _(채울 자리)_
- `gh pr checks 48` 결과: _(채울 자리)_

## 사용한 기존 자산

- [`PLAN.md`](./PLAN.md) — Scope/룰/Verification 원본
- `.github/workflows/build.yml` — lint step 삽입 위치 (line 37 "Generate workspace" 다음)
- `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Brand/Secondary.colorset/Contents.json` — 결함 1건 (수정 대상)
- `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Semantic/BgPrimary.colorset/Contents.json` — 회귀 시나리오 대상
- `Tuist/ResourceSynthesizers/Assets.stencil` — colorset → Swift enum 자동 생성 경로
