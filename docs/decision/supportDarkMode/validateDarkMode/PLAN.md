# Dark Mode Validation — (1) Asset Lint

## Context

Dori 앱은 현재 `Projects/App/Sources/DoriApp.swift:103` 의 `.preferredColorScheme(.light)` 로 다크모드를 강제 비활성화 한 상태로 출시되어 있다. 디자인 시스템(`DoriDesignSystem`) 의 Semantic 토큰 12개는 이미 light/dark 페어가 정의되어 있고, 컴포넌트 스냅샷 테스트도 light/dark 페어로 검증 중이다. 그러나 다음 두 사각지대로 인해 라이트 강제를 안전하게 풀 수 없다.

1. **Brand colorset 의 dark 누락** — `Brand/Secondary.colorset` 등은 dark appearance 가 정의돼 있지 않다. 시스템이 자동으로 어둡게 변환하면서 브랜드 색이 깨진다.
2. **카카오 옐로(`#FEE500`) 같은 외부 SDK 색상의 자동 변환** — SDK 가 자체 제공하는 색은 colorset 으로 등록돼 있지 않아 lint 범위 밖이고, 시뮬레이터에서 어둡게 변색되는 현상이 실측 확인됨.

두 결함 모두 현재의 스냅샷 회귀 자동화로는 잡히지 않는다 — 스냅샷은 "그렇게 그려진 결과" 를 정상으로 박아 통과하기 때문이다.

이 PLAN 은 다크 활성화 전 검증 자동화의 **1단계 (정적 lint)** 만 다룬다. 후속:
- (2) `assertSnapshotPair` 헬퍼 — 별도 PLAN
- (3) Feature 모듈 카탈로그 스냅샷 페어 — 별도 PLAN

## Scope

### In scope
- Brand/Semantic colorset 의 dark appearance 누락 검출
- Brand colorset 의 `dark RGB == light RGB` 검증 (브랜드 색 보존)
- 카카오 옐로 `#FEE500` 을 `Brand/KakaoYellow.colorset` 으로 신규 정의 → lint 범위 진입
- 현재 결함 1건 정리: `Brand/Secondary.colorset` 에 dark appearance 추가
- CI (`.github/workflows/build.yml`) 에 lint step 추가

### Out of scope (별도 작업)
- 카카오 버튼 코드가 실제로 `Brand/KakaoYellow.colorset` 을 참조하도록 리팩터 (Feature 영역, 별도)
- pre-commit hook / Tuist build phase 통합
- 시스템 자동 변환을 우회하는 다른 색상 정의 패턴
- assertSnapshotPair 헬퍼 및 Feature 카탈로그 스냅샷 ((2), (3) PLAN)

## Approach

### A. Lint 스크립트 (Python, 표준 라이브러리만)

`Scripts/lint_color_assets.py` 신규 생성. CI 러너에 기본 설치된 Python 3 사용, pip 의존성 없음 (json/pathlib/sys 만).

**입력**: `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/{Brand,Semantic}/**/*.colorset/Contents.json`

**룰**:
| 카테고리 | 룰 | 위반 메시지 예시 |
|---|---|---|
| Brand/ | dark appearance 존재 | `Brand/Foo.colorset is missing dark appearance` |
| Brand/ | dark RGB == light RGB (16진수 정규화 후 비교) | `Brand/KakaoYellow.colorset dark RGB differs from light (light=#FEE500, dark=#B89A1C)` |
| Semantic/ | dark appearance 존재 | `Semantic/Foo.colorset is missing dark appearance` |

**동작**:
- 모든 colorset 을 순회 후 위반 항목 전체를 stderr 출력 (첫 위반에서 abort 하지 않음 — 사용자가 한 번에 다 보고 고치도록)
- 위반 있으면 exit 1, 없으면 exit 0
- exit 시 위반 개수를 stderr 마지막 줄에 요약

### B. 데이터 결함 정리

- `Brand/Secondary.colorset/Contents.json` 에 dark appearance 추가 (RGB 는 light 와 동일하게 박아 룰 만족)
- `Brand/KakaoYellow.colorset/Contents.json` 신규 생성 (light/dark 모두 `#FEE500`)

### C. CI 통합

`.github/workflows/build.yml` 의 "Generate workspace" step 다음, "Build" step 이전에 lint step 추가:

```yaml
- name: Lint color assets
  run: python3 Scripts/lint_color_assets.py
```

`tuist generate` 와 무관하게 동작하는 정적 검사라 generate 전 실행도 가능하지만, **빌드 직전 배치**가 "lint → build → test" 의 자연스러운 피드백 순서.

## Files

| 작업 | 경로 |
|---|---|
| Create | `Scripts/lint_color_assets.py` |
| Create | `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Brand/KakaoYellow.colorset/Contents.json` |
| Modify | `Projects/Core/DoriDesignSystem/Resources/Colors.xcassets/Brand/Secondary.colorset/Contents.json` |
| Modify | `.github/workflows/build.yml` |

## Implementation Notes

- `Contents.json` 의 색상은 `color.color-space` 가 srgb 또는 display-p3 둘 다 가능. 룰 비교 시 색공간이 다르면 일단 mismatch 로 fail (Brand 컬러는 srgb 통일을 권장).
- `components` 의 `red/green/blue/alpha` 는 `0xFF` 같은 16진수 또는 `0.500` 같은 0~1 실수 두 형태가 모두 유효. 정규화 함수 필요 (16진수 → 0~255 정수, 실수 → 반올림 0~255 정수).
- 룰 위반은 colorset 경로(상대 경로)로 출력 — 사용자가 즉시 파일을 열 수 있게.
- 향후 확장 여지로 `EXEMPT` 마커(예: colorset 옆 `.lint-exempt` 파일)를 비워두되 이 PLAN 에선 구현하지 않음. 화이트리스트 필요 시점에 추가.

## Verification

1. **로컬 실행 (스크립트만)**
   - `python3 Scripts/lint_color_assets.py` → 결함 정리 전: `Brand/Secondary.colorset` 누락 보고 + exit 1
   - 결함 정리 후 재실행 → exit 0
2. **회귀 시나리오**
   - `Semantic/BgPrimary.colorset/Contents.json` 의 dark appearance 일시 제거 → 스크립트가 fail 보고
   - 원복 후 통과 확인
3. **CI 동작**
   - 임시 PR 로 의도적 누락 colorset 푸시 → GitHub Actions 의 "Lint color assets" step 이 fail 하고 빌드 step 까지 도달하지 않는지 확인
4. **신규 정의 확인**
   - `Brand/KakaoYellow.colorset` 이 ResourceSynthesizer 를 통해 `DoriColors.kakaoYellow` (또는 동등) 로 자동 생성되는지 `tuist generate` 후 Derived sources 확인

## Out of Scope but Tracked

- 카카오 버튼 (`Projects/Feature/Onboarding/Sources/...`) 이 실제로 `DoriColors.kakaoYellow` 를 참조하도록 리팩터 — 후속 작업. 이 PLAN 은 lint 가 "잡을 수 있는 상태" 까지만.
- `.preferredColorScheme(.light)` 제거 시점은 (2)(3) PLAN 완료 + 카탈로그 다크 스냅샷 전수 통과 후.
