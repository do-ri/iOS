# Dori

[![App Store](https://img.shields.io/badge/App_Store-Download-0D96F6?logo=app-store&logoColor=white)]({{APP_STORE_URL}})
![Swift](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-17.6+-000000?logo=apple&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-26.2-1575F9?logo=xcode&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-TCA-purple)

> {{ONE_LINE_TAGLINE}}

App Store에 출시된 iOS 앱이며, 이 저장소는 동일 빌드의 소스를 공개한다.

## Screenshots

| {{SCENE_1}} | {{SCENE_2}} | {{SCENE_3}} |
| :---: | :---: | :---: |
| ![]({{SCREENSHOT_1_PATH}}) | ![]({{SCREENSHOT_2_PATH}}) | ![]({{SCREENSHOT_3_PATH}}) |

## Features

- {{FEATURE_1}}
- {{FEATURE_2}}
- {{FEATURE_3}}

## Tech Stack

- **Language / Platform** — Swift 6, iOS 17.6+, Xcode 26.2
- **Architecture** — TCA (The Composable Architecture)
- **Project Generation** — Tuist (mise 로 툴체인 버전 고정)
- **Auth** — Kakao SDK + Security framework 기반 토큰 저장
- **Network** — 자체 네트워크 레이어 + 인증 인터셉터

선택 근거는 [`docs/core/tech-stack.md`](docs/core/tech-stack.md) 에 정리되어 있다.

## Architecture

TCA 기반 5계층 구조다. View → Feature(Reducer) → Client 경계 → Platform / Infra 순으로 흐르고, 인증은 UI·저장소·네트워크가 하나의 흐름으로 연결된다.

```
AppFeature
  ├── Splash     # 인증 진입 판단
  ├── Intro      # 로그인
  └── MainTab    # 메인 기능 조합
```

시스템의 큰 그림, 경계, 변경 비용이 큰 결정은 [`ARCHITECTURE.md`](ARCHITECTURE.md) 에 둔다. README 는 진입점일 뿐이며, 구조 설명의 진실 출처는 그쪽이다.

## Project Structure

```
Projects/
  App/        앱 부트스트랩, dependency 조합, 루트 route 소유
  Feature/    사용자 흐름, 화면 상태
  Core/       도메인 모델, 디자인 시스템, 공통 의존성 키
  Platform/   Kakao SDK, Keychain, iOS 런타임 어댑터
  Infra/      네트워크 서비스, 인증 인터셉터, 로깅
```

각 계층의 책임과 경계 규칙은 [`docs/core/directory-structure.md`](docs/core/directory-structure.md).

## Documentation

이 저장소는 README 를 가볍게 두는 대신, 오래 가는 규칙을 주제별 문서로 분리해 관리한다. 아래 트리는 "현재 이 프로젝트가 실제로 지키고 있는 규칙" 의 전부다.

### Architecture & Core Rules
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — 시스템 모양, 모듈 경계, 변경 비용이 큰 결정
- [`docs/core/coding-style.md`](docs/core/coding-style.md) — 오래 가는 엔지니어링 스타일 (복잡도는 경계에서 흡수, 이름보다 책임)
- [`docs/core/directory-structure.md`](docs/core/directory-structure.md) — 모듈별 책임과 경계 규칙
- [`docs/core/tech-stack.md`](docs/core/tech-stack.md) — 구조에 영향을 준 기술 선택
- [`docs/core/lessons-learned.md`](docs/core/lessons-learned.md) — 다시 토론하지 않을 결정 (인증·네트워크·내비게이션)

### Frontend
- [`docs/frontend/swift-language-guide.md`](docs/frontend/swift-language-guide.md) — Swift 6 동시성 규칙, Sendable, MainActor
- [`docs/frontend/security.md`](docs/frontend/security.md) — 민감값 주입과 시크릿 경계
- [`docs/frontend/test-strategy.md`](docs/frontend/test-strategy.md) — 상태 전이와 경계 동작 우선 검증

### Backend Integration
- [`docs/backend/network-layer.md`](docs/backend/network-layer.md) — 네트워크 경계, 인터셉터, refresh, 강제 로그아웃 흐름

### Workflows
- [`docs/workflows/plan-workflow.md`](docs/workflows/plan-workflow.md) — `plan/*.md` 기반 작업 큐와 핸드오프
- [`docs/workflows/implementation-workflow.md`](docs/workflows/implementation-workflow.md) — 구현 → 테스트 → 빌드 검증 흐름
- [`docs/workflows/git-worktree.md`](docs/workflows/git-worktree.md) — 워크트리 운영 규칙

### Reference (TCA 패턴 예시)
- [`docs/reference/tca-navigation.md`](docs/reference/tca-navigation.md) — Tree / Stack / Tab / AppRoot 패턴
- [`docs/reference/tca-network.md`](docs/reference/tca-network.md) — `@DependencyClient` 기반 API Client 템플릿
- [`docs/reference/tca-test.md`](docs/reference/tca-test.md) — TestStore 기반 Reducer 테스트
- [`docs/reference/routing-guide.md`](docs/reference/routing-guide.md) — 바닐라 SwiftUI vs TCA 비교

### Plan
- [`plan/`](plan/) — 진행 중인 작업 컨텍스트와 완료 이력 (`plan/history.md`)

## Requirements & Build

```bash
mise install        # Xcode·Tuist 등 툴체인 버전 고정
tuist install       # Tuist 플러그인 설치
tuist generate      # Xcode workspace 생성
open Dori-iOS.xcworkspace
```

Kakao Native App Key 등 시크릿은 별도 설정 파일로 주입한다. 세부 규칙은 [`docs/frontend/security.md`](docs/frontend/security.md).

## Testing

- **Reducer 단위 테스트** — TCA `TestStore` 기반 상태 전이와 효과 검증
- **시각 회귀** — swift-snapshot-testing 자동화
- 전략 전반: [`docs/frontend/test-strategy.md`](docs/frontend/test-strategy.md)

## License

{{LICENSE}}

## Contact

{{CONTACT}}
